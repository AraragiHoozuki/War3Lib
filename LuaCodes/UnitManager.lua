UnitManager = {}
UnitManager.LuaUnits = {};
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
    o.unit = unit
    o.modifiers = {}
    o.greeting = 'My name is '..GetUnitName(unit)
    return o
end

function LuaUnit:Update()
    for k,v in pairs(self.modifiers) do
        v:Update()
    end
end

function LuaUnit:AcquireModifier(mid)
    local mod = Modifier:new(nil, self, mid)
    table.insert(self.modifiers, mod)
    mod:OnAcquired()
end

function LuaUnit:AddTestModifier()
    print(self.greeting)
    self:AcquireModifier('MODIFIER_TEST')
end

function LuaUnit:RemoveModifier(mod)
    local index = IndexOf(self.modifiers, mod)
    self:RemoveModifierByIndex(index)
end
function LuaUnit:RemoveModifierByIndex(index)
    local mod = table.remove(self.modifiers, index)
    mod:OnRemoved()
end
function LuaUnit:RemoveModifierById()

end
-----------------------------------------------
-- Modifiers
Modifier = {owner = nil}


function Modifier:new(o, owner, mid)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local data = ModifierMaster[mid]
    o.data = data
    o.owner = owner
    o.interval = data.interval
    o.duration = data.duration
    o.effects = {}
    o.delta_time = 0
    return o
end

function Modifier:Update()
    self.delta_time = self.delta_time + CoreTicker.Interval
    if (self.delta_time >= self.interval) then
        self.data.Update(self)
        self.delta_time = self.delta_time - self.interval
    end
    if (self.duration ~= -1) then
        self.duration = self.duration - CoreTicker.Interval
        if (self.duration < 0) then
            self:Remove()
        end
    end
end

function Modifier:Remove()
    self.owner:RemoveModifier(self)
end

function Modifier:OnAcquired()
    --create effects
    for k,v in pairs(self.data.Effects) do
        local eff = AddSpecialEffectTarget(v.model, self.owner.unit, v.attach_point)
        table.insert(self.effects, eff)
    end
end

function Modifier:OnRemoved()
    --destroy effects
    for k,v in pairs(self.effects) do
        DestroyEffect(v)
    end
    self.effects = {}
end