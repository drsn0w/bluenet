-- bluenet routed
-- Copyright 2015 Liam Crabbe and Shawn Anastasio

-- setup constants
WAN_INTERFACE = "left"
LAN_INTERFACE = "right"
MY_ID = os.getComputerID()

function init()
	print("bluenet routed starting...")

	-- initialize and wrap modem devices
	print("Initializing modems...")
	print("LAN: " .. LAN_INTERFACE)
	lan_modem = peripheral.wrap(LAN_INTERFACE)
	print("WAN: " .. WAN_INTERFACE)
	wan_modem = peripheral.wrap(WAN_INTERFACE)

	-- setup WAN listener
	wan_modem.open(6050)
	print("Listening for WAN packets on 6050...")

	-- setup LAN listeners
	lan_modem.open(6010)
	print("Listening for LAN packets on 6010...")
	lan_modem.open(6011)
	print("Listening for LAN host announcements on 6011...")

	-- initialize routing table()
	lan_host_list = {}
end

-- check if a host exists in the LAN routing table
function lan_check_host_exists(route)
	for key, value in pairs(lan_host_list) do
		if value == route then return true end
	end
	return false
end

-- add a host to the LAN routing table
function add_lan_host(route)
	if lan_check_host_exists(route) then
		print(route .. " is already a registered route! Dropping request.")
	else
		table.insert(lan_host_list, route)
		print(route .. " registered as route!")
	end
end

-- deserialize and disassemble bluenet packet table
-- returns as destination_address, source_address, message
function deserialize_and_disassemble(data)
	local data_table = textutils.unserialize(data)
	return data_table[1], data_table[2], data_table[3]
end

-- assembles and serializes bluenet packet table
function assemble_and_serialize(destination_address, source_address, message)
	local data_table = {destination_address, source_address, message}
	local serialized_table = textutils.serialize(data_table)
	return serialized_table
end

-- listen for and route data packets from LAN
function route_lan_to_wan()
	while true do
		local event, m_side, on_chan, dest_dev, data, _ = os.pullEvent("modem_message")
		if m_side == LAN_INTERFACE and on_chan == 6010 then
			local destination, source, message = deserialize_and_disassemble(data)
			if lan_check_host_exists(destination) then
				print("Routing packet from LAN " .. source .. " to LAN " .. destination)
				lan_modem.transmit(destination, 6010, data)
			else
				print("Routing packet from LAN " .. source .. " to WAN " .. destination)
				wan_modem.transmit(6050, 6050, data)
			end
		end
	end
end

-- listen for and route data packets from WAN
function route_wan_to_lan()
	while true do
		local event, m_side, on_chan, dest_dev, data, _ = os.pullEvent("modem_message")
		if m_side == WAN_INTERFACE and on_chan == 6050 then
			local destination, source, message = deserialize_and_disassemble(data)
			if lan_check_route_exists(destination) then
				print("Routing packet from WAN " .. source .. " to LAN " .. destination)
				lan_modem.transmit(destination, 6010, data)
			end
		end
	end
end

-- listen for LAN host announcements
function listen_for_lan_announce()
	while true do
		local event, m_side, on_chan, dest_dev, data, _ = os.pullEvent("modem_message")
		if m_side == LAN_INTERFACE and on_chan == 6011 then
			local destination, source, message = deserialize_and_disassemble(data)
			if message == "bluenet_announce host_up" then
				add_lan_host(source)
			end
		end
	end
end


init()
parallel.waitForAny(route_lan_to_wan, route_wan_to_lan, listen_for_lan_announce)
print("If you see this, something has gone terribly wrong.")
