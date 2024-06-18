Damage = {}
Damage.ATTACK_TYPE_UNKNOWN = 0
Damage.ATTACK_TYPE_MELEE = 1 --近战攻击
Damage.ATTACK_TYPE_PROJECTIL = 2 --弹道攻击
Damage.ATTACK_TYPE_AOE = 4

Damage.DAMAGE_TYPE_NORMAL = 0
Damage.DAMAGE_TYPE_PURE = 1
Damage.DAMAGE_TYPE_DOT = 2 -- damage over time

Damage.ELEMENT_TYPE_NONE = 0
Damage.ELEMENT_TYPE_THERMO = 0 --热
Damage.ELEMENT_TYPE_KRYO = 0 --冷

Damage.CONTROL_TYPE_SET = 0
Damage.CONTROL_TYPE_CAPTION_MAX = 1
Damage.CONTROL_TYPE_CAPTION_MIN = 2
Damage.CONTROL_TYPE_ADD_BEFORE_RATE = 3
Damage.CONTROL_TYPE_RATE = 4
Damage.CONTROL_TYPE_ADD_AFTER_RATE = 5


Damage.ApplyDirectDamage = function(targetUnit, amount)
    local life = GetWidgetLife(targetUnit)
    SetWidgetLife(targetUnit, life - amount)
end
-------------------------------------------------------------------------------

function Damage:new(o, lu_source, lu_target, amount, atktype, dmgtype, eletype)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.source = lu_source
  o.target = lu_target
  o.amount = amount
  o.amount_before_control = amount
  o.atktype = atktype or Damage.ATTACK_TYPE_NORMAL
  o.dmgtype = dmgtype or Damage.DAMAGE_TYPE_NORMAL
  o.eletype = eletype or Damage.ELEMENT_TYPE_NONE
  --controls
  o.control_set = nil
  o.control_caption_max = nil
  o.control_caption_min = 0
  o.control_add_before = nil
  o.control_rate = nil
  o.control_add_after = nil
  return o
end

function Damage:PreApply()
  self.source:OnBeforeDealDamage(self)
  self.target:OnBeforeTakeDamage(self)
end

function Damage:Control()
  self.amount_before_control = self.amount
  local amt = self.amount
  if (self.control_add_before ~= nil) then
    amt = amt + self.control_add_before
  end
  if (self.control_rate ~= nil) then
    amt = amt + amt*self.control_rate/100
  end
  if (self.control_add_after ~= nil) then
    amt = amt + self.control_add_after
  end
  if (self.control_set ~= nil) then
    amt = self.control_set
  end
  if (self.control_caption_max ~= nil) then
    amt = math.min(amt, self.control_caption_max)
  end
  if (self.control_caption_min ~= nil) then
    amt = math.max(amt, self.control_caption_min)
  end
  self.amount = amt
end

function Damage:Apply()

  Damage.ApplyDirectDamage(self.target.unit, self.amount)
  self.source:OnDealDamage(self)
  self.target:OnTakeDamage(self)
end

function Damage:Resolve()
  self:PreApply()
  self:Control()
  self:Apply()
end