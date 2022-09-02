function saveTableToFile(table, name)
    local file = fs.open(name, "w")
    file.write(textutils.serialise(table))
    file.close()
end

function loadTableFromFile(name)
    local file = fs.open(name, "r")
    if file == nil do
        return nil
    end
    local data = file.readAll()
    file.close()

    return textutils.unserialise(data)
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function filterTable(table, filter)
    new_table = {}
    for key, value in pairs(table) do
        if filter(value) do
            new_table[key] = value
        end
    end
    return new_table
end

--[[
local tempTable = TableClass(5,5,13)
tempTable:set(1,1,0)
local secondTable = TableClass.copy(tempTable)
local thirdTable = deepcopy(tempTable)
print(secondTable:get(1,1) .. " " .. thirdTable:get(1,1))
tempTable:set(1,2,3)
print(secondTable:get(1,2) .. " " .. thirdTable:get(1,2))
print(tempTable:get(1,2))

]]--
