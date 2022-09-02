
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


setmetatable(TurtleController, {__call=TurtleController.__init__})
