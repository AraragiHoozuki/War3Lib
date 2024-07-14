UnitManager = {}
UnitManager.DummyCaster = FourCC('h003')
UnitManager.LuaUnits = {}
--[[
UnitManager.CreateUnit = function()
    local unit = CreateUnit()
    UnitManager.RegisterUnit(unit)
end
]]--

UnitManager.RegisterUnit = function(unit)
    local lu = LuaUnit:new(nil, unit)
    UnitManager.LuaUnits[unit] = lu
    return lu;
end

UnitManager.UnregisterUnit = function(unit)
    UnitManager.LuaUnits[unit] = nil
end

UnitManager.UnregisterLuaUnit = function(lu)
    UnitManager.LuaUnits[lu.unit] = nil
end

UnitManager.IsUnitRegistered = function(unit)
    return UnitManager.LuaUnits[unit] ~= nil
end

UnitManager.Update = function()
    for k,v in pairs(UnitManager.LuaUnits) do
        v:Update()
    end
end

UnitManager.DummySpellTarget = function(speller, target, abiId, level, order_string)
    local dummy = CreateUnit(GetOwningPlayer(speller), UnitManager.DummyCaster, GetUnitX(speller), GetUnitY(speller), 0)
    UnitApplyTimedLife(dummy, FourCC('BTLF'), 1)
    ShowUnit(dummy, false)
    UnitAddAbility(dummy, abiId)
    SetUnitAbilityLevel(dummy, abiId, level)
    IssueTargetOrder(dummy, order_string, target)
end

----------------------------------------------------------
--LuaUnit object
LuaUnit = {unit=nil}
LuaUnit.Get = function(unit)
    if (UnitManager.IsUnitRegistered(unit)) then
        return UnitManager.LuaUnits[unit]
    else
        return UnitManager.RegisterUnit(unit)
    end
end

function LuaUnit:new(o, unit)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.uuid = GUID.generate()
    o.unit = unit
    o.modifiers = {}
    o.hitHistory = {}
    o.atk_spd_modify = 0
    o.default_atk_interval = BlzGetUnitWeaponRealField(o.unit, UNIT_WEAPON_RF_ATTACK_BASE_COOLDOWN, 0)
    o.greeting = 'My name is '..GetUnitName(unit)
    return o
end

function LuaUnit:AttackSpeedModify(value_pct)
    self.atk_spd_modify = self.atk_spd_modify + value_pct
    local value = self.atk_spd_modify/100
    local interval_new = self.default_atk_interval/(1+value)
    BlzSetUnitWeaponRealField(self.unit, UNIT_WEAPON_RF_ATTACK_BASE_COOLDOWN, 0, interval_new)
end

function LuaUnit:Update()
    for k,v in pairs(self.modifiers) do
        v:Update()
    end
end

function LuaUnit:AcquireModifier(settings, lu_applier, bindAbility)
    local mod = Modifier.Create(self, settings, lu_applier, bindAbility)
    self:CheckModifierReapply(mod)
end
function LuaUnit:AcquireModifierById(mid, lu_applier, bindAbility)
    local mod = Modifier.CreateById(self, mid, lu_applier, bindAbility)
    self:CheckModifierReapply(mod)
end

function LuaUnit:ApplyModifier(settings, lu_target, bindAbility)
    local mod = Modifier.Create(lu_target, settings, self, bindAbility)
    lu_target:CheckModifierReapply(mod)
end
function LuaUnit:ApplyModifierById(mid, lu_target, bindAbility)
    local mod = Modifier.CreateById(lu_target, mid, self, bindAbility)
    lu_target:CheckModifierReapply(mod)
end

function LuaUnit:IsModifierTypeAffected(mid)
    for k,v in pairs(self.modifiers) do
        if v.id == mid then
            return true
        end
    end
    return false
end
function LuaUnit:GetAffectedModifier(mid)
    for _,v in pairs(self.modifiers) do
        if v.id == mid then
            return v
        end
    end
    return nil
end
function LuaUnit:GetAffectedModifierIndex(mid)
    for i,v in ipairs(self.modifiers) do
        if v.id == mid then
            return i
        end
    end
    return nil
end

function LuaUnit:CheckModifierReapply(m)
    local mod = self:GetAffectedModifier(m.id)
    if mod ~= nil then
        if m.reapply_mode == Modifier.REAPPLY_MODE_NO then
            return
        elseif m.reapply_mode == Modifier.REAPPLY_MODE_STACK then
            mod:AddStack(m.stack, false)
        elseif m.reapply_mode == Modifier.REAPPLY_MODE_REFRESH then
            mod:Refresh()
        elseif m.reapply_mode == Modifier.REAPPLY_MODE_STACK_AND_REFRESH then
            mod:AddStack(m.stack, true)
        elseif m.reapply_mode == Modifier.REAPPLY_MODE_COEXIST then
            table.insert(self.modifiers, m)
            m:OnAcquired()
        elseif m.reapply_mode == Modifier.REAPPLY_MODE_REMOVE_OLD then
            mod:Remove()
            table.insert(self.modifiers, m)
            m:OnAcquired()
        end
    else
        table.insert(self.modifiers, m)
        m:OnAcquired()
    end
end

function LuaUnit:AddTestModifier()
    self:AcquireModifier('MODIFIER_TEST')
end

function LuaUnit:RemoveModifier(mod)
    local index = IndexOf(self.modifiers, mod)
    self:RemoveModifierByIndex(index)
end
function LuaUnit:RemoveModifierById(mid)
    local index = self:GetAffectedModifierIndex(mid)
    self:RemoveModifierByIndex(index)
end
function LuaUnit:RemoveModifierByIndex(index)
    if index ~= nil then
        local mod = table.remove(self.modifiers, index)
        mod:OnRemoved()
    end
end


function LuaUnit:OnDeath()
    for _,m in pairs(self.modifiers) do
        m:OnDeath()
    end
end

function LuaUnit:OnBeforeDealDamage(damage)
    for _,m in pairs(self.modifiers) do
        m:OnBeforeDealDamage(damage)
    end
end
function LuaUnit:OnBeforeTakeDamage(damage)
    for _,m in pairs(self.modifiers) do
        m:OnBeforeTakeDamage(damage)
    end
end

function LuaUnit:OnDealDamage(damage)
    for _,m in pairs(self.modifiers) do
        m:OnDealDamage(damage)
    end
end
function LuaUnit:OnTakeDamage(damage)
    for _,m in pairs(self.modifiers) do
        m:OnTakeDamage(damage)
    end
end

-----------------------------------------------
-- Modifiers
Modifier = {}
Modifier.REAPPLY_MODE_NO = 0
Modifier.REAPPLY_MODE_STACK = 1
Modifier.REAPPLY_MODE_REFRESH = 2
Modifier.REAPPLY_MODE_STACK_AND_REFRESH = 3
Modifier.REAPPLY_MODE_COEXIST = 4
Modifier.REAPPLY_MODE_REMOVE_OLD = 5

Modifier.Create = function(lu_owner, settings, lu_applier, bindAbility)
    return Modifier:new(nil, lu_owner, settings, lu_applier, bindAbility)
end

Modifier.CreateById = function(lu_owner, mid, lu_applier, bindAbility)
    local settings = ModifierMaster[mid]
    return Modifier:new(nil, lu_owner, settings, lu_applier, bindAbility)
end

function Modifier:new(o, lu_owner, settings, lu_applier, bindAbility)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.settings = settings
    o.id = settings.id
    o.uuid = GUID.generate()
    o.ability = bindAbility or settings.BindAbility or nil
    o.applier = lu_applier or lu_owner
    o.owner = lu_owner
    o.interval = settings.interval or CoreTicker.Interval
    o.duration = settings.duration
    o.remove_on_death = settings.remove_on_death or true
    o.valid_when_death = settings.valid_when_death or false
    o.reapply_mode = settings.reapply_mode or Modifier.REAPPLY_MODE_NO
    o.stack = settings.stack or 1
    o.max_stack = settings.max_stack or 1
    o.bonitas = settings.bonitas or 0 --大于0表示正面效果，小于0表示负面效果 
    o.effects = {}
    o.effects_scale = 1
    o.delta_time = 0
    o.tags = {}
    if settings.tags then 
        for _,tag in ipairs(settings.tags) do
            table.insert(o.tags, tag)
        end
    end
    return o
end

function Modifier:GetLevel()
    if (self.ability == nil) then
        return 1
    else
        return GetUnitAbilityLevel(self.applier.unit, self.ability)
    end
end

function Modifier:GetLevelValue(key)
    local value = self.settings.LevelValues;
    if (value ~= nil) then value = value[key] end
    if (value ~= nil) then value = value[self:GetLevel()] end
    if (value ~= nil) then
        return value
    else
        return 0
    end
end
function Modifier:LV(key) return self:GetLevelValue(key) end

function Modifier:Refresh(refresh)
    self.duration = self.settings.duration
end

function Modifier:AddStack(value, refresh)
    if (self.stack < self.max_stack) then
        self.stack = self.stack + value
        if (self.stack > self.max_stack) then
            self.stack = self.max_stack
        end
    end
    if (refresh == true) then
        self:Refresh()
    end
end

function Modifier:Update()
    self.delta_time = self.delta_time + CoreTicker.Interval
    if (self.duration ~= -1) then
        self.duration = self.duration - CoreTicker.Interval
        if (self.duration < 0) then
            self:Remove()
        end
    end
    if (self.stack < 1) then
        self:Remove()
    end
    if (self.delta_time >= self.interval) then
        if (self.valid_when_death == true or IsUnitAliveBJ(self.owner.unit)) and (self.settings.Update ~= nil) then
            self.settings.Update(self) 
        end
        for _,efx in pairs(self.effects) do
            BlzSetSpecialEffectMatrixScale(efx, self.effects_scale,self.effects_scale,self.effects_scale)
        end
        self.delta_time = self.delta_time - self.interval
    end
end

function Modifier:Remove()
    self.owner:RemoveModifier(self)
end

function Modifier:OnDeath()
    if (self.remove_on_death == true) then
        self:Remove()
    end
end

function Modifier:OnAcquired()
    --create effects
    for k,v in pairs(self.settings.Effects) do
        local eff = AddSpecialEffectTarget(v.model, self.owner.unit, v.attach_point)
        table.insert(self.effects, eff)
    end
    if (self.settings.Acquire ~= nil) then self.settings.Acquire(self) end
end

function Modifier:OnRemoved()
    --destroy effects
    for k,v in pairs(self.effects) do
        DestroyEffect(v)
    end
    self.effects = {}
    if (self.settings.Remove ~= nil) then self.settings.Remove(self) end
end

function Modifier:OnBeforeTakeDamage(damage)
    if (self.settings.BeforeTakeDamage ~= nil) then self.settings.BeforeTakeDamage(self, damage) end
end
function Modifier:OnBeforeDealDamage(damage)
    if (self.settings.BeforeDealDamage ~= nil) then self.settings.BeforeDealDamage(self, damage) end
end

function Modifier:OnTakeDamage(damage)
    if (self.settings.TakeDamage ~= nil) then self.settings.TakeDamage(self, damage) end
end
function Modifier:OnDealDamage(damage)
    if (self.settings.DealDamage ~= nil) then self.settings.DealDamage(self, damage) end
end