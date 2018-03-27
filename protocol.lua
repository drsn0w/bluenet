-- Bluenet protocol constants and helper functions
-- This file is not to be run manually
-- Copyright 2018 Shawn Anastasio, Liam Crabbe
-- Licensed under the terms of the GNU GPL v3 license

-- Channel for all LAN data traffic
local LAN_DATA_CHANNEL = 6010

-- Channel for all LAN announcement traffic
local LAN_ANNOUNCEMENT_CHANNEL = 6011

-- Channel for all WAN announcement traffic
local WAN_DATA_CHANNEL = 6050

-- deserialize and disassemble bluenet packet table
-- returns as destination_address, source_address, message
local function deserialize_and_disassemble(data)
	local data_table = textutils.unserialize(data)
	return data_table[1], data_table[2], data_table[3]
end

-- assembles and serializes bluenet packet table
local function assemble_and_serialize(destination_address, source_address, message)
	local data_table = {destination_address, source_address, message}
	local serialized_table = textutils.serialize(data_table)
	return serialized_table
end
