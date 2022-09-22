local VERBOSE = false
function debugPrint(input)
    if VERBOSE then
        print(input)
    end
end
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
            debugPrint("COULD NOT GET COORDINATES FROM GPS")
            self.coords = vector.new(0,0,0)
        end
    end
    direction = TurtleController.valueToOrientation(direction)
    if direction ~= nil then
        self.direction = direction
    else
        if not self:calibrateOrientation() then
            debugPrint("COULD NOT GET COORDINATES FROM GPS")
        end
    end

    self.home = self.coords
    setmetatable (self, {__index=TurtleController})
    return self
end

function TurtleController:calibrateOrientation()
    local startCoords = vector.new(gps.locate())
    for i=0,3 do
        if turtle.forward() then
            local endCoords = vector.new(gps.locate())
            self.direction = endCoords - startCoords
            --attempt to move back to start (might run out of fuel or get trolled by a player)
            if not turtle.back() then self.coords:add(self.direction) end
            return true
        end
        turtle.turnRight()
    end
    debugPrint("CANT MOVE")
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
        debugPrint("INCOMPATIBLE COMMAND ".. mCommand)
        return
    end

    success = turtle[mCommand]() --runs turtle.mCommand()
    if success and self:direction ~= nil then
        moveOdometry[mCommand](self)
    end
    return success
end

function TurtleController:face(vec)
    if type(vec) ~= 'table' then
        local newVec = TurtleController.valueToOrientation(vec)
            
        if not newVec then
            debugPrint("TC:face() - INVALID INPUT: "..newVec)
            return false
        end
        vec = newVec
        end
    end
    if directionConversions[vec] == nil then debugPrint("TC:face() - vector non unitary") return false end
    for i=0,3 do
        if vec == self.direction then
            return true   
        end
        self:move("turnRight")
    end
    debugPrint("TC:face() - INVALID VECTOR: "..vec.tostring())
    return false
end

--move in the direction of a unitary vector a certain amount. undefined behavior for non right-unitary
function TurtleController:moveVector(unitVec, amount, allowReverse)

    local goingBackwards = allowReverse and -self.direction == unitVec
    if not goingBackwards then --if allowreverse and facing away, ignore unitVec
        self:face(unitVec)  --WONT TURN IF ITS UP OR DOWN (could put an if here)
    end
    local success = true
    for i = 1, amount do
        if unitVec.y > 0 then success = success and self:move("up")
        elseif unitVec.y < 0 then success = success and self:move("down")
        elseif goingBackwards then success = success and self:move("back")
        else success = success and self:move("forward") end
        if not success then return false end
    end
    --todo handle hitting walls.
    return true
end

local function sign(n)
    return n > 0 and 1
       or  n < 0 and 1
       or  0
 end

--[[
    Takes a vector, returns a right angle unitary vector, by the vectors biggest value.
    returns VECTOR, LENGTH
    where VECTOR: one of the six right unitary vectors (eg [-1,0,0])
    LENGTH: non-negative length in the chosen axis.

    example: [3,-25,19]  ->  ret [0,-1,0], 25
]]--
function TurtleController.normalizeToGrid(vec)
    local maxvalue = 0, maxindex = 'x'
    for i, value in pairs(vec) do
        if math.abs(value) > maxvalue then
            maxvalue, maxindex = math.abs(value), i
        end
    end
    local normalized = vector.new(0,0,0)
    normalized[maxindex] = sign(vec[maxindex]) -- turns into -1 or 1 (or 0?)
    if normalized[maxindex] == 0 then normalized[maxindex] = 1 end
    return normalized, vector[maxindex]
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
function TurtleController.valueToOrientation(directionValue)
    if directionValue == nil then return nil end
    if directionConversions[directionValue] ~= nil then return directionConversions[directionValue].vector end
    if type(directionValue) == 'number' then directionValue = (directionValue + 360 ) % 360  end --Make sure angles range between 0-360
    
    for direction, conversion in pairs(directionConversions) do
        if conversion.angle == directionValue or conversion.name == directionValue then
            return directionConversions[direction].vector
        end
    end
    return nil  --Incase of invalid input, return nil
end

--[[converts input to vector and sets the direction to be that direction (doesnt work if already vector)]]
function TurtleController:importOrientation(direction)
    local newOrientation = TurtleController.valueToOrientation(direction)
    if newOrientation ~= nil then
        self.direction = newOrientation
        return true
    else
        return false
    end
end

--[[returns home as a VECTOR]]
function TurtleController:getHome()
    --In the future, can get home from broadcasting computers
    return self.home
end

function TurtleController:goTo(destination, repeatAttemptCount ,allowReverse)
    if repeatAtteptCount == nil then repeatAttemptCount = 0 end
    local order = {'y', 'x', 'z'} --y,x,z
    for _, direction in ipairs(order) do
        local path = destination - self.coords
        local unitVector = vector.new(0,0,0)
        unitVector.direction = path.direction --assign one length to be nonzero

        --move along ;direction; axis
        if not self:moveVector(TurtleController.normalizeToGrid(unitVector), allowReverse) then
            table.insert(hitObstacles, direction)
        end
    end

    if repeatAttemptCount > 0 then
        self:goTo(destination,repeatAttemptCount - 1 , allowReverse)
    end
    return self.coords == destination
end

function TurtleController:checkReturn()

end


setmetatable(TurtleController, {__call=TurtleController.__init__})
