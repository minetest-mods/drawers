--[[
Minetest Mod Storage Drawers - A Mod adding storage drawers

Copyright (C) 2017 LNJ <git@lnj.li>
Copyright (C) 2016 Mango Tango <mtango688@gmail.com>

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

drawers.node_box_simple = {
	{-0.5, -0.5, -0.4375, 0.5, 0.5, 0.5},
	{-0.5, -0.5, -0.5, -0.4375, 0.5, -0.4375},
	{0.4375, -0.5, -0.5, 0.5, 0.5, -0.4375},
	{-0.4375, 0.4375, -0.5, 0.4375, 0.5, -0.4375},
	{-0.4375, -0.5, -0.5, 0.4375, -0.4375, -0.4375},
}

-- construct drawer
function drawers.drawer_on_construct(pos)
	local node = core.get_node(pos)
	local ndef = core.registered_nodes[node.name]

	local base_stack_max = core.nodedef_default.stack_max or 99
	local stack_max_factor = ndef.drawer_stack_max_factor or 24 -- 3x8

	-- meta
	local meta = core.get_meta(pos)
	meta:set_string("name", "")
	meta:set_int("count", 0)
	meta:set_int("max_count", base_stack_max * stack_max_factor)
	meta:set_int("stack_max_factor", stack_max_factor)
	meta:set_int("base_stack_max", base_stack_max)
	meta:set_string("entity_infotext", drawers.gen_info_text("Empty", 0,
		stack_max_factor, base_stack_max))

	drawers.spawn_visual(pos)
end

-- destruct drawer
function drawers.drawer_on_destruct(pos)
	local objs = core.get_objects_inside_radius(pos, 0.5)
	if objs then
		for _, obj in pairs(objs) do
			if obj and obj:get_luaentity() and
					obj:get_luaentity().name == "drawers:visual" then
				obj:remove()
				return
			end
		end
	end
end

-- drop all items
function drawers.drawer_on_dig(pos, node, player)
	local meta = core.get_meta(pos)
	local count = meta:get_int("count")
	local name = meta:get_string("name")

	-- remove node
	core.node_dig(pos, node, player)

	-- drop the items
	local stack_max = ItemStack(name):get_stack_max()

	local j = math.floor(count / stack_max) + 1
	local i = 1
	while i <= j do
		if not (i == j) then
			core.add_item(pos, name .. " " .. stack_max)
		else
			core.add_item(pos, name .. " " .. count % stack_max)
		end
		i = i + 1
	end
end

function drawers.drawer_insert_object(pos, node, stack, direction)
	local drawer_visual = drawers.drawer_visuals[core.serialize(pos)]
	if not drawer_visual then return stack end

	local leftover = drawer_visual.try_insert_stack(drawer_visual, stack, true)
	return leftover
end

function drawers.register_drawer(name, def)
	def.description = def.description or "Drawer"
	def.drawtype = "nodebox"
	def.node_box = {type = "fixed", fixed = drawers.node_box_simple}
	def.collision_box = {type = "regular"}
	def.selection_box = {type = "regular"}
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.legacy_facedir_simple = true
	def.groups = def.groups or {}
	def.groups.drawer = def.groups.drawer or 1
	def.drawer_stack_max_factor = def.drawer_stack_max_factor or 24

	-- events
	def.on_construct = drawers.drawer_on_construct
	def.on_destruct = drawers.drawer_on_destruct
	def.on_dig = drawers.drawer_on_dig

	if screwdriver then
		def.on_rotate = def.on_rotate or screwdriver.disallow
	end

	if pipeworks then
		def.groups.tubedevice = 1
		def.groups.tubedevice_receiver = 1
		def.tube = def.tube or {}
		def.tube.insert_object = def.tube.insert_object or
			drawers.drawer_insert_object
		def.tube.connect_sides = {left = 1, right = 1, back = 1, top = 1,
			bottom = 1}
		def.after_place_node = pipeworks.after_place
		def.after_dig_node = pipeworks.after_dig
	end

	core.register_node(name, def)

	if (not def.no_craft) and def.material then
		core.register_craft({
			output = name,
			recipe = {
				{def.material, def.material, def.material},
				{"", drawers.CHEST_ITEMSTRING, ""},
				{def.material, def.material, def.material}
			}
		})
	end
end
