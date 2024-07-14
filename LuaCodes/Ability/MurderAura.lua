-- 谋杀光环
AbilitySystem.MURDER_AURA = {}
ModifierMaster.MODIFIER_MURDER_AURA_SELF = {
    id = 'MODIFIER_MURDER_AURA_SELF',
    duration = -1,
    interval = 1,
    reapply_mode = Modifier.REAPPLY_MODE_NO,
    Effects = {},
    BindAbility = FourCC('A00E'),
    LevelValues = {
        Range = {300,300,300,300}
    },
    Acquire = function(this) 
        this.apply_checker_group = CreateGroup()
    end,
    Update = function(this) 
        local cond = Condition(function() return
            (IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(this.owner.unit))) and
            (not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD))
        end)
        GroupEnumUnitsInRange(this.apply_checker_group, GetUnitX(this.owner.unit), GetUnitY(this.owner.unit), this:LV('Range'), cond)
        ForGroup(this.apply_checker_group, function()
            local u = GetEnumUnit()
            this.owner:ApplyModifier(ModifierMaster.MODIFIER_MURDER_AURA_TARGET, LuaUnit.Get(u), this.ability)
        end)
    end,
    Remove = function(this) DestroyGroup(this.apply_checker_group) end
}

ModifierMaster.MODIFIER_MURDER_AURA_TARGET = {
    id = 'MODIFIER_MURDER_AURA_TARGET',
    duration = -1,
    interval = 1,
    reapply_mode = Modifier.REAPPLY_MODE_STACK,
    stack = 15,
    max_stack = 100,
    Effects = {{
        model = 'Abilities\\Spells\\Undead\\Curse\\CurseTarget.mdl',
        attach_point = 'overhead'
    }},
    BindAbility = FourCC('A00E'),
    LevelValues = {
        DamageRateBonusPerStack = {2,3,4,5}
    },
    Update = function(this) 
        this.stack = this.stack - 5
        
    end,
    BeforeTakeDamage = function(this, damage)
        if (damage.source == this.applier) then
            if (damage.dmgtype ~= Damage.DAMAGE_TYPE_DIRECT and damage.dmgtype ~= Damage.DAMAGE_TYPE_DOT) then
                damage.control_rate = damage.control_rate + this.stack * this:LV('DamageRateBonusPerStack')
                DestroyEffect(AddSpecialEffectTarget('Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodLarge0.mdl', this.owner.unit, 'chest'))
                this.stack = 0
            end
        end
    end
}