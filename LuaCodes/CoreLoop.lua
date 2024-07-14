CoreTicker = {}
CoreTicker._timer = CreateTimer()
CoreTicker._stamp = 0
CoreTicker.Interval = 1/60
CoreTicker.DelayedActions = {}
CoreTicker.Init = function()
    TimerStart(CoreTicker._timer, CoreTicker.Interval, true, CoreTicker.Tick)
end

CoreTicker.Tick = function()
    CoreTicker._stamp = CoreTicker._stamp + 1
    UnitManager.Update()
    ProjectilMgr.Update()
    MapObjectMgr.Update()
    CoreTicker.DoDelayedActions()
end

CoreTicker.RegisterDelayedAction = function(action, delay_time)
    local target_stamp = math.floor(CoreTicker._stamp + delay_time/CoreTicker.Interval)
    if (CoreTicker.DelayedActions[target_stamp] == nil) then
        CoreTicker.DelayedActions[target_stamp] = {}
    end
    table.insert(CoreTicker.DelayedActions[target_stamp], action)
end

CoreTicker.DoDelayedActions = function()
    local actions = CoreTicker.DelayedActions[CoreTicker._stamp]
    if (actions ~= nil) then
        for _,act in ipairs(actions) do
            act()
        end
        CoreTicker.DelayedActions[CoreTicker._stamp] = nil
    end
    
end

GameConstants = {
    Gravity = 600
}