minetest.register_chatcommand("findnodes", {
	description = "Scan for one or multible nodes in a radius around you",
	param = "<radius> <node1>[,<node2>...]",
	func = function(param)
		local radius = tonumber(param:split(" ")[1])
		local nodes = param:split(" ")[2]:split(",")
		local pos = minetest.localplayer:get_pos()
		local fpos = minetest.find_node_near(pos, radius, nodes, true)
		if fpos then
			return true, "Found " .. table.concat(nodes, " or ") .. " at " .. minetest.pos_to_string(fpos)
		end
		return false, "None of " .. table.concat(nodes, " or ") .. " found in a radius of " .. tostring(radius)
	end,
}) 

minetest.register_chatcommand("place", {
	params = "<X>,<Y>,<Z>",
	description = "Place wielded item",
	func = function(param)
		local success, pos = minetest.parse_relative_pos(param)
		if success then
			minetest.place_node(pos)
			return true, "Node placed at " .. minetest.pos_to_string(pos)
		end
		return false, pos
	end,
})

minetest.register_chatcommand("dig", {
	params = "<X>,<Y>,<Z>",
	description = "Dig node",
	func = function(param)
		local success, pos = minetest.parse_relative_pos(param)
		if success then
			minetest.dig_node(pos)
			return true, "Node at " .. minetest.pos_to_string(pos) .. " dug"
		end
		return false, pos
	end,
})

minetest.register_globalstep(function()
	local player = minetest.localplayer 
	if not player then return end
	local pos = minetest.localplayer:get_pos()
	local wielditem = minetest.localplayer:get_wielded_item()
	if minetest.settings:get_bool("scaffold") then
		minetest.place_node(vector.add(pos, {x = 0, y = -0.6, z = 0}))
	end
	if minetest.settings:get_bool("highway_z") and wielditem then
		local z = pos.z
		local positions = {
			{x = 0, y = 0, z = z},
			{x = 1, y = 0, z = z},
			{x = 2, y = 1, z = z},
			{x = -2, y = 1, z = z},
			{x = -2, y = 0, z = z},
			{x = -1, y = 0, z = z},
			{x = 2, y = 0, z = z}
		}
		for _, p in pairs(positions) do
			local node = minetest.get_node_or_nil(p)
			if node and not minetest.get_node_def(node.name).walkable then
				minetest.place_node(p)
			end
		end
	end
	if minetest.settings:get_bool("fucker") then
		local p = minetest.find_node_near(pos, 5, "group:bed", true)
		if p then
			minetest.dig_node(p)
		end
	end
	if minetest.settings:get_bool("destroy_liquids") then
		local p = minetest.find_node_near(pos, 5, "mcl_core:water_source", true) or minetest.find_node_near(pos, 5, "mcl_core:water_floating", true)
		if p then
			minetest.place_node(p)
		end
	end  
end) 

minetest.register_cheat("Scaffold", "World", "scaffold")
minetest.register_cheat("HighwayZ", "World", "highway_z")
minetest.register_cheat("Fucker", "World", "fucker")
minetest.register_cheat("BlockWater", "World", "destroy_liquids")
