
local bWidth, bHeight, bSpace = 3, 3, 1
local termX, termY = term.getSize()
local arrowCenter = {termX/2, termY/2}
local buttons = {leftButton = window.create(term.current() ,arrowCenter[1]-bWidth-bSpace ,arrowCenter[2] ,bWidth, bHeight),
rightButton = window.create(term.current(),arrowCenter[1]+bWidth+bSpace ,arrowCenter[2] ,bWidth, bHeight),
upButton = window.create(term.current(), arrowCenter[1] ,arrowCenter[2] - bWidth - bSpace, bWidth, bHeight),
downButton = window.create(term.current(), arrowCenter[1], arrowCenter[2] + bWidth + bSpace, bWidth, bHeight),
ascendButton = window.create(term.current(), termX-bWidth-1, arrowCenter[2] - bHeight, bWidth, bHeight),
descendButton = window.create(term.current(), termX-bWidth-1, arrowCenter[2] + 1, bWidth,bHeight)
}

local buttonAscii = {leftButton = '\27',
rightButton = '\26',
upButton = '\24',
downButton = '\25',
ascendButton = '\30',
descendButton = '\31'}

local buttonFunctions = {leftButton = "left",
rightButton = "right",
upButton = "forward",
downButton = "down",
ascendButton = "up",
descendButton = "down"}

local function miniPixel(topLeft, topRight, midLeft, midRight, botLeft, botRight, mainColor, bgColor)
    local char = 0
    if topLeft then char = char + 1 end
    if topRight then char = char + 2 end
    if midLeft then char = char + 4 end
    if midRight then char = char + 8 end
    if botLeft then char = char + 16 end
    if botRight then return string.char(159 - char), bgColor, mainColor end
    return string.char(128 + char), mainColor, bgColor
end

local function miniPixelBlit(window, topLeft, topRight, midLeft, midRight, botLeft, botRight, mainColor, bgColor, cx, cy)
    if window == nil then return end
    window.setCursorPos(cx, cy)
    local ch, mainC, bgC = miniPixel(topLeft, topRight, midLeft, midRight, botLeft, botRight, mainColor, bgColor)
    window.setBackgroundColor(bgC)
    window.setTextColor(mainC)
    window.write(ch)
     
end

local function drawButton(button, mainColor, accentColor, symbolColor, ascii)
    button.setBackgroundColor(colors[mainColor])
    button.setTextColor(colors[accentColor])
    button.getSize()
    button.clear()
    local bx, by = button.getSize()
    for y = 1, by do
        button.setCursorPos(1,y)
        button.write(miniPixel(true, false, true, false, true, false, colors[mainColor]), colors[accentColor])

    end
    for x=2,bx do
        button.setBackgroundColor(colors[accentColor])
        button.setTextColor(colors[mainColor])
        button.write(miniPixel(false,false,false,false,true,true,colors[accentColor]), colors[mainColor])

    end

    miniPixelBlit(button,true,false,true,false,true,true,colors[accentColor],colors[mainColor],1,by)

    button.setCursorPos(bx/2+1, (by+1)/2)
    button.setTextColor(colors[symbolColor])
    button.setBackgroundColor(colors[mainColor])
    button.write(ascii)
end

local function resetGUI()
    term.setBackgroundColor(colors.black)
    term.clear()
    for name, button in pairs(buttons) do
        drawButton(button, "white", "gray", "black", buttonAscii[name])
    end
end

resetGUI()
rednet.open("back")
local buttonTimers = {}
while true do
    local event, param1, x, y = os.pullEvent()
    if event == "mouse_click" then
        for name, button in pairs(buttons) do
            
            term.setTextColor(colors.white)
            
            local bx, by = button.getPosition()
            local bsx, bsy = button.getSize()
        
            if x >= bx and y >= by-0.5 and x < bx+bsx and y < by+bsy-0.5 then
                
                rednet.broadcast(buttonFunctions[name], "remote-turtle")
                term.setCursorPos(1,1)
                term.write(name)
                button.clear()
                sleep(0.05)
                drawButton(button, "lightGray", "gray", "black", buttonAscii[name])
                --button.clear()
                buttonTimers[name] = os.startTimer(0.5)
            end
        end
    elseif event == "timer" then
        local targetName = nil
        for name, id in pairs(buttonTimers) do
            if id == param1 then targetName = name end
        end
        if targetName ~= nil then
            drawButton(buttons[targetName], "white", "gray", "black", buttonAscii[targetName])
            buttonTimers[targetName] = nil --useful?
        end
    end
end