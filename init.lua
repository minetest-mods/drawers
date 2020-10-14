--[[
Minetest Mod Storage Drawers - A Mod adding storage drawers

Copyright (C) 2017-2020 Linus Jahn <lnj@kaidan.im>

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

-- Load support for intllib.
local MP = core.get_modpath(core.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

drawers = {}
drawers.drawer_visuals = {}

drawers.WOOD_ITEMSTRING = "group:wood"
if core.get_modpath("default") and default then
	drawers.WOOD_SOUNDS = default.node_sound_wood_defaults()
	drawers.CHEST_ITEMSTRING = "default:chest"
elseif core.get_modpath("mcl_core") and mcl_core then -- MineClone 2
	drawers.CHEST_ITEMSTRING = "mcl_chests:chest"
	if core.get_modpath("mcl_sounds") and mcl_sounds then
		drawers.WOOD_SOUNDS = mcl_sounds.node_sound_wood_defaults()
	end
else
	drawers.CHEST_ITEMSTRING = "chest"
end


drawers.enable_1x1 = not core.settings:get_bool("drawers_disable_1x1")
drawers.enable_1x2 = not core.settings:get_bool("drawers_disable_1x2")
drawers.enable_2x2 = not core.settings:get_bool("drawers_disable_2x2")

drawers.CONTROLLER_RANGE = 14

--
-- GUI
--

drawers.gui_bg = "bgcolor[#080808BB;true]"
drawers.gui_slots = "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"
if (core.get_modpath("mcl_core")) and mcl_core then -- MCL2
	drawers.gui_bg_img = "background[5,5;1,1;crafting_creative_bg.png;true]"
else
	drawers.gui_bg_img = "background[5,5;1,1;gui_formbg.png;true]"
end

--
-- Load API
--

dofile(MP .. "/lua/helpers.lua")
dofile(MP .. "/lua/visual.lua")
dofile(MP .. "/lua/api.lua")
dofile(MP .. "/lua/controller.lua")


--
-- Register drawers
--

if core.get_modpath("default") and default then
	drawers.register_drawer("drawers:wood", {
		description = S("Wooden"),
		tiles1 = drawers.node_tiles_front_other("drawers_wood_front_1.png",
			"drawers_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_wood_front_2.png",
			"drawers_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_wood_front_4.png",
			"drawers_wood.png"),
		groups = {choppy = 3, oddly_breakable_by_hand = 2},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 32, -- 4 * 8 normal chest size
		material = drawers.WOOD_ITEMSTRING
	})
	drawers.register_drawer("drawers:acacia_wood", {
		description = S("Acacia Wood"),
		tiles1 = drawers.node_tiles_front_other("drawers_acacia_wood_front_1.png",
			"drawers_acacia_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_acacia_wood_front_2.png",
			"drawers_acacia_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_acacia_wood_front_4.png",
			"drawers_acacia_wood.png"),
		groups = {choppy = 3, oddly_breakable_by_hand = 2},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 32, -- 4 * 8 normal mcl chest size
		material = "default:acacia_wood"
	})
	drawers.register_drawer("drawers:aspen_wood", {
		description = S("Aspen Wood"),
		tiles1 = drawers.node_tiles_front_other("drawers_aspen_wood_front_1.png",
			"drawers_aspen_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_aspen_wood_front_2.png",
			"drawers_aspen_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_aspen_wood_front_4.png",
			"drawers_aspen_wood.png"),
		groups = {choppy = 3, oddly_breakable_by_hand = 2},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 32, -- 4 * 8 normal chest size
		material = "default:aspen_wood"
	})
	drawers.register_drawer("drawers:junglewood", {
		description = S("Junglewood"),
		tiles1 = drawers.node_tiles_front_other("drawers_junglewood_front_1.png",
			"drawers_junglewood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_junglewood_front_2.png",
			"drawers_junglewood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_junglewood_front_4.png",
			"drawers_junglewood.png"),
		groups = {choppy = 3, oddly_breakable_by_hand = 2},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 32, -- 4 * 8 normal mcl chest size
		material = "default:junglewood"
	})
	drawers.register_drawer("drawers:pine_wood", {
		description = S("Pine Wood"),
		tiles1 = drawers.node_tiles_front_other("drawers_pine_wood_front_1.png",
			"drawers_pine_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_pine_wood_front_2.png",
			"drawers_pine_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_pine_wood_front_4.png",
			"drawers_pine_wood.png"),
		groups = {choppy = 3, oddly_breakable_by_hand = 2},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 32, -- 4 * 8 normal chest size
		material = "default:pine_wood"
	})
elseif core.get_modpath("mcl_core") and mcl_core then
	drawers.register_drawer("drawers:oakwood", {
		description = S("Oak Wood"),
		tiles1 = drawers.node_tiles_front_other("drawers_oak_wood_front_1.png",
			"drawers_oak_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_oak_wood_front_2.png",
			"drawers_oak_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_oak_wood_front_4.png",
			"drawers_oak_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36, -- 4 * 9 normal mcl chest size
		material = drawers.WOOD_ITEMSTRING,
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:acaciawood", {
		description = S("Acacia Wood"),
		tiles1 = drawers.node_tiles_front_other("drawers_acacia_wood_mcl_front_1.png",
			"drawers_acacia_wood_mcl.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_acacia_wood_mcl_front_2.png",
			"drawers_acacia_wood_mcl.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_acacia_wood_mcl_front_4.png",
			"drawers_acacia_wood_mcl.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36, -- 4 * 9 normal mcl chest size
		material = "mcl_core:acaciawood",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:birchwood", {
		description = S("Birch Wood"),
		tiles1 = drawers.node_tiles_front_other("drawers_birch_wood_front_1.png",
			"drawers_birch_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_birch_wood_front_2.png",
			"drawers_birch_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_birch_wood_front_4.png",
			"drawers_birch_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36, -- 4 * 9 normal mcl chest size
		material = "mcl_core:birchwood",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:darkwood", {
		description = S("Dark Oak Wood"),
		tiles1 = drawers.node_tiles_front_other("drawers_dark_oak_wood_front_1.png",
			"drawers_dark_oak_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_dark_oak_wood_front_2.png",
			"drawers_dark_oak_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_dark_oak_wood_front_4.png",
			"drawers_dark_oak_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36, -- 4 * 9 normal mcl chest size
		material = "mcl_core:darkwood",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:junglewood", {
		description = S("Junglewood"),
		tiles1 = drawers.node_tiles_front_other("drawers_junglewood_mcl_front_1.png",
			"drawers_junglewood_mcl.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_junglewood_mcl_front_2.png",
			"drawers_junglewood_mcl.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_junglewood_mcl_front_4.png",
			"drawers_junglewood_mcl.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36, -- 4 * 9 normal mcl chest size
		material = "mcl_core:junglewood",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:sprucewood", {
		description = S("Spruce Wood"),
		tiles1 = drawers.node_tiles_front_other("drawers_spruce_wood_front_1.png",
			"drawers_spruce_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_spruce_wood_front_2.png",
			"drawers_spruce_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_spruce_wood_front_4.png",
			"drawers_spruce_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36, -- 4 * 9 normal mcl chest size
		material = "mcl_core:sprucewood",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})

	-- backwards compatibility
	core.register_alias("drawers:wood1", "drawers:oakwood1")
	core.register_alias("drawers:wood2", "drawers:oakwood2")
	core.register_alias("drawers:wood4", "drawers:oakwood4")
else
	drawers.register_drawer("drawers:wood", {
		description = S("Wooden"),
		tiles1 = drawers.node_tiles_front_other("drawers_wood_front_1.png",
			"drawers_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_wood_front_2.png",
			"drawers_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_wood_front_4.png",
			"drawers_wood.png"),
		groups = {choppy = 3, oddly_breakable_by_hand = 2},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 32, -- 4 * 8 normal chest size
		material = drawers.WOOD_ITEMSTRING
	})
end


--
-- Register drawer upgrades
--

if core.get_modpath("default") and default then
	drawers.register_drawer_upgrade("drawers:upgrade_steel", {
		description = S("Steel Drawer Upgrade (x2)"),
		inventory_image = "drawers_upgrade_steel.png",
		groups = {drawer_upgrade = 100},
		recipe_item = "default:steel_ingot"
	})

	drawers.register_drawer_upgrade("drawers:upgrade_gold", {
		description = S("Gold Drawer Upgrade (x3)"),
		inventory_image = "drawers_upgrade_gold.png",
		groups = {drawer_upgrade = 200},
		recipe_item = "default:gold_ingot"
	})

	drawers.register_drawer_upgrade("drawers:upgrade_obsidian", {
		description = S("Obsidian Drawer Upgrade (x4)"),
		inventory_image = "drawers_upgrade_obsidian.png",
		groups = {drawer_upgrade = 300},
		recipe_item = "default:obsidian"
	})

	drawers.register_drawer_upgrade("drawers:upgrade_diamond", {
		description = S("Diamond Drawer Upgrade (x8)"),
		inventory_image = "drawers_upgrade_diamond.png",
		groups = {drawer_upgrade = 700},
		recipe_item = "default:diamond"
	})
elseif core.get_modpath("mcl_core") and mcl_core then
	drawers.register_drawer_upgrade("drawers:upgrade_iron", {
		description = S("Iron Drawer Upgrade (x2)"),
		inventory_image = "drawers_upgrade_iron.png",
		groups = {drawer_upgrade = 100},
		recipe_item = "mcl_core:iron_ingot"
	})

	drawers.register_drawer_upgrade("drawers:upgrade_gold", {
		description = S("Gold Drawer Upgrade (x3)"),
		inventory_image = "drawers_upgrade_gold.png",
		groups = {drawer_upgrade = 200},
		recipe_item = "mcl_core:gold_ingot"
	})

	drawers.register_drawer_upgrade("drawers:upgrade_obsidian", {
		description = S("Obsidian Drawer Upgrade (x4)"),
		inventory_image = "drawers_upgrade_obsidian.png",
		groups = {drawer_upgrade = 300},
		recipe_item = "mcl_core:obsidian"
	})

	drawers.register_drawer_upgrade("drawers:upgrade_diamond", {
		description = S("Diamond Drawer Upgrade (x8)"),
		inventory_image = "drawers_upgrade_diamond.png",
		groups = {drawer_upgrade = 700},
		recipe_item = "mcl_core:diamond"
	})

	drawers.register_drawer_upgrade("drawers:upgrade_emerald", {
		description = S("Emerald Drawer Upgrade (x13)"),
		inventory_image = "drawers_upgrade_emerald.png",
		groups = {drawer_upgrade = 1200},
		recipe_item = "mcl_core:emerald"
	})
end

if core.get_modpath("moreores") then
	drawers.register_drawer_upgrade("drawers:upgrade_mithril", {
		description = S("Mithril Drawer Upgrade (x13)"),
		inventory_image = "drawers_upgrade_mithril.png",
		groups = {drawer_upgrade = 1200},
		recipe_item = "moreores:mithril_ingot"
	})
end

--
-- Register drawer trim
--

if core.get_modpath("mcl_core") and mcl_core then
	core.register_node("drawers:trim", {
		description = S("Wooden Trim"),
		tiles = {"drawers_trim.png"},
		groups = {drawer_connector = 1, handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
else
	core.register_node("drawers:trim", {
		description = S("Wooden Trim"),
		tiles = {"drawers_trim.png"},
		groups = {drawer_connector = 1, choppy = 3, oddly_breakable_by_hand = 2},
	})
end

core.register_craft({
	output = "drawers:trim 6",
	recipe = {
		{"group:stick", "group:wood", "group:stick"},
		{"group:wood",  "group:wood",  "group:wood"},
		{"group:stick", "group:wood", "group:stick"}
	}
})

--
-- Register drawer upgrade template
--

core.register_craftitem("drawers:upgrade_template", {
	description = S("Drawer Upgrade Template"),
	inventory_image = "drawers_upgrade_template.png"
})

core.register_craft({
	output = "drawers:upgrade_template 4",
	recipe = {
		{"group:stick", "group:stick", "group:stick"},
		{"group:stick", "group:drawer", "group:stick"},
		{"group:stick", "group:stick", "group:stick"}
	}
})

