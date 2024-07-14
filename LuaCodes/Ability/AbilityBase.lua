AbilitySystem = {}
AbilitySystem.Constants = {
    CommonInvisibilityAbilityId = FourCC('A00L'),
    --HighInvisibilityAbilityId = FourCC('')
}

AbilitySystem.AddAbilityWithIntrinsecModifier = function(u, abilityId)
    UnitAddAbility(u, abilityId)
    if AbilitySystem.IntrinsecModifiers[abilityId] ~= nil then
        LuaUnit.Get(u):AcquireModifierById(AbilitySystem.IntrinsecModifiers[abilityId], LuaUnit.Get(u), abilityId)
    end
end
AbilitySystem.IntrinsecModifiers = {
    --幽影生物
    [FourCC('A00M')] = 'MODIFIER_DEEP_SHADOW_CREATURE',
    --幽影诅咒光环
    [FourCC('A00N')] = 'MODIFIER_DEEP_SHADOW_CURSE_PROVIDER',
    --曙光结界
    [FourCC('A00P')] = 'MODIFIER_ANTI_DEEP_SHADOW_PROVIDER'
}