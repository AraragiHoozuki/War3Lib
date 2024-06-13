-- table extend
function KeyOf(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
    return nil
end
function IndexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end
function TableCount(t)
    local leng=0
    for k, v in pairs(t) do
      leng=leng+1
    end
    return leng;
end
function PrintTable(t)
    print('-------------start ', t, '----------------')
    for k, v in pairs(t) do
      print(k, ':', v)
    end
    print('--------------end----------------')
end

Vector2 = {x=0, y=0}

function Vector2:new(o, x, y)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.x = x
    o.y = y
    return o
end