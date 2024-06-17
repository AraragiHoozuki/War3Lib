--冰墙
AbilitySystem.ICE_WALL = {
    IceBlockSize = 64,
}
AbilitySystem.ICE_WALL.Cast = function()
    local lu_caster = LuaUnit.Get(GetTriggerUnit())
    local x0 = GetUnitX(lu_caster.unit)
    local y0 = GetUnitY(lu_caster.unit)
    local x = GetSpellTargetX()
    local y = GetSpellTargetY()
    local lv = GetUnitAbilityLevel(lu_caster.unit, GetSpellAbilityId())

    local alpha = math.atan(y-y0, x-x0)
    local dx = AbilitySystem.ICE_WALL.IceBlockSize * Cos(math.pi/2 - alpha)
    local dy = - AbilitySystem.ICE_WALL.IceBlockSize * Sin(math.pi/2 - alpha)
    for i = -9, 9 do
        local ice = MapObjectMgr.Create(lu_caster, Vector3:new(nil, x+i*dx,y+i*dy,0), 'Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathTargetArt.mdl', 15, 
            {function(this)
                SetTerrainPathable(this.position.x, this.position.y, PATHING_TYPE_WALKABILITY, false)
            end}
        )
        ice:AddDestroyHandler(function(this) 
            SetTerrainPathable(this.position.x, this.position.y, PATHING_TYPE_WALKABILITY, true)
        end)
        ice:AddUpdateHandler(function(this)
            for _,prjt in pairs(ProjectilMgr.Projectils) do
                if (this.position:Distance(prjt.position.x, prjt.position.y) < AbilitySystem.ICE_WALL.IceBlockSize and
                    prjt.position.z - this.position.z < 140) then
                    prjt.ended = true
                end
            end
        end)
    end
end