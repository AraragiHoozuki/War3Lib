ProjectilMaster={}
ProjectilMaster.UnitAttackProjectils = {
    --弓箭手 巫妖冰箭
    [FourCC('earc')] = {
        model = 'Abilities\\Weapons\\LichMissile\\LichMissile.mdl', --子弹模型
        velocity = 900, --水平（XY轴）弹道速度
        velocityZ = 0, --Z轴初始速度
        velocityZMax = 9999, --最大Z轴速度绝对值
        no_gravity = false, --是否无视重力
        hit_range = 50, --命中检测范围（水平）
        hit_rangeZ = 60, --若为true,在命中判定时，会额外考虑子弹和目标的Z轴坐标
        hit_terrain = true, --是否命中地形（若是，子弹会被地面、高坡、悬崖等阻挡）
        hit_other = true, --是否能命中目标以外单位
        hit_ally = true, --是否能命中友军
        hit_piercing = false, --是否穿透（命中单位后继续飞行）
        hit_cooldown = 1, --同一单位命中间隔（仅对穿透弹道生效，防止同一个单位一直被判定命中）
        track_type = Projectil.TRACK_TYPE_UNIT, --追踪类型：无/追踪目标单位/追踪目标点
        trackZ = false, --是否Z轴追踪（根据目标高度调整子弹竖直方向速度）
        tracking_angle = 60 * Degree, --最大追踪角度角度（水平），当目标不在子弹前方该角度的扇形区域时，丢失追踪效果
        turning_speed = 60 * Degree, --最大转向速度（弧度/秒）
        max_flying_distance = 1500, --最大飞行距离
        offsetX = 11, --发射点偏移
        offsetY = 62,
        offsetZ = 71,
        Hit = nil --命中时额外调用函数
    },
    --吉安娜
    [FourCC('H004')] = {
        model = 'Abilities\\Weapons\\LichMissile\\LichMissile.mdl', --子弹模型
        velocity = 900, --水平（XY轴）弹道速度
        velocityZ = 0, --Z轴初始速度
        velocityZMax = 9999, --最大Z轴速度绝对值
        no_gravity = true, --是否无视重力
        hit_range = 50, --命中检测范围（水平）
        hit_rangeZ = 60, --若为true,在命中判定时，会额外考虑子弹和目标的Z轴坐标
        hit_terrain = true, --是否命中地形（若是，子弹会被地面、高坡、悬崖等阻挡）
        hit_other = false, --是否能命中目标以外单位
        hit_ally = false, --是否能命中友军
        hit_piercing = false, --是否穿透（命中单位后继续飞行）
        hit_cooldown = 1, --同一单位命中间隔（仅对穿透弹道生效，防止同一个单位一直被判定命中）
        track_type = Projectil.TRACK_TYPE_UNIT, --追踪类型：无/追踪目标单位/追踪目标点
        trackZ = true, --是否Z轴追踪（根据目标高度调整子弹竖直方向速度）
        tracking_angle = 60 * Degree, --最大追踪角度角度（水平），当目标不在子弹前方该角度的扇形区域时，丢失追踪效果
        turning_speed = 60 * Degree, --最大转向速度（弧度/秒）
        max_flying_distance = 1500, --最大飞行距离
        offsetX = 11, --发射点偏移
        offsetY = 62,
        offsetZ = 71,
        Hit = nil --命中时额外调用函数
    },
    -- 女猎手 
    [FourCC('esen')] = {
        model = 'Abilities\\Weapons\\SentinelMissile\\SentinelMissile.mdl',
        velocity = 900,
        velocityZ = 0,
        velocityZMax = 9999,
        no_gravity = false,
        hit_range = 60,
        hit_rangeZ = 40,
        hit_terrain = true,
        hit_other = true,
        hit_ally = false,
        hit_piercing = false,
        hit_cooldown = 1,
        track_type = Projectil.TRACK_TYPE_NONE,
        trackZ = false,
        tracking_angle = 60 * Degree,
        turning_speed = 60 * Degree,
        max_flying_distance = 1500,
        offsetX = 11,
        offsetY = 62,
        offsetZ = 71,
        Hit = nil
    },
    -- 奇美拉
    [FourCC('echm')] = {
        model = 'Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl',
        velocity = 1200,
        velocityZ = 0,
        velocityZMax = 999999,
        no_gravity = false,
        hit_range = 75,
        hit_rangeZ = 60,
        hit_terrain = true,
        hit_other = true,
        hit_ally = false,
        hit_piercing = false,
        hit_cooldown = 1,
        track_type = Projectil.TRACK_TYPE_NONE,
        trackZ = false,
        tracking_angle = 60 * Degree,
        turning_speed = 60 * Degree,
        max_flying_distance = 1500,
        offsetX = 10,
        offsetY = 105,
        offsetZ = -18,
        Hit = nil
    },
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