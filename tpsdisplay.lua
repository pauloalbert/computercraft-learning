os.loadAPI("apis/webJson")
local SAMPLETIME = 1
local monitorside = "right"

local monitor = peripheral.wrap(monitorside)
local lastTimeSample = nil
local timeSample = nil

local histogramTPS = {}

local function getWarningColor(tps)
   if tps > 20 then
       return colors.blue
   elseif tps >18 then
       return colors.lime
   elseif tps > 14 then
       return colors.green
   elseif tps > 11 then
       return colors.yellow
   elseif tps > 8 then
       return colors.orange
   else
       return colors.red
   end
       
end

local function printHistogram(resultstable)
    local x,y = monitor.getSize()
    
    for index, tps in pairs(resultstable) do
        local lx = x - 2*index
        local ly = y - 1
        monitor.setCursorPos(lx,ly)
        monitor.blit(" ",colors.black, getWarningColor(tps))
    end
end

--INIT--
monitor.setBackgroundColor(colors.black)
monitor.clear()

--PERIODIC--
local function periodic()
    lastTimeSample = webJson.getRealTime()
    sleep(SAMPLETIME)
    timeSample = webJson.getRealTime()
    local tps = SAMPLETIME*20/((timeSample-lastTimeSample)/10000000)
    
    monitor.setBackgroundColor(getWarningColor(tps))
    monitor.clear()
    local x,y = monitor.getSize()
    monitor.setCursorPos(x/2-1,y/4)
    monitor.setTextColor(colors.white)
    monitor.write(math.floor(100*tps)/100)
    
    monitor.setTextColor(colors.black)
    monitor.setCursorPos(x/2,y/4-1)
    monitor.write("TPS")
    
    table.insert(histogramTPS, tps)
    if #histogramTPS > 5 then
        table.remove(histogramTPS, 1)
    end
    if x >= 20 and y >= 10 then
        printHistogram(histogramTPS)
    end
end

while true do
    periodic()
end