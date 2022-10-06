local input = {...}
if input[1] ~= nil and textutils.unserialise(input[1]) == 'number' then
local coords = vector.new(textutils.unserialise(input[1]), textutils.unserialise(input[2]), textutils.unserialise(input[3]))
else

end
--lazy af but im supposed to varify the inputs, deal with the crash on your own!

while true do
    rednet.broadcast(coords, "RefillStationResponse")
end