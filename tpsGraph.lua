--WEBJSON "API"
webJson = {}
function webJson:getHttpHeader(url, query)
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

function webJson:getRealTime()
    local retVal = webJson:getHttpHeader("http://worldclockapi.com/api/json/utc/now", '\"currentFileTime\":')
    if retVal ~= "" then
        return tonumber(retVal) 
    end
end

--WEBJSON END

local SAMPLETIME = 3

local monitor = peripheral.find("monitor")
if monitor == nil then
	monitor = term.current()
end

local lastTimeSample = nil
local timeSample = nil

local histogramTPS = {}

local function colorass(c,bw)
    return monitor.isColor() and c or bw
end

local function getWarningColor(tps)
   if tps > 20 then
       return colors.blue, 0
   elseif tps >18 then
       return colors.lime, 5
   elseif tps > 14 then
       return colors.green, 4
   elseif tps > 11 then
       return colors.yellow, 3
   elseif tps > 8 then
       return colors.orange, 2
   else
       return colors.red, 1
   end
       
end

local function printHistogram(resultstable)
    local x,y = monitor.getSize()
    for index, tps in pairs(resultstable) do
        local color, height = getWarningColor(tps)
        color = colorass(color,colors.white)
        local lx = x + 2*index -2*#resultstable - 2
        local ly = y - 1
        for i = 1, height do
            monitor.setCursorPos(lx,y-i)
            monitor.setBackgroundColor(color)
            monitor.write(" ")
        end
    end
end

--INIT--
monitor.setBackgroundColor(colorass(colors.blue,colors.black))
monitor.clear()
monitor.setTextColor(colorass(colors.black,colors.white))
monitor.setCursorPos(monitor.getSize(),1)
monitor.write("Waiting for estimation..")

--PERIODIC--
local function periodic()
    lastTimeSample = webJson.getRealTime()
    sleep(SAMPLETIME)
    timeSample = webJson.getRealTime()
    local tps = SAMPLETIME*20/((timeSample-lastTimeSample)/10000000)
    
    monitor.setBackgroundColor(colorass(colors.blue,colors.black))
    local x,y = monitor.getSize()
    monitor.setTextColor(colorass(getWarningColor(tps),colors.white))
    local doBarGraph = x >= 20 and y>= 10
    if not doBarGraph then
        monitor.setBackgroundColor(colorass(getWarningColor(tps),colors.white))
        monitor.setTextColor(colors.white)
    end
    monitor.clear()
    monitor.setCursorPos(x/2-1,y/4)
    monitor.write(math.floor(100*tps)/100)
    
    monitor.setTextColor(colorass(colors.black,colors.white))
    monitor.setCursorPos(x/2,y/4-1)
    monitor.write("TPS")
    
    table.insert(histogramTPS, tps)
    if #histogramTPS > 7 then
        table.remove(histogramTPS, 1)
    end
    if doBarGraph then
        printHistogram(histogramTPS)
    end
end

while true do
    periodic()
end