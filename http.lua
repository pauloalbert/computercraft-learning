local function getHttpHeader(url, query)
    local h = http.get(url)
 
    local char = "h"
    local i = 1
    while char ~= nil do
        char = h.read()
        if char == string.sub(query,i,i) then
            i = i+1
        else
            i=1
        end
        if i == #query + 1 then
            break
        end
    end
    
    local resultText = ""
    
    while char ~= "," and char ~= nil do
        char = h.read()
        if char ~= "," and char ~= nil then
        resultText = resultText .. char
        end
    end
    return resultText
end

local function getRealTime()
    local retVal = getHttpHeader("http://worldclockapi.com/api/json/utc/now", '\"currentFileTime\":')
    if retVal ~= "" then
        return tonumber(retVal) 
    end
end