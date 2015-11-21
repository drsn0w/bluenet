-- bluenet_announce
-- Copyright 2015 Liam Crabbe

arg = {...}

print(arg[1])
print(arg[2])
local modem = peripheral.wrap(arg[1])

my_id = os.getComputerID()

packet = {6011, my_id, "ANNOUNCE HOST UP"}
data = textutils.serialize(packet)

modem.transmit(6011, my_id, data)
