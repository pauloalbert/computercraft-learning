
rednet.open()

while true do
    id, message = rednet.receive()

    if message == "Execute" do
        print("EXECUTED")
        rednet.send(id, "Recieved")
    end

end