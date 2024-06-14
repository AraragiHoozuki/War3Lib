CoreTicker = {}
CoreTicker._timer = CreateTimer()
CoreTicker._stamp = 0
CoreTicker.Interval = 1/60
CoreTicker.Init = function()
    TimerStart(CoreTicker._timer, CoreTicker.Interval, true, CoreTicker.Tick)
end

CoreTicker.Tick = function()
    CoreTicker._stamp = CoreTicker._stamp + 1
    UnitManager.Update()
    ProjectilMgr.Update()
end