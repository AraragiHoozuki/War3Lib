AbilitySystem.StarPick = function()
    local lu = LuaUnit.Get(GetTriggerUnit())
    local x = GetUnitX(lu.unit)
    local y = GetUnitY(lu.unit)
    for k,prjt in pairs(ProjectilMgr.Projectils) do
        local dis = prjt.position:Distance(x, y)
        if (dis <= 150) then
            prjt.target_unit = prjt.emitter.unit
            prjt.emitter = lu
            prjt.track_unit = true
            prjt.tracking_angle = 2 * math.pi
            prjt.max_flying_distance = prjt.max_flying_distance + 10000
            prjt.hit_other = false
            prjt.hit_ally = true
            local dx = GetUnitX(prjt.target_unit) - GetUnitX(prjt.bullet)
            local dy = GetUnitY(prjt.target_unit) - GetUnitY(prjt.bullet)
            prjt.angle = math.atan(dy, dx)
            DestroyEffect(AddSpecialEffect('Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl',prjt.position.x, prjt.position.y))
            break
        end
    end
end