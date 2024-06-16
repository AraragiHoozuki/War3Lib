ProjectilMaster={}
ProjectilMaster.UnitAttackProjectils = {
    --弓箭手 巫妖冰箭
    [FourCC('earc')] = {
        model = 'h000', --马甲模型
        velocity = 500, --弹道速度
        track_unit = true, --是否跟踪目标
        track_position = false, --是否跟踪地点
        tracking_angle = 60 * Degree, --最大跟踪角度
        turning_speed = 60 * Degree, --转向速度
        max_flying_distance = 1500, --最大飞行距离
        hit_other = false, --是否能命中目标以外单位
        hit_ally = true, --是否能命中友军
        hit_piercing = false, --是否穿透（命中后继续飞行）
        hit_cooldown = 1, --同一单位命中间隔（仅对穿透弹道生效，防止同一个单位一直被判定命中）
        hit_range = 25, --命中检测范围
        offsetX = 11, --发射点偏移
        offsetY = 62,
        offsetZ = 25,
        Hit = nil --命中时调用函数
    },
    --吉安娜
    [FourCC('H004')] = {
        model = 'h000', --马甲模型
        velocity = 700, --弹道速度
        track_unit = true, --是否跟踪目标
        track_position = false, --是否跟踪地点
        tracking_angle = 60 * Degree, --最大跟踪角度
        turning_speed = 90 * Degree, --转向速度
        max_flying_distance = 1500, --最大飞行距离
        hit_other = false, --是否能命中目标以外单位
        hit_ally = true, --是否能命中友军
        hit_piercing = false, --是否穿透（命中后继续飞行）
        hit_cooldown = 1, --同一单位命中间隔（仅对穿透弹道生效，防止同一个单位一直被判定命中）
        hit_range = 25, --命中检测范围
        offsetX = 15, --发射点偏移
        offsetY = 20,
        offsetZ = 66,
        Hit = nil --命中时调用函数
    },
    -- 女猎手 
    [FourCC('esen')] = {
        model = 'h001',
        velocity = 900,
        track_unit = false,
        track_position = false,
        tracking_angle = 60 * Degree,
        turning_speed = 90 * Degree,
        max_flying_distance = 1500,
        hit_other = true,
        hit_ally = false,
        hit_piercing = false,
        hit_cooldown = 0,
        hit_range = 40,
        offsetX = 0,
        offsetY = 0,
        offsetZ = 10,
        Hit = nil
    },
    -- 火枪手 
    [FourCC('hrif')] = {
        model = 'h002',
        velocity = 4500,
        track_unit = true,
        track_position = false,
        tracking_angle = 45 * Degree,
        turning_speed = 30 * Degree,
        max_flying_distance = 2000,
        hit_other = false,
        hit_ally = true,
        hit_range = 25,
        offsetX = 0,
        offsetY = 0,
        offsetZ = 60,
        Hit = nil
    }
}

ProjectilMaster.AbilityProjectils = {
    FireBall = {
        model = 'h003',
        velocity = 2000,
        track_unit = false,
        track_position = true,
        tracking_angle = 60 * Degree,
        turning_speed = 60 * Degree,
        max_flying_distance = 3000,
        hit_other = true,
        hit_ally = true,
        hit_piercing = false,
        hit_cooldown = 1,
        hit_range = 40,
        offsetX = 0,
        offsetY = 50,
        offsetZ = 0,
        LevelValues = {
            ExplodeDamageRange = {300, 300, 300, 300},
            ExplodeDamage = {100, 200, 300, 400}
        },
        Hit = function(this)
            local cond = Condition(function()
                return not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
            end)
            DestroyEffect(AddSpecialEffect('Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl',this.position.x, this.position.y))
            local g = CreateGroup()
            GroupEnumUnitsInRange(g, this.position.x, this.position.y, this:LV('ExplodeDamageRange'), cond)
            ForGroup(g, function()
                local u = GetEnumUnit()
                local dmg = Damage:new(nil, this.emitter, LuaUnit.Get(u), this:LV('ExplodeDamage'), Damage.ATTACK_TYPE_, Damage.DAMAGE_TYPE_NORMAL, Damage.ELEMENT_TYPE_NONE)
                dmg:Resolve()
            end)
            DestroyGroup(g)
        end
    },
}