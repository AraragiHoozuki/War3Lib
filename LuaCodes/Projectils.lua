ProjectilMaster={}
ProjectilMaster.UnitAttackProjectils = {
    [FourCC('earc')] = {
        model = 'h000',
        velocity = 500,
        track_unit = true,
        track_position = false,
        tracking_angle = 60 * Degree, -- if angle between bullet and target >= tracking angle, then stop tracking
        turning_speed = 60 * Degree, -- rad per second
        max_flying_distance = 1500,
        hit_other = true,
        hit_ally = false,
        hit_range = 25,
        offsetX = 11,
        offsetY = 62,
        offsetZ = 110,
        Hit = function(this, lu_target)
            local src = this.emitter
            local tgt = lu_target
            local life = GetWidgetLife(tgt.unit)
            SetWidgetLife(tgt.unit, life - 10)
        end
    }
}