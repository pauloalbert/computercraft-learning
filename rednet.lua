local wifiSide = "right"
local _ID_ = os.getComputerID()
rednet.open(wifiSide)

while true do
    rednet.send(id, "Recieved")
    
    os.queueEvent("randomEvent")
    os.pullEvent()
end

