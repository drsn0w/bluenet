-- Bluenet Client API
-- Written by drsn0w
-- Copyright 2015 Liam Crabbe and Shawn Anastasio

local blue_modem = nil
local bluenet_open = false
local local_id = os.getComputerID()
local lan_packet_channel = 6010


-- deserialize and disassemble bluenet packet table
-- returns as destination_address, source_address, message
-- copied from routed
local function deserialize_and_disassemble(data)
	local data_table = textutils.unserialize(data)
	return data_table[1], data_table[2], data_table[3]
end

-- assembles and serializes bluenet packet table
-- copied from routed
local function assemble_and_serialize(destination_address, source_address, message)
	local data_table = {destination_address, source_address, message}
	local serialized_table = textutils.serialize(data_table)
	return serialized_table
end

local function announce_host(modem)
	packet = {6011, my_id, "bluenet_announce host_up"}
	data = textutils.serialize(packet)

	modem.transmit(6011, my_id, data)
end

function open(modem_side)
	if bluenet_open == true then
		print("[bluenet] bluenet is already open!")
		return
	end
	blue_modem = peripheral.wrap(modem_side)
	blue_modem.open(local_id)
	announce_host(modem)
	bluenet_open = true
end

function close(modem_side)
	if bluenet_open == false then
		print("[bluenet] cannot close bluenet if it's not even open")
		return
	end
	blue_modem.close(local_id)
	bluenet_open = false
end

function send(recipient_id, message_to_send)
	local data_table = assemble_and_serialize(recipient_id, local_id, message_to_send)
	blue_modem.transmit(lan_packet_channel, local_id, data_table)
end

function receive()
	if bluenet_open == false then
		print("[bluenet] bluenet is not open!")
		return
	end
	local event, m_side, s_channel, r_channel, message, _ = os.pullEvent("modem_message")
	local destination_address, source_address, d_message = deserialize_and_disassemble(message)
	return source_address, d_message
end
