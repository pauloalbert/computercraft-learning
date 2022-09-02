
TurtleController = {}
function TurtleController.__init__ (returnOnFuel,returnOnFilled, saveExact, xs,ys,zs, direction)
    --nil handling?
    local self = {returning = false, FUEL_RETURNS = returnOnFuel, INV_RETURNS = returnOnFilled}
    if(zs ~= nil) then
        self.coords = vector.new(xs, ys, zs)
    else then
        self.coords = vector.new(gps.locate())
        if self.coords.x == nil do
            print("COULD NOT GET COORDINATES")
            self.coords = vector.new(0,0,0)
        end
    end
    self.direction = direction
    setmetatable (self, {__index=TurtleController})
    return self
end

function TurtleController:calibrateOrientation()
    local startCoords = vector.new(gps.locate())
    for i=0,3 do
        if turtle.forward() do
            local endCoords = vector.new(gps.locate())
            self.direction = endCoords - startCoords
            tc.coords:add(tc.direction)
            return true
        end
        turtle.turnRight()
    end
    print("CANT MOVE")
    return false
end

function TurtleController:move(mCommand)
    local abbreviations = {f = "forward", u = "up", d="down", tl ="turnLeft", tr = "turnRight", b = "back"} 
    local moveOdometry = {
        "forward" = function(tc) tc.coords:add(tc.direction) end,
        "back" = function(tc) tc.coords:sub(tc.direction) end,
        "up" = function(tc) tc.coords:add(vector.new(0,1,0)) end,
        "down" = function(tc) tc.coords:add(vector.new(0,1,0)) end,
        "turnLeft" = function(tc) tc.direction = vector.new(-tc.direction.z,0,tc.direction.x) end,
        "turnRight" = function(tc) tc.direction = vector.new(tc.direction.z, 0, -tc.direction.x) end
    }
    local success = false
    
    if abbreviations[mCommand] then
        mCommand = abreviations[mCommand]
    end

    if not moveActions[mCommand] then
        print("INCOMPATIBLE COMMAND ".. mCommand)
        return
    end

    success = turtle[mCommand]() --runs turtle.mCommand()
    if success then
        moveOdometry[mCommand](self)
    end
    return success
end

function TurtleController:face(vec)
    for i=0,3 do
        if vec == self.direction do
            return true   
        end
        self:move("turnRight")
    end
    print("INVALID INPUT VECTOR")
    return false
end

function TurtleController:orientationToString()
    local directionNames = {"1,0,0" = "east", "0,0,-1" = "south", "-1,0,0" = "west", "0,0,1" = "north"}
    return directionNames[self.direction.tostring()]
end

function TurtleController:orientationToDegrees()
    local directionNumbers = {"1,0,0" = 90, "0,0,-1" = 180, "-1,0,0" = 270, "0,0,1" = 0}
    return directionNumbers[self.direction.tostring()]
end

function goto

setmetatable(TurtleController, {__call=TurtleController.__init__})
