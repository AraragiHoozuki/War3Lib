MapObjectMgr = {}
MapObjectMgr.Objects = {}

MapObjectMgr.Update = function()
    for k,obj in pairs(MapObjectMgr.Objects) do
        if obj ~= nil then
            obj:Update()
            if (obj.ended == true) then
                MapObjectMgr.Objects[k] = nil
                obj:Destroy()
            end
        end
	end
end

MapObjectMgr.Create = function(lu_creator, position, model, duration, awake_handlers)
    local obj = MapObject:new(nil, lu_creator, position, model, duration, awake_handlers)
    MapObjectMgr.Objects[obj.uuid] = obj
    return obj
end

--------------------------------------------------------

MapObject={}
MapObject.tempLoc = Location(0, 0)

function MapObject:new(o, lu_creator, position, model, duration, awake_handlers)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.uuid = GUID.generate()
    o.creator = lu_creator
    o.position = position
    o.model = model
    o.duration = duration
    o.effect = nil
    o.awake_handlers = awake_handlers or {}
    o.update_handlers = {}
    o.remove_handlers = {}
    o.ended = false
    --init Z
    MoveLocation(MapObject.tempLoc, o.position.x, o.position.y)
    o.position.z = GetLocationZ(MapObject.tempLoc) + o.position.z
    o:CreateModel()
    o:Awake()
    return o
end

function MapObject:AddUpdateHandler(func)
    table.insert(self.update_handlers, func)
end
function MapObject:AddDestroyHandler(func)
    table.insert(self.remove_handlers, func)
end
function MapObject:CreateModel()
    if (self.model ~= nil) then
        self.effect = AddSpecialEffect(self.model, self.position.x, self.position.y)
        BlzSetSpecialEffectZ(self.effect, self.position.z)
    end
end
function MapObject:Update()
    for _,h in pairs(self.update_handlers) do
        h(self)
    end
    if (self.duration ~= -1) then
        self.duration = self.duration - CoreTicker.Interval
        if (self.duration < 0) then
            self.ended = true
        end
    end
end
function MapObject:Awake()
    for _,h in pairs(self.awake_handlers) do
        h(self)
    end
end
function MapObject:Destroy()
    if (self.effect ~= nil) then
        DestroyEffect(self.effect)
    end
    for _,h in pairs(self.remove_handlers) do
        h(self)
    end
end