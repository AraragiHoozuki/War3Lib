--冰风暴
AbilitySystem.ICE_STORM = {
}
AbilitySystem.ICE_STORM.Projectil = {
    model = 'Abilities\\Weapons\\LichMissile\\LichMissile.mdl',
    velocity = 0,
    velocityZ = 0,
    velocityZMax = 99999,
    no_gravity = false,
    hit_range = 60,
    hit_rangeZ = 40,
    hit_terrain = true,
    hit_other = true,
    hit_ally = false,
    hit_piercing = false,
    hit_cooldown = 1,
    track_type = Projectil.TRACK_TYPE_NONE,
    trackZ = false,
    tracking_angle = 60 * Degree,
    turning_speed = 60 * Degree,
    max_flying_distance = 5000,
    offsetX = 0,
    offsetY = 0,
    offsetZ = 0,
    Hit = nil
}
AbilitySystem.ICE_STORM.Cast = function()
    local lu_caster = LuaUnit.Get(GetTriggerUnit())
    local x0 = GetUnitX(lu_caster.unit)
    local y0 = GetUnitY(lu_caster.unit)
    local x = GetSpellTargetX()
    local y = GetSpellTargetY()
    local lv = GetUnitAbilityLevel(lu_caster.unit, GetSpellAbilityId())

    for i = 1,5 do
        CoreTicker.RegisterDelayedAction(
            function()
                for j = 1, 20 do
                    local radius = math.random(0,400)
                    local angle = math.random(0, 2*math.pi)
                    local x1 = x + radius*Cos(angle)
                    local y1 = y + radius*Sin(angle)
                    Projectil:new(nil, 
                    lu_caster, 
                    x1, y1, 2000, 0, 
                    AbilitySystem.ICE_STORM.Projectil,
                    nil, 
                    Vector3:new(nil, x1, y1), 
                    {
                        amount = 25*(lv+1),
                        atktype = Damage.ATTACK_TYPE_PROJECTIL,
                        dmgtype = Damage.DAMAGE_TYPE_NORMAL,
                        eleltype = Damage.ELEMENT_TYPE_KRYO
                    }, 
                    lv)
                end
            end,
            0.5 * i
        )
    end
end