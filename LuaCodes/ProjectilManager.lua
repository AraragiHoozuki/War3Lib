Projectil = {}

function Projectil:new(o, lu_emitter, x, y, z, facing, settings, target_unit, target_position, damageSettings, level)
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
    o.hit_piercing = settings.hit_piercing == false
    o.hit_cooldown = settings.hit_cooldown or 1
    o.track_unit = settings.track_unit == true
    o.track_position = settings.track_position == true
    o.tracking_angle = settings.tracking_angle or -1
    o.turning_speed = settings.turning_speed or 0
    o.max_flying_distance = settings.max_flying_distance or o.velocity * 5
    o.model = settings.model or 'h000'
    o.emitter = lu_emitter
    o.damageSettings = {}
    o.damageSettings.amount = damageSettings.amount or 0
    o.damageSettings.atktype = damageSettings.atktype or Damage.ATTACK_TYPE_NORMAL
    o.damageSettings.dmgtype = damageSettings.dmgtype or Damage.DAMAGE_TYPE_NORMAL
    o.damageSettings.eletype = damageSettings.eletype or Damage.ELEMENT_TYPE_NONE
    o.level = level or 1

    --properties
    o.uuid = GUID.generate()
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
    
    SetUnitFlyHeight(o.bullet, z, 0)
    return o
end

function Projectil:GetPlayer()
    return GetOwningPlayer(self.emitter.unit)
end

function Projectil:GetLevelValue(key)
    local value = self.settings.LevelValues;
    if (value ~= nil) then value = value[key] end
    if (value ~= nil) then value = value[self.level] end
    if (value ~= nil) then
        return value
    else
        return 0
    end
end
function Projectil:LV(key) return self:GetLevelValue(key) end

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
                local distance = (x-GetUnitX(self.bullet))^2+(y-GetUnitY(self.bullet))^2
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
        --DestroyBoolExpr(cond)
        elseif (self.track_position == true) then
            if (self.target_point ~= nil) then
                local distance = self.position:Distance(self.target_point.x, self.target_point.y)
                if (distance < self.hit_range) then
                    self:OnHit(nil)
                    self.ended = true
                end
            end
        end
    end

end

function Projectil:CheckEnd()
    if self.flying_distance > self.max_flying_distance then
        self.ended = true
    end
end

function Projectil:OnHit(lu_victim)
    if lu_victim ~= nil then
        local dmg = Damage:new(nil, self.emitter, lu_victim, self.damageSettings.amount, self.damageSettings.atktype, self.damageSettings.dmgtype, self.damageSettings.eletype)
        dmg:Resolve()
    end
    if (self.settings.Hit ~= nil) then self.settings.Hit(self, lu_victim) end
end

function Projectil:OnMiss()
end

function Projectil:Remove()
    DestroyGroup(self.hit_checker_group)
    KillUnit(self.bullet)
end


ProjectilMgr = {}
ProjectilMgr.Projectils = {}


ProjectilMgr.CreateAttackProjectil = function(lu_emitter, u_target, damage_value)
    local settings = ProjectilMaster.UnitAttackProjectils[GetUnitTypeId(lu_emitter.unit)]

    local x = GetUnitX(lu_emitter.unit)
    local y = GetUnitY(lu_emitter.unit)
    local theta = GetUnitFacing(lu_emitter.unit) * Degree
    x = settings.offsetY * Cos(theta) - settings.offsetX * Sin(theta) + x
    y = settings.offsetY * Sin(theta) + settings.offsetX * Cos(theta) + y
    local z = settings.offsetZ or 0

    local dx = GetUnitX(u_target) - GetUnitX(lu_emitter.unit)
    local dy = GetUnitY(u_target) - GetUnitY(lu_emitter.unit)
    local facing = math.atan(dy,dx)
    --if (facing < 0) then facing = facing + 2 * math.pi end

    local damageSettings = {amount = damage_value}
    local prjt = Projectil:new(nil, lu_emitter, x, y, z, facing, settings, u_target, nil, damageSettings)
    --local id = ProjectilMgr.GetNextId()
    local id = prjt.uuid
    ProjectilMgr.Projectils[id] = prjt
end

ProjectilMgr.CreateProjectilBySettings = function(settings, lu_emitter, u_target, vec_tpos, damageSettings, level)
    local x = GetUnitX(lu_emitter.unit)
    local y = GetUnitY(lu_emitter.unit)
    local dx
    local dy
    if (u_target ~= nil) then
        dx = GetUnitX(u_target) - x
        dy = GetUnitY(u_target) - y
    elseif vec_tpos ~= nil then
        dx = vec_tpos.x - x
        dy = vec_tpos.y - y
    end
    local angle = math.atan(dy,dx)

    -- calc emit offset
    local theta = angle
    x = settings.offsetY * Cos(theta) - settings.offsetX * Sin(theta) + x
    y = settings.offsetY * Sin(theta) + settings.offsetX * Cos(theta) + y
    local z = settings.offsetZ or 0

    local prjt = Projectil:new(nil, lu_emitter, x, y, z, angle, settings, u_target, vec_tpos, damageSettings, level)
    ProjectilMgr.Projectils[prjt.uuid] = prjt
end

ProjectilMgr.CreateProjectilById = function(pid, lu_emitter, u_target, vec_tpos, damageSettings, level)
    local settings = ProjectilMaster.AbilityProjectils[pid]
    ProjectilMgr.CreateProjectilBySettings(settings, lu_emitter, u_target, vec_tpos, damageSettings, level)
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