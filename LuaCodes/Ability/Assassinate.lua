--刺杀
AbilitySystem.Assassinate = {
}

ModifierMaster.MODIFIER_ASSASSINATE_SELF = {
    id = 'MODIFIER_ASSASSINATE_SELF',
    duration = -1,
    interval = 65535,
    reapply_mode = Modifier.REAPPLY_MODE_NO,
    Effects = {},
    BindAbility = FourCC('A00I'),
    LevelValues = {
        DamageScale = {150, 180, 210, 240}
    },
    BeforeDealDamage = function(this, damage)
        if (IsUnitInvisible(this.owner.unit, GetOwningPlayer(damage.target.unit))) then
            damage.control_scale = damage.control_scale * this:LV('DamageScale')/100
            DestroyEffect(AddSpecialEffectTarget('Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl', damage.target.unit, 'chest'))
        end
    end
}