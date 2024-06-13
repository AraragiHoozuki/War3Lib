ModifierData = {
    MODIFIER_TEST = {
        id = 'MODIFIER_TEST',
        duration = 6,
        interval = 1,
        Effects = {{
            model = 'Abilities\\Spells\\Human\\ManaFlare\\ManaFlareTarget.mdl',
            attach_point = 'overhead'
        }},
        Update = function(this)
            local life = GetWidgetLife(this.owner.unit)
            SetWidgetLife(this.owner.unit, life + 10)
            DestroyEffect(AddSpecialEffectTarget('Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl', this.owner.unit, 'origin'))
        end,
        debug_string = ''
    },
    MODIFIER_TEST2 = {
        id = 'MODIFIER_TEST',
        duration = 7,
        interval = 1,
        Update = function(owner)
            print('Modifer updated! owner is '..GetUnitName(owner.unit))
        end,
        debug_string = ''
    }
}