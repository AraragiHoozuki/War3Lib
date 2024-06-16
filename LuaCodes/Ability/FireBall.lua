-- 火球术
-- 向目标位置投掷火球
AbilitySystem.FireBall = function()
    local lu = LuaUnit.Get(GetTriggerUnit())
    local x = GetSpellTargetX()
    local y = GetSpellTargetY()
    local lv = GetUnitAbilityLevel(lu.unit, GetSpellAbilityId())
    local tpos= Vector2:new(nil, x, y)
    local damageSettings = {
        amount = 50,
        atktype = Damage.ATTACK_TYPE_,
        dmgtype = Damage.DAMAGE_TYPE_NORMAL,
        eletype = Damage.ELEMENT_TYPE_NONE
    }
    ProjectilMgr.CreateProjectilById('FireBall', lu, nil, tpos, damageSettings, lv)
end