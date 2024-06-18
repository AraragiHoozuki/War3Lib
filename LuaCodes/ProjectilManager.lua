Projectil = {}
Projectil.TRACK_TYPE_NONE = 0
Projectil.TRACK_TYPE_UNIT = 1
Projectil.TRACK_TYPE_POSITION = 2
Projectil.TRACK_TYPE_CUSTOM = 3

Projectil.tempLoc = Location(0, 0)
Projectil.GetUnitHitZ = function(unit)
    return BlzGetLocalUnitZ(unit) + GetUnitFlyHeight(unit)+ 60
end

function Projectil:new(o, lu_emitter, x, y, z, facing, settings, target_unit, target_position, damageSettings, level)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    --settings
    o.settings = settings
    o.velocity = settings.velocity or 900
    o.velocityZ = settings.velocityZ or 0
    o.velocityZMax = settings.velocityZMax or o.velocityZ
    o.no_gravity = settings.no_gravity or false
    o.hit_range = settings.hit_range or 25
    o.hit_rangeZ = settings.hit_rangeZ or 0
    o.hit_range_2 = (o.hit_range)^2
    o.hit_terrain = settings.hit_terrain or true
    o.hit_other = settings.hit_other == true
    o.hit_ally = settings.hit_ally == true
    o.hit_piercing = settings.hit_piercing == false
    o.hit_cooldown = settings.hit_cooldown or 1
    o.track_type = settings.track_type or Projectil.TRACK_TYPE_NONE
    o.trackZ = settings.trackZ or false
    o.tracking_angle = settings.tracking_angle or -1
    o.turning_speed = settings.turning_speed or 0
    o.max_flying_distance = settings.max_flying_distance or o.velocity * 5
    o.model = settings.model or 'Abilities\\Weapons\\LichMissile\\LichMissile.mdl'
    o.emitter = lu_emitter
    o.damageSettings = {}
    o.damageSettings.amount = damageSettings.amount or 0
    o.damageSettings.atktype = damageSettings.atktype or Damage.ATTACK_TYPE_NORMAL
    o.damageSettings.dmgtype = damageSettings.dmgtype or Damage.DAMAGE_TYPE_NORMAL
    o.damageSettings.eletype = damageSettings.eletype or Damage.ELEMENT_TYPE_NONE
    o.level = level or 1

    --properties
    o.uuid = GUID.generate()
    o.position = Vector3:new(nil, x, y)
    o.bullet = AddSpecialEffect(o.model, o.position.x, o.position.y)
    o.yaw = facing --radians not degree
    o.pitch = 0 --radians not degree angleZ
    o.flying_time = 0
    o.flying_distance = 0
    o.target_unit = target_unit or nil
    o.target_position = target_position or nil
    o.tracking_stopped = false
    o.hit_checker_group = CreateGroup()
    o.ended = false
    
    --set Z
    MoveLocation(Projectil.tempLoc, o.position.x, o.position.y)
    o.position.z = z + GetLocationZ(Projectil.tempLoc) + GetUnitFlyHeight(o.emitter.unit)
    o:InitVelocityZ()
    
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

function Projectil:InitVelocityZ()
    --对于有目标的非追踪弹道，若受到重力，需要确定初始Z轴速度
    if self.no_gravity == true then return end
    if self.velocityZ ~= 0 then return end

    local tx, ty, tz
    if (self.target_unit ~= nil) then
        tx = GetUnitX(self.target_unit)
        ty = GetUnitY(self.target_unit)
        tz = Projectil.GetUnitHitZ(self.target_unit)
    elseif (self.target_position ~= nil) then
        tx = self.target_position.x
        ty = self.target_position.y
        MoveLocation(Projectil.tempLoc, tx, ty)
        tz = GetLocationZ(Projectil.tempLoc) + (self.target_position.z or 0)
    end
    local xy_dis = self.position:Distance(tx, ty)
    local t = xy_dis / self.velocity

    local deltZ = tz - self.position.z
    self.velocityZ = GameConstants.Gravity * t / 2 + deltZ / t
    if (self.velocityZ > self.velocityZMax) then self.velocityZ = self.velocityZMax end
    if (self.velocityZ < -self.velocityZMax) then self.velocityZ = -self.velocityZMax end
end

function Projectil:CalcDeltaYaw(target_yaw)
    local angle_to_turn = AngleDiff(self.yaw, target_yaw)
    local max_turn_angle = self.turning_speed * CoreTicker.Interval
    local delta_yaw
    if (angle_to_turn > 0) then
        delta_yaw = math.min(angle_to_turn, max_turn_angle)
    else
        delta_yaw = math.max(angle_to_turn, -max_turn_angle)
    end
    return delta_yaw
end

function Projectil:TrackXY()
    if (self.tracking_stopped == false) then
        --追踪单位
        if (self.track_type == Projectil.TRACK_TYPE_UNIT) then
            if self.target_unit ~= nil then
                local dx = GetUnitX(self.target_unit) - self.position.x
                local dy = GetUnitY(self.target_unit) - self.position.y
                local target_yaw = math.atan(dy,dx)
                --if (target_yaw < 0) then target_angle = target_angle + 2 * math.pi end
                self.yaw = self.yaw + self:CalcDeltaYaw(target_yaw)
                
                if math.abs(AngleDiff(self.yaw, target_yaw)) > self.tracking_angle then
                    print('target angle: ', target_yaw)
                    print('self angle: ', self.yaw)
                    print('tracking angle: ', self.tracking_angle)
                    self.tracking_stopped = true
                    print('tracking fail')
                end
            end
        --追踪点
        elseif self.track_type == Projectil.TRACK_TYPE_POSITION then
            if self.target_position ~= nil then
                local dx = self.target_position.x - self.position.x
                local dy = self.target_position.y - self.position.y
                local target_yaw = math.atan(dy,dx)
                self.yaw = self.yaw + self:CalcDeltaYaw(target_yaw)
            end
        end
    end
    BlzSetSpecialEffectYaw(self.bullet, self.yaw)
end

function Projectil:TrackZ()
    if (self.tracking_stopped == false) then
        if (self.trackZ ~= false) then
            local tx, ty, tz
            if (self.track_type == Projectil.TRACK_TYPE_UNIT) then
                if (self.target_unit ~= nil) then
                    tx = GetUnitX(self.target_unit)
                    ty = GetUnitY(self.target_unit)
                    tz = Projectil.GetUnitHitZ(self.target_unit)
                end
            elseif self.track_type == Projectil.TRACK_TYPE_POSITION then
                if (self.target_position ~= nil) then
                    tx = self.target_position.x
                    ty = self.target_position.y
                    MoveLocation(Projectil.tempLoc, tx, ty)
                    tz = GetLocationZ(Projectil.tempLoc)  + (self.target_position.z or 0)
                end
            end
            local xy_dis = self.position:Distance(tx, ty)
            local t = xy_dis / self.velocity
            local vz = (tz - self.position.z) / t
            if ( vz > self.velocityZMax) then 
                vz = self.velocityZMax
            elseif (vz < -self.velocityZMax) then
                vz = - self.velocityZMax
            end
            self.velocityZ = vz
        end
    end
    self.pitch = math.atan(self.velocityZ, self.velocity)
    BlzSetSpecialEffectPitch(self.bullet, -self.pitch)
end

function Projectil:Displace()
    local x = self.velocity * Cos(self.yaw) * CoreTicker.Interval
    local y = self.velocity * Sin(self.yaw) * CoreTicker.Interval
    local z = self.velocityZ * CoreTicker.Interval
    self.position.x = self.position.x + x
    self.position.y = self.position.y + y
    self.position.z = self.position.z + z
    BlzSetSpecialEffectX(self.bullet, self.position.x)
    BlzSetSpecialEffectY(self.bullet, self.position.y)
    BlzSetSpecialEffectZ(self.bullet, self.position.z)
    self.flying_distance = self.flying_distance + self.velocity * CoreTicker.Interval
end

function Projectil:UpdateVelocity()
    if self.no_gravity == false then
        self.velocityZ = self.velocityZ - GameConstants.Gravity * CoreTicker.Interval
    end
end

function Projectil:Update()
    if (self.ended == true) then return end
    self.flying_time = self.flying_time + CoreTicker.Interval
    self:TrackXY()
    self:TrackZ()
    self:Displace()
    self:UpdateVelocity()
    self:CheckHit()
    self:CheckEnd()
end

function Projectil:CheckHit()
    if (self.hit_terrain == true) then
        MoveLocation(Projectil.tempLoc, self.position.x, self.position.y)
        local terrainZ = GetLocationZ(Projectil.tempLoc)
        if (self.position.z + 10 < terrainZ ) then
            self:OnHit(nil)
            self.ended = true
            return
        end
    end
    if (self.hit_other == false) then
        if (self.track_type == Projectil.TRACK_TYPE_UNIT) then
            if self.target_unit ~= nil then
                local x = GetUnitX(self.target_unit)
                local y = GetUnitY(self.target_unit)
                local distance = (x-self.position.x)^2+(y-self.position.y)^2
                local z_check = true
                if (self.hit_rangeZ > 0) then
                    z_check = (math.abs(Projectil.GetUnitHitZ(self.target_unit) - self.position.z) < self.hit_rangeZ)
                end
                if (distance < self.hit_range_2 and z_check) then
                    self:OnHit(LuaUnit.Get(self.target_unit))
                    self.ended = true
                    return
                end
            end
        end
    else
        local cond = Condition(function() return
            (IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(self.emitter.unit)) or self.hit_ally == true) and
            (not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)) and
            ((math.abs(Projectil.GetUnitHitZ(GetFilterUnit()) - self.position.z) < self.hit_rangeZ) or self.hit_rangeZ == 0)
        end)
        GroupEnumUnitsInRange(self.hit_checker_group, self.position.x, self.position.y, self.hit_range, cond)
        local hit = FirstOfGroup(self.hit_checker_group)
        if (hit ~= nil) then
            self:OnHit(LuaUnit.Get(hit))
            self.ended = true
        --DestroyBoolExpr(cond)
        elseif (self.track_type == Projectil.TRACK_TYPE_POSITION) then
            if (self.target_position ~= nil) then
                local distance = self.position:Distance(self.target_position.x, self.target_position.y)
                local z_check = true
                if (self.hit_rangeZ > 0) then
                    z_check = ((self.target_position.z - self.position.z) < self.hit_rangeZ)
                end
                if (distance < self.hit_range and z_check) then
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

function Projectil:End()
    self.ended = true
end

function Projectil:Remove()
    DestroyGroup(self.hit_checker_group)
    DestroyEffect(self.bullet)
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

    local damageSettings = {amount = damage_value, atktype = Damage.ATTACK_TYPE_PROJECTIL}
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