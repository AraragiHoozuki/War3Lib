--极寒领域
AbilitySystem.FREZZING_REALM = {}
AbilitySystem.FREZZING_REALM.AuraModifier = {
    id = 'MODIFIER_FREEZING_REALM_AURA',
    duration = -1,
    interval = 0.1,
    Effects = {},
    BindAbility = FourCC('A007'),
    LevelValues = {
        AuraRange = {900, 900, 900, 900}
    },
    Acquire = function(this)
        this.checker_group = CreateGroup()
    end,
    Update = function(this)
        local cond = Condition(function()
            return (IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(this.owner.unit))) and
            (not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD))
        end)
        GroupEnumUnitsInRange(this.checker_group, GetUnitX(this.owner.unit), GetUnitY(this.owner.unit), this:LV('AuraRange'), cond)
        ForGroup(this.checker_group, function()
            local lu = LuaUnit.Get(GetEnumUnit())
            if not lu:IsModifierTypeAffected('MODIFIER_FREEZING_REALM_EFFECT') then
                this.owner:ApplyModifier(AbilitySystem.FREZZING_REALM.EffectModifier, lu)
            end
        end)
    end,
    Remove = function(this) DestroyGroup(this.checker_group) end
}

AbilitySystem.FREZZING_REALM.EffectModifier = {
    id = 'MODIFIER_FREEZING_REALM_EFFECT',
    duration = -1,
    interval = nil, -- default = CoreTicker.Interval
    remove_on_death = true,
    valid_when_death = false,
    Effects = {{
        model = 'Abilities\\Weapons\\ZigguratFrostMissile\\ZigguratFrostMissile.mdl',
        attach_point = 'foot'
    }},
    BindAbility = FourCC('A007'),
    LevelValues = {
        AuraRange = {900, 900, 900, 900},
        MaxMoveSpeedModPercent = {-50, -65, -80, -95}
    },
    Acquire = function(this)
        this.last_move_mod = 0
    end,
    Update = function(this)
        local dx = GetUnitX(this.owner.unit) - GetUnitX(this.applier.unit)
        local dy = GetUnitY(this.owner.unit) - GetUnitY(this.applier.unit)
        local distance = math.sqrt(dx * dx + dy * dy)
        local max_distance = this:LV('AuraRange')
        if distance > max_distance then
            this:Remove()
        else
            local delta = max_distance - distance
            local move_speed = GetUnitMoveSpeed(this.owner.unit)
            move_speed = move_speed - this.last_move_mod
            local move_mod = move_speed * (this:LV('MaxMoveSpeedModPercent') / 100) * delta / max_distance
            move_mod = math.floor(move_mod)
            move_speed = move_speed + move_mod
            SetUnitMoveSpeed(this.owner.unit, move_speed)
            this.last_move_mod = move_mod
        end
    end,
    Remove = function(this)
        local move_speed = GetUnitMoveSpeed(this.owner.unit)
        move_speed = move_speed - this.last_move_mod
        SetUnitMoveSpeed(this.owner.unit, move_speed)
    end
}