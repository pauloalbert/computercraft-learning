upGearSide = "left"
downGearSide = "right"

topButtonMoveSide = "front"
bottomButtonMoveSide = "back"

topButtonCallSide = "bottom"
bottomButtonCallSide = "top"

function resetAllRedstone()
    for num, side in pairs(rs.getSides()) do
        rs.setOutput(side, false)
    end
end

function stopElevator()
    redstone.setOutput(upGearSide, false)
    redstone.setOutput(downGearSide, false)
    sleep(0.2)
end
function moveElevatorUp()
    stopElevator()
    rs.setOutput(upGearSide, true)
    sleep(1)
end

function moveElevatorDown()
    stopElevator()
    rs.setOutput(downGearSide, true)
    sleep(1) --tempFix from .1, see *1 at bottom
end

--
--PERIODIC:
--

function periodic()
    if rs.getInput(topButtonMoveSide) or
           rs.getInput(bottomButtonCallSide) then

        moveElevatorDown()

    elseif rs.getInput(bottomButtonMoveSide) or
            rs.getInput(topButtonCallSide) then

        moveElevatorUp()
    end
end

--
--INIT:
--

resetAllRedstone()
while true do
    periodic()
end

--[[
*1 if the input is 1sec the elevator will repeatedly "change directions"
upwards only.
I'd fix this by:
    A) boolean/int for the current elevator direction
    B) until released booleans for all 4 buttons...
]]--

    