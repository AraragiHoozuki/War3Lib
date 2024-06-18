--冰霜护甲
--减少受到近战伤害
--减少攻击者攻速
AbilitySystem.ICE_SHIELD = {}

AbilitySystem.ICE_SHIELD.SelfModifier = {
    id = 'MODIFIER_ICE_SHIELD_SELF',
    duration = 30,
    interval = 1,
    reapply_mode = Modifier.REAPPLY_MODE_REFRESH,
    Effects = {{
        model = 'Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorTarget.mdl',
        attach_point = 'chest'
    }},
    BindAbility = FourCC('A009'),
    LevelValues = {
        MeleeDamageModify = {-5, -8, -10, -15}
    },
    BeforeTakeDamage = function(this, damage)
        if (damage.atktype == Damage.ATTACK_TYPE_MELEE) then
            damage.control_add_after = (damage.control_add_after or 0) + this:LV('MeleeDamageModify')
            this.applier:ApplyModifier(AbilitySystem.ICE_SHIELD.SlowModifier, damage.source, FourCC('A009'))
        end
    end,
}

AbilitySystem.ICE_SHIELD.SlowModifier = {
    id = 'MODIFIER_ICE_SHIELD_SLOW',
    duration = 4,
    interval = 1,
    reapply_mode = Modifier.REAPPLY_MODE_REFRESH,
    bonitas = -1,
    Effects = {{
        model = 'Abilities\\Weapons\\ZigguratFrostMissile\\ZigguratFrostMissile.mdl',
        attach_point = 'hand'
    }},
    BindAbility = FourCC('A009'),
    LevelValues = {
        AttackSpeedModifyPct = {-30, -40, -50, -50}
    },
    Acquire = function(this)
        this.modified_atk_spd = this:LV('AttackSpeedModifyPct')
        this.owner:AttackSpeedModify(this:LV('AttackSpeedModifyPct'))
    end,
    Remove = function(this)
        this.owner:AttackSpeedModify(-this.modified_atk_spd)
    end
}

AbilitySystem.ICE_SHIELD.Cast = function()
    local lu_caster = LuaUnit.Get(GetTriggerUnit())
    local lu_target = LuaUnit.Get(GetSpellTargetUnit())
    lu_caster:ApplyModifier(AbilitySystem.ICE_SHIELD.SelfModifier, lu_target, FourCC('A009'))
end