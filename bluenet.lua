-- bluenet userspace utility
-- Copyright 2015 Liam Crabbe

-- interpret command line arguments. these can be added to at a later date if more userspace functions are needed
function interpret_arguments() 
	local command = arg[1]
	
	if parse_1 == "announce" then
		host_announce()
	else
		print("usage: bluenet announce <modem side>")
	end
end

-- announce host on the network
function host_announce()
	local side = arg[2]
	if side != "top" or side != "bottom" or side != "left" or side != "right" or side != "back" then
		print("usage: bluenet announce <modem side>")
		print("<modem side> can be either top, bottom, left, right, or back")
	else
		local modem = peripheral.wrap(side)
		local my_id = os.getComputerID()
		
		modem.transmit(6011, my_id, "ANNOUNCE HOST UP")
	end
end

		
	