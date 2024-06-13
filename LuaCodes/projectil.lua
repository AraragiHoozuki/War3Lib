Projectil = {}
Projectil.UnitAttackProjectils = {
    [FourCC('earc')] = {
        model = 'h000',
        velocity = 200,
        track_unit = true,
        track_position = false,
        tracking_range = 100,
        max_flying_distance = 2500
    }
}

function Projectil:new(o, lu_emitter, x, y, facing, settings, target_unit, target_position)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    --settings
    o.velocity = settings.velocity or 900
    o.hit_range = settings.hit_range or 10
    o.hit_range_2 = (settings.hit_range or 10)^2
    o.track_unit = settings.track_unit == true
    o.track_position = settings.track_position == true
    o.max_flying_distance = settings.max_flying_distance or o.velocity * 5
    o.model = settings.model or 'h000'
    o.emitter = lu_emitter

    --properties
    o.position = Vector2:new(nil, x, y)
    o.bullet = CreateUnit(GetOwningPlayer(lu_emitter.unit), FourCC(o.model), x, y, facing)
    o.angle = facing
    o.flying_time = 0
    o.flying_distance = 0
    o.target_unit = target_unit or nil
    o.target_point = target_position or nil
    o.ended = false
    return o
end

function Projectil:Track()
    if (self.track_unit == true) then
        if self.target_unit ~= nil then
            local dx = GetUnitX(self.target_unit) - GetUnitX(self.bullet)
            local dy = GetUnitY(self.target_unit) - GetUnitY(self.bullet)
            self.angle = math.atan(dy,dx)
            SetUnitFacing(self.bullet, self.angle * 180 / math.pi)
        end
    elseif self.tack_position == true then
        if self.target_point ~= nil then
            local dx = self.target_point.x - GetUnitX(self.bullet)
            local dy = self.target_point.y - GetUnitY(self.bullet)
            self.angle = math.atan(dy,dx)
            SetUnitFacing(self.bullet, self.angle * 180 / math.pi)
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
    print(self.flying_distance, self.max_flying_distance)
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
    if (self.track_unit == true) then
        if self.target_unit ~= nil then
            local x = GetUnitX(self.target_unit)
            local y = GetUnitY(self.target_unit)
            local distance = (x-self.position.x)^2+(y-self.position.y)^2
            if (distance < self.hit_range_2) then
                self.ended = true
            end
        end
    end
end

function Projectil:CheckEnd()
    if self.flying_distance > self.max_flying_distance then
        self.ended = true
    end
end

function Projectil:OnMiss()
end

function Projectil:Remove()
    KillUnit(self.bullet)
end


ProjectilMgr = {}
ProjectilMgr.DummyId = FourCC('h000')
ProjectilMgr.MaxId = 0

ProjectilMgr.Projectils = {}

ProjectilMgr.GetNextId = function()
    print(ProjectilMgr.MaxId)
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
    local x = GetUnitX(lu_emitter.unit)
    local y = GetUnitY(lu_emitter.unit)
    local facing = GetUnitFacing(lu_emitter.unit) * math.pi / 180
    local settings = Projectil.UnitAttackProjectils[GetUnitTypeId(lu_emitter.unit)]
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