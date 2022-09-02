require(table)

--If possible get a table of all sugar cane locations.
--sort tables
--what is async + how do tjmers

--[[breaking sugar canes]]
--approach sugar cane   (turtleplus.navigate)
--move down until reached floor/no more sugar cane (turtle.detectDown)
--suck all the items    (turtle.suck(), turtleplus.managesuck() :{turtle.select(), turtle.getItemSpace()})

--[[navigation]]
--turtleplus.gotoCoords(nextcanes)      {facing vector, target vector, sort least, ret false??}
--turtleplus: handle obstructions
--gotonearest?
local tArgs = {...}
--[[extra]]
local TARGET_BLOCK = 'sugar_cane'
local FOUND_SUGARCANES = {}
local SUGARCANE_FILE = "sugarcane_locations"
local SEARCH_MODE = 0

--[[load previous]]
FOUND_SUGARCANES = loadTableFromFile(SUGARCANE_FILE)
if FOUND_SUGARCANES == nil do
    FOUND_SUGARCANES = {}
    SEARCH_MODE == 1
end

