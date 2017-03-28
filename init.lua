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

drawers = {}

-- TODO: Support other games than MTG/MTG-like  (e.g. MineClone2)
local WOOD_SOUNDS
local WOOD_ITEMSTRING
local CHEST_ITEMSTRING
if default then
	WOOD_SOUNDS = default.node_sound_wood_defaults()
	WOOD_ITEMSTRING = "default:wood"
	CHEST_ITEMSTRING = "default:chest"
else
	WOOD_ITEMSTRING = "wood"
	CHEST_ITEMSTRING = "chest"
end

drawers.node_box_simple = {
	{-0.5, -0.5, -0.4375, 0.5, 0.5, 0.5},
	{-0.5, -0.5, -0.5, -0.4375, 0.5, -0.4375},
	{0.4375, -0.5, -0.5, 0.5, 0.5, -0.4375},
	{-0.4375, 0.4375, -0.5, 0.4375, 0.5, -0.4375},
	{-0.4375, -0.5, -0.5, 0.4375, -0.4375, -0.4375},
}

local function gen_info_text(basename, count, factor, stack_max)
	-- in the end it should look like:
	-- Sand [4x99+43 / 24x99]
	-- bot NOT so:
	-- Dirt [2x99 + 0 / 24x99]
	local countstr = tostring(math.floor(count / stack_max)) .. "x" ..
		stack_max
	if count % stack_max ~= 0 then
		countstr = countstr .. " + " .. count % stack_max
	end
	return basename .. " [" .. countstr .. " / " .. factor .. "x" .. stack_max .. "]"
end

local function get_inv_image(name)
	local texture = default_texture
	local def = minetest.registered_items[name]
	if name ~= "air" and def then
		if def.inventory_image and #def.inventory_image > 0 then
			texture = def.inventory_image
		else
			local c = #def.tiles
			local x = {}
			for i, v in ipairs(def.tiles) do
				if type(v) == "table" then
					x[i] = v.name
				else
					x[i] = v
				end
				i = i + 1
			end
			if not x[3] then x[3] = x[1] end
			if not x[4] then x[4] = x[3] end
			texture = core.inventorycube(x[1], x[3], x[4])
		end
	end
	return texture
end

core.register_entity("drawers:visual", {
	initial_properties = {
		hp_max = 1,
		physical = false,
		collide_with_objects = false,
		collisionbox = {-0.4374, -0.4374, 0,  0.4374, 0.4374, 0}, -- for param2 0, 2
		visual = "upright_sprite", -- "wielditem" for items without inv img?
		visual_size = {x = 0.6, y = 0.6},
		textures = {"drawers_empty.png"},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = true,
	},

	get_staticdata = function(self)
		return core.serialize({
			drawer_posx = self.drawer_pos.x,
			drawer_posy = self.drawer_pos.y,
			drawer_posz = self.drawer_pos.z,
			texture = self.texture
		})
	end,

	on_activate = function(self, staticdata, dtime_s)
		-- Restore data
		data = core.deserialize(staticdata)
		if data then
			self.drawer_pos = {
				x = data.drawer_posx,
				y = data.drawer_posy,
				z = data.drawer_posz,
			}
			self.texture = data.texture
		else
			self.drawer_pos = drawers.last_drawer_pos
			self.texture = "drawers_empty.png"
		end


		local node = core.get_node(self.drawer_pos)

		-- collisionbox
		local colbox = {-0.4374, -0.4374, 0,  0.4374, 0.4374, 0} -- for param2 = 0 or 2
		if node.param2 == 1 or node.param2 == 3 then
			colbox = {0, -0.4374, -0.4374,  0, 0.4374, 0.4374}
		end


		-- infotext
		local meta = core.get_meta(self.drawer_pos)
		local infotext = meta:get_string("entity_infotext") .. "\n\n\n\n\n"

		self.object:set_properties({
			collisionbox = colbox,
			infotext = infotext,
			textures = {self.texture}
		})

		-- make entity undestroyable
		self.object:set_armor_groups({immortal = 1})
	end,

	on_rightclick = function(self, clicker)
		local node = core.get_node(self.drawer_pos)
		local itemstack = clicker:get_wielded_item()
		local add_count = itemstack:get_count()
		local add_name = itemstack:get_name()

		local meta = core.get_meta(self.drawer_pos)
		local name = meta:get_string("name")
		local count = meta:get_int("count")
		local max_count = meta:get_int("max_count")

		local base_stack_max = meta:get_int("base_stack_max")
		local stack_max_factor = meta:get_int("stack_max_factor")

		-- if nothing to be added, return
		if add_count <= 0 then return end
		-- if no itemstring, return
		if item_name == "" then return end

		-- only add one, if player holding sneak key
		if clicker:get_player_control().sneak then
			add_count = 1
		end

		-- if current itemstring is not empty
		if name ~= "" then
			-- check if same item
			if add_name ~= name then return end
		else -- is empty
			name = add_name
			count = 0

			-- get new stack max
			base_stack_max = ItemStack(name):get_stack_max()
			max_count = base_stack_max * stack_max_factor

			-- Don't add items stackable only to 1
			if base_stack_max == 1 then
				return
			end

			meta:set_string("name", name)
			meta:set_int("base_stack_max", base_stack_max)
			meta:set_int("max_count", max_count)
		end

		-- set new counts:
		-- if new count is more than max_count
		if (count + add_count) > max_count then
			count = max_count
			itemstack:set_count((count + add_count) - max_count)
		else -- new count fits
			count = count + add_count
			itemstack:set_count(itemstack:get_count() - add_count)
		end
		-- set new drawer count
		meta:set_int("count", count)

		-- update infotext
		local infotext = gen_info_text(core.registered_items[name].description,
			count, stack_max_factor, base_stack_max)
		meta:set_string("entity_infotext", infotext)

		-- texture
		self.texture = get_inv_image(name)

		self.object:set_properties({
			infotext = infotext .. "\n\n\n\n\n",
			textures = {self.texture}
		})

		clicker:set_wielded_item(itemstack)
	end,

	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local meta = minetest.get_meta(self.drawer_pos)
		local count = meta:get_int("count")

		if count <= 0 then
			return
		end
		local name = meta:get_string("name")

		local remove_count = 1
		if not puncher:get_player_control().sneak then
			remove_count = ItemStack(name):get_stack_max()
		end
		if remove_count > count then remove_count = count end

		local stack = ItemStack(name)
		stack:set_count(remove_count)

		local inv = puncher:get_inventory()
		if not inv:room_for_item("main", stack) then
			return
		end

		inv:add_item("main", stack)
		count = count - remove_count
		meta:set_int("count", count)

		-- update infotext
		local stack_max_factor = meta:get_int("stack_max_factor")
		local base_stack_max = meta:get_int("base_stack_max")
		local item_description = ""
		if core.registered_items[name] then
			item_description = core.registered_items[name].description
		end

		if count <= 0 then
			meta:set_string("name", "")
			self.texture = "drawers_empty.png"
			item_description = "Empty"
		end

		local infotext = gen_info_text(item_description,
			count, stack_max_factor, base_stack_max)
		meta:set_string("entity_infotext", infotext)

		self.object:set_properties({
			infotext = infotext .. "\n\n\n\n\n",
			textures = {self.texture}
		})
	end
})

local function spawn_visual(pos)
	local node = core.get_node(pos)

	-- data for the new visual
	drawers.last_drawer_pos = pos

	local bdir = core.facedir_to_dir(node.param2)
	local fdir = vector.new(-bdir.x, 0, -bdir.z)
	local pos2 = vector.add(pos, vector.multiply(fdir, 0.438))

	obj = core.add_entity(pos2, "drawers:visual")

	if bdir.x < 0 then obj:setyaw(0.5 * math.pi) end
	if bdir.z < 0 then obj:setyaw(math.pi) end
	if bdir.x > 0 then obj:setyaw(1.5 * math.pi) end
end

-- construct drawer
local function drawer_on_construct(pos)
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
	meta:set_string("entity_infotext", gen_info_text("Empty", 0,
		stack_max_factor, base_stack_max))

	spawn_visual(pos)
end

-- destruct drawer
local function drawer_on_destruct(pos)
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
local function drawer_on_dig(pos, node, player)
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

core.register_lbm({
	name = "drawers:restore_visual",
	nodenames = {"group:drawer"},
	run_at_every_load = true,
	action  = function(pos, node)
		local objs = core.get_objects_inside_radius(pos, 0.5)
		if objs then
			for _, obj in pairs(objs) do
				if obj and obj:get_luaentity() and
						obj:get_luaentity().name == "drawers:visual" then
					return
				end
			end
		end

		-- no visual found, create a new one
		spawn_visual(pos)
	end
})

function drawers.register_drawer(name, def)
	def.description = def.description or "Drawer"
	def.drawtype = "nodebox"
	def.node_box = {type = "fixed", fixed = drawers.node_box_simple}
	def.collision_box = {type = "regular"}
	def.selection_box = {type = "regular"}
	def.tiles = def.tiles or {"default_wood.png"}
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.legacy_facedir_simple = true
	def.groups = def.groups or {}
	def.groups.drawer = def.groups.drawer or 1
	def.drawer_stack_max_factor = def.drawer_stack_max_factor or 24

	-- events
	def.on_construct = drawer_on_construct
	def.on_destruct = drawer_on_destruct
	def.on_dig = drawer_on_dig

	if screwdriver then
		def.on_rotate = def.on_rotate or screwdriver.disallow
	end

	core.register_node(name, def)

	if (not def.no_craft) and def.material then
		core.register_craft({
			output = name,
			recipe = {
				{def.material, def.material, def.material},
				{"", CHEST_ITEMSTRING, ""},
				{def.material, def.material, def.material}
			}
		})
	end
end

drawers.register_drawer("drawers:wood", {
	description = "Wooden Drawer",
	groups = {choppy = 3, oddly_breakable_by_hand = 2},
	sounds = WOOD_SOUNDS,
	drawer_stack_max_factor = 3 * 8, -- normal chest size
	material = WOOD_ITEMSTRING
})
