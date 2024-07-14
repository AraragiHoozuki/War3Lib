-- 幽影诅咒
-- 累计10层时，杀死单位
ModifierMaster.MODIFIER_DEEP_SHADOW_CURSE = {
    id = 'MODIFIER_DEEP_SHADOW_CURSE',
    duration = 3,
    interval = 1,
    reapply_mode = Modifier.REAPPLY_MODE_STACK_AND_REFRESH,
    stack = 1,
    max_stack = 10,
    Effects = {{
        model = 'Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl',
        attach_point = 'overhead'
    }},
    Update = function(this)
        this.effects_scale = this.stack * 0.2 + 1
        if (this.stack >= this.max_stack and (not this.owner:IsModifierTypeAffected('MODIFIER_DEEP_SHADOW_CREATURE')) and (not IsUnitType(this.owner.unit, UNIT_TYPE_HERO) )) then
            local u = this.owner.unit
            this:Remove()
            KillUnit(u)
        end
    end
}

ModifierMaster.MODIFIER_DEEP_SHADOW_CURSE_PROVIDER = {
    id = 'MODIFIER_DEEP_SHADOW_CURSE_PROVIDER',
    duration = -1,
    interval = 1,
    reapply_mode = Modifier.REAPPLY_MODE_NO,
    Effects = {},
    BindAbility = FourCC('A00N'),
    LevelValues = {
        Range = {900,900,900,900}
    },
    Acquire = function(this) 
        this.apply_checker_group = CreateGroup()
    end,
    Update = function(this)
        local cond = Condition(function() return
            (not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)) and (not IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE))
        end)
        GroupEnumUnitsInRange(this.apply_checker_group, GetUnitX(this.owner.unit), GetUnitY(this.owner.unit), this:LV('Range'), cond)
        ForGroup(this.apply_checker_group, function()
            local u = GetEnumUnit()
            this.owner:ApplyModifier(ModifierMaster.MODIFIER_DEEP_SHADOW_CURSE, LuaUnit.Get(u), this.ability)
        end)
    end,
    Remove = function(this)
        DestroyGroup(this.apply_checker_group)
    end
}

-- 幽影生物
ModifierMaster.MODIFIER_DEEP_SHADOW_CREATURE = {
    id = 'MODIFIER_DEEP_SHADOW_CREATURE',
    duration = -1,
    interval = 0.1,
    reapply_mode = Modifier.REAPPLY_MODE_NO,
    Effects = {},
    Update = function(this)
        if this.owner:IsModifierTypeAffected('MODIFIER_DEEP_SHADOW_CURSE') then
            if (not (GetUnitAbilityLevel(this.owner.unit, AbilitySystem.Constants.CommonInvisibilityAbilityId) > 0))
            and (not this.owner:IsModifierTypeAffected('MODIFIER_ANTI_DEEP_SHADOW')) then
                UnitAddAbility(this.owner.unit, AbilitySystem.Constants.CommonInvisibilityAbilityId)
            end
        elseif GetUnitAbilityLevel(this.owner.unit, AbilitySystem.Constants.CommonInvisibilityAbilityId) > 0 then
            UnitRemoveAbility(this.owner.unit, AbilitySystem.Constants.CommonInvisibilityAbilityId)
        end
    end
}

-- 曙光
-- 移除幽影诅咒
ModifierMaster.MODIFIER_ANTI_DEEP_SHADOW = {
    id = 'MODIFIER_ANTI_DEEP_SHADOW',
    duration = 3,
    interval = 0.1,
    reapply_mode = Modifier.REAPPLY_MODE_REFRESH,
    Effects = {{
        model = [[Abilities\Spells\Human\InnerFire\InnerFireTarget.mdl]],
        attach_point = 'overhead'
    }},
    Update = function(this)
        this.owner:RemoveModifierById('MODIFIER_DEEP_SHADOW_CURSE')
    end
}

ModifierMaster.MODIFIER_ANTI_DEEP_SHADOW_PROVIDER = {
    id = 'MODIFIER_ANTI_DEEP_SHADOW_PROVIDER',
    duration = -1,
    interval = 1,
    reapply_mode = Modifier.REAPPLY_MODE_NO,
    Effects = {},
    BindAbility = FourCC('A00P'),
    LevelValues = {
        Range = {900,900,900,900}
    },
    Acquire = function(this) 
        this.apply_checker_group = CreateGroup()
    end,
    Update = function(this)
        local cond = Condition(function() return
            (not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)) and (not IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE))
        end)
        GroupEnumUnitsInRange(this.apply_checker_group, GetUnitX(this.owner.unit), GetUnitY(this.owner.unit), this:LV('Range'), cond)
        ForGroup(this.apply_checker_group, function()
            local u = GetEnumUnit()
            this.owner:ApplyModifier(ModifierMaster.MODIFIER_ANTI_DEEP_SHADOW, LuaUnit.Get(u), this.ability)
        end)
    end,
    Remove = function(this)
        DestroyGroup(this.apply_checker_group)
    end
}