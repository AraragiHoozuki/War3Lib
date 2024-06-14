Projectil = {}

function Projectil:new(o, lu_emitter, x, y, facing, settings, target_unit, target_position)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    --settings
    o.settings = settings
    o.velocity = settings.velocity or 900
    o.hit_range = settings.hit_range or 25
    o.hit_range_2 = (o.hit_range)^2
    o.hit_other = settings.hit_other == true
    o.hit_ally = settings.hit_ally == true
    o.track_unit = settings.track_unit == true
    o.track_position = settings.track_position == true
    o.tracking_angle = settings.tracking_angle or -1
    o.turning_speed = settings.turning_speed or 0
    o.max_flying_distance = settings.max_flying_distance or o.velocity * 5
    o.model = settings.model or 'h000'
    o.emitter = lu_emitter

    --properties
    o.position = Vector2:new(nil, x, y)
    o.bullet = CreateUnit(GetOwningPlayer(lu_emitter.unit), FourCC(o.model), o.position.x, o.position.y, facing/Degree)
    o.angle = facing -- radius not degree
    o.flying_time = 0
    o.flying_distance = 0
    o.target_unit = target_unit or nil
    o.target_point = target_position or nil
    o.tracking_stopped = false
    o.hit_checker_group = CreateGroup()
    o.ended = false
    
    return o
end

function Projectil:Track()
    if self.tracking_stopped then 
        BlzSetUnitFacingEx(self.bullet, self.angle / Degree)
        return
    end
    if (self.track_unit == true) then
        if self.target_unit ~= nil then
            local dx = GetUnitX(self.target_unit) - GetUnitX(self.bullet)
            local dy = GetUnitY(self.target_unit) - GetUnitY(self.bullet)
            local target_angle = math.atan(dy,dx)
            --if (target_angle < 0) then target_angle = target_angle + 2 * math.pi end
            local angle_to_turn = AngleDiff(self.angle, target_angle)
            local max_turn_angle = self.turning_speed * CoreTicker.Interval
            local delta_angle
            if (angle_to_turn > 0) then
                delta_angle = math.min(angle_to_turn, max_turn_angle)
            else
                delta_angle = math.max(angle_to_turn, -max_turn_angle)
            end
            self.angle = self.angle + delta_angle
            BlzSetUnitFacingEx(self.bullet, self.angle / Degree)
            if math.abs(AngleDiff(self.angle, target_angle)) > self.tracking_angle then
                print('target angle: ', target_angle)
                print('self angle: ', self.angle)
                print('tracking angle: ', self.tracking_angle)
                self.tracking_stopped = true
                print('tracking fail')
            end
        end
    elseif self.track_position == true then
        if self.target_point ~= nil then
            local dx = self.target_point.x - GetUnitX(self.bullet)
            local dy = self.target_point.y - GetUnitY(self.bullet)
            self.angle = math.atan(dy,dx)
            BlzSetUnitFacingEx(self.bullet, self.angle * 180 / math.pi)
        end
    end
end

function Projectil:Displace()
    local x = self.velocity * Cos(self.angle) * CoreTicker.Interval
    local y = self.velocity * Sin(self.angle) * CoreTicker.Interval
    self.position.x = self.position.x + x
    self.position.y = self.position.y + y
    SetUnitX(self.bullet, self.position.x)
    SetUnitY(self.bullet, self.position.y)
    self.flying_distance = self.flying_distance + self.velocity * CoreTicker.Interval
end

function Projectil:Update()
    if (self.ended == true) then return end
    self.flying_time = self.flying_time + CoreTicker.Interval
    self:Track()
    self:Displace()
    self:CheckHit()
    self:CheckEnd()
end

function Projectil:CheckHit()
    if (self.hit_other == false) then
        if (self.track_unit == true) then
            if self.target_unit ~= nil then
                local x = GetUnitX(self.target_unit)
                local y = GetUnitY(self.target_unit)
                local distance = (x-self.position.x)^2+(y-self.position.y)^2
                if (distance < self.hit_range_2) then
                    self:OnHit(LuaUnit.Get(self.target_unit))
                    self.ended = true
                end
            end
        end
    else
        local cond = Condition(function() return
            (IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(self.emitter.unit)) or self.hit_ally == true) and
            not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
        end)
        GroupEnumUnitsInRange(self.hit_checker_group, self.position.x, self.position.y, self.hit_range, cond)
        local hit = FirstOfGroup(self.hit_checker_group)
        if (hit ~= nil) then
            self:OnHit(LuaUnit.Get(hit))
            self.ended = true
        end
        --DestroyBoolExpr(cond)
    end

end

function Projectil:CheckEnd()
    if self.flying_distance > self.max_flying_distance then
        self.ended = true
    end
end

function Projectil:OnHit(lu)
    self.settings.Hit(self, lu)
end

function Projectil:OnMiss()
end

function Projectil:Remove()
    DestroyGroup(self.hit_checker_group)
    KillUnit(self.bullet)
end


ProjectilMgr = {}
ProjectilMgr.DummyId = FourCC('h000')
ProjectilMgr.MaxId = 0

ProjectilMgr.Projectils = {}

ProjectilMgr.GetNextId = function()
    if ProjectilMgr.MaxId < 1 then
        ProjectilMgr.MaxId = 1
        return 1
    end
    for i = 1, ProjectilMgr.MaxId do
        if ProjectilMgr.Projectils[i] == nil then
            return i
        end
    end
    ProjectilMgr.MaxId = ProjectilMgr.MaxId + 1
    return ProjectilMgr.MaxId
end

ProjectilMgr.CreateProjectil = function(lu_emitter, x, y, facing, settings)
    local prjt = Projectil:new(nil, lu_emitter, x, y, facing, settings)
    local id = ProjectilMgr.GetNextId()
    ProjectilMgr.Projectils[id] = prjt
end

ProjectilMgr.CreateAttackProjectil = function(lu_emitter, u_target)
    local settings = ProjectilMaster.UnitAttackProjectils[GetUnitTypeId(lu_emitter.unit)]

    local x = GetUnitX(lu_emitter.unit)
    local y = GetUnitY(lu_emitter.unit)
    local theta = GetUnitFacing(lu_emitter.unit) * Degree
    x = settings.offsetY * Cos(theta) - settings.offsetX * Sin(theta) + x
    y = settings.offsetY * Sin(theta) + settings.offsetX * Cos(theta) + y

    local dx = GetUnitX(u_target) - GetUnitX(lu_emitter.unit)
    local dy = GetUnitY(u_target) - GetUnitY(lu_emitter.unit)
    local facing = math.atan(dy,dx)
    --if (facing < 0) then facing = facing + 2 * math.pi end

    local prjt = Projectil:new(nil, lu_emitter, x, y, facing, settings, u_target, nil)
    local id = ProjectilMgr.GetNextId()
    ProjectilMgr.Projectils[id] = prjt
end

ProjectilMgr.Update = function()
    for k,v in pairs(ProjectilMgr.Projectils) do
        if v ~= nil then
            v:Update()
            if (v.ended == true) then
                ProjectilMgr.Projectils[k] = nil
                v:Remove()
            end
        end
	end
end