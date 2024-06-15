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
function TableContain(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
end
-- Math -----------------------------------------------------
Degree = math.pi / 180
AngleDiff = function(r1, r2)
    local d = r2 - r1
    --[[
    while (d > math.pi) do
        d = d - 2 * math.pi
    end
    while (d < -math.pi) do
        d = d + 2 * math.pi
    end
    ]]--
    if (d > math.pi) then d = d - 2 * math.pi
    elseif (d < - math.pi) then d = d + 2 * math.pi
    end
    return d
end
-- DND x d y
math.dice = function(x, y)
    local result = 0
    for i = 1, x do
        result = result + math.random(y)
    end
    return result
end

-- Vector2 ----------------------------------------------------
Vector2 = {x=0, y=0}

function Vector2:new(o, x, y)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.x = x
    o.y = y
    return o
end

function Vector2:Distance(x, y)
    return math.sqrt((x - self.x)^2 + (y - self.y)^2)
end