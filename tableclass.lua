TableClass = {data={}}
function TableClass.__init__ (baseClass, width, height, init_val)
    local self = {data={}}
    self["width"] = width
    self["height"] = height
    for i = 1,width do
        self.data[i] = {}
        for j = 1,height do
            self.data[i][j] = init_val
        end
    end

    setmetatable (self, {__index=TableClass})
    return self
end

function TableClass:get (x, y)
    return self.data[x][y]
end

function TableClass:set (x, y, newval)
    self.data[x][y] = newval
end

function TableClass:getDimensions()
    return self["width"], self["height"]
end

setmetatable(TableClass, {__call=TableClass.__init__})

--[[function TableClass.copy(table)
local self = {data={}}
self["width"] = table["width"]
self["height"] = table["height"]
for i=1,table["width"] do
    self.data[i] = {}
    for j = 1,table["height"] do
        self.data[i][j] = table.data[i][j]  --might copy reference to other object!!!!
    end
end
setmetatable (self, {__index=TableClass})
return self
end]]--