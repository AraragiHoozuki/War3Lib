--高等隐身术
AbilitySystem.HighInvisibility = {
    AbilityCode = FourCC('A00F'),
    BuffCode = FourCC('B002'),
    ContinuedAbilityCode = FourCC('A00H')
}

AbilitySystem.HighInvisibility.Cast = function()
    local lu_caster = LuaUnit.Get(GetTriggerUnit())
    local lu_target = LuaUnit.Get(GetSpellTargetUnit())
    lu_caster:ApplyModifier(ModifierMaster.MODIFIER_HIGH_INVIS_OBSERVER, lu_target)
end

ModifierMaster.MODIFIER_HIGH_INVIS_OBSERVER = {
    id = 'MODIFIER_HIGH_INVIS_OBSERVER',
    duration = -1,
    interval = 0.1,
    reapply_mode = Modifier.REAPPLY_MODE_NO,
    Effects = {},
    BindAbility = FourCC('A00F'),
    LevelValues = {
        ContinueTime = {0.25, 0.5, 0.75, 1}
    },
    Acquire = function(this) 
        this.continued = false
    end,
    Update = function(this)
        UnitRemoveAbility(this.owner.unit, FourCC('B004'))
        if GetUnitAbilityLevel(this.owner.unit, AbilitySystem.HighInvisibility.BuffCode) < 1 then
            if this.continued == false then
                UnitAddAbility(this.owner.unit, FourCC('A00H'))
                CoreTicker.RegisterDelayedAction(function()
                    UnitRemoveAbility(this.owner.unit, FourCC('A00H'))
                end, this:LV('ContinueTime'))
                this.continued = true
            elseif GetUnitAbilityLevel(this.owner.unit, FourCC('A00H')) < 1 then
                this:Remove()
            end
        end
    end
}