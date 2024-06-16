Damage = {}
Damage.ATTACK_TYPE_NORMAL = 1 --普通攻击
Damage.ATTACK_TYPE_PROJECTIL = 2
Damage.ATTACK_TYPE_AOE = 4

Damage.DAMAGE_TYPE_NORMAL = 0
Damage.DAMAGE_TYPE_PURE = 1
Damage.DAMAGE_TYPE_DOT = 2 -- damage over time

Damage.ELEMENT_TYPE_NONE = 0

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
  o.atktype = atktype or Damage.ATTACK_TYPE_NORMAL
  o.dmgtype = dmgtype or Damage.DAMAGE_TYPE_NORMAL
  o.eletype = eletype or Damage.ELEMENT_TYPE_NONE
  return o
end

function Damage:PreApply()
  self.source:OnBeforeDealDamage(self)
  self.target:OnBeforeDamage(self)
end

function Damage:Apply()

  Damage.ApplyDirectDamage(self.target.unit, self.amount)
end

function Damage:Resolve()
  self:PreApply()
  self:Apply()
end