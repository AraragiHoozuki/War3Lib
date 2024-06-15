ProjectilMaster={}
ProjectilMaster.UnitAttackProjectils = {
    --弓箭手 巫妖冰箭
    [FourCC('earc')] = { 
        model = 'h000',
        velocity = 500,
        track_unit = true,
        track_position = false,
        tracking_angle = 60 * Degree, -- if angle between bullet and target >= tracking angle, then stop tracking
        turning_speed = 60 * Degree, -- rad per second
        max_flying_distance = 1500,
        hit_other = false,
        hit_ally = true,
        hit_range = 25,
        offsetX = 11,
        offsetY = 62,
        offsetZ = 110,
        Hit = nil
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
        hit_range = 25,
        offsetX = 0,
        offsetY = 0,
        offsetZ = 100,
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
    
}