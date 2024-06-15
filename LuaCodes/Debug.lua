Debug = {}
Debug.On = false
Debug.Log = function(s)
    print(s)
end

Debug.LogInfo = function(info)
    if (Debug.On == true) then
        print('[Info] ', info)
    end
end