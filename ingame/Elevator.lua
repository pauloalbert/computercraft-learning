upGearSide = "left"
downGearSide = "right"
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
