
TurtleController = {}
--[[
    Initialize the turtle controller.
    returnOnFuel: boolean, if true, turtle will return to a recharge station noting that it will have enough fuel
    returnOnFilled: boolean, if true, will return to base when inventory fills up
    saveExact: boolean, if true, store every move made, so that the turtle can retrace its own steps.
    [xs,ys,zs];; optional, ints, define initial position
    [direction];; optional, string, define original orientation of robot
]]--
function TurtleController.__init__ (returnOnFuel,returnOnFilled, saveExact, xs,ys,zs, direction)
    --nil handling?
    local self = {returning = false, FUEL_RETURNS = returnOnFuel, INV_RETURNS = returnOnFilled}
    if(zs ~= nil) then
        self.coords = vector.new(xs, ys, zs)
    else
        self.coords = vector.new(gps.locate())
        if self.coords.x == nil then
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
        if turtle.forward() then
            local endCoords = vector.new(gps.locate())
            self.direction = endCoords - startCoords
            self.coords:add(self.direction)
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
        forward = function(tc) tc.coords:add(tc.direction) end,
        back = function(tc) tc.coords:sub(tc.direction) end,
        up = function(tc) tc.coords:add(vector.new(0,1,0)) end,
        down = function(tc) tc.coords:add(vector.new(0,1,0)) end,
        turnLeft = function(tc) tc.direction = vector.new(-tc.direction.z,0,tc.direction.x) end,
        turnRight = function(tc) tc.direction = vector.new(tc.direction.z, 0, -tc.direction.x) end
    }
    local success = false
    
    if abbreviations[mCommand] then
        mCommand = abreviations[mCommand]
    end

    if not moveOdometry[mCommand] then
        print("INCOMPATIBLE COMMAND ".. mCommand)
        return
    end

    success = turtle[mCommand]() --runs turtle.mCommand()
    if success and self:direction ~= nil then
        moveOdometry[mCommand](self)
    end
    return success
end

function TurtleController:face(vec)
    for i=0,3 do
        if vec == self.direction then
            return true   
        end
        self:move("turnRight")
    end
    print("INVALID INPUT VECTOR")
    return false
end

local directionConversions = {['1,0,0'] = {name = "east", angle = 90, vector = vector.new(1,0,0)}, 
                              ['0,0,-1'] = {name = "south", angle = 180, vector = vector.new(0,0,-1)},
                              ['-1,0,0'] = {name="west", angle = 270, vector = vector.new(-1,0,0)}, 
                              ['0,0,1'] = {name = "north", angle = 0, vector = vector.new(0,0,1)}
                        }

function TurtleController.orientationToString(directionVector)
    return directionConversions[directionVector.tostring()].name
end

function TurtleController.orientationToDegrees(directionVector)
    return directionConversions[directionVector.tostring()].angle
end

--[[Converts cardinal direction names ("east"), angles (270), and vector strings ([-1,0,0]) to valid vector.]]--
function TurtleController.ValueToOrientation(directionValue)
    if directionConversions[directionValue] ~= null do return directionConversions[directionValue].vector end
    if type(directionValue) == 'number' do directionValue = (directionValue + 360 ) % 360  end --Make sure angles range between 0-360
    
    for direction, conversion in pairs(directionConversions) do
        if conversion.angle == directionValue or conversion.name == directionValue do
            return directionConversions[direction].vector
        end
    end
    return nil  --Incase of invalid input, return nil
end

function TurtleController:importOrientation(direction)
    if not direction then
        return false
    end
    elseif type(direction) == 'string' then    

    end
function TurtleController:

setmetatable(TurtleController, {__call=TurtleController.__init__})
