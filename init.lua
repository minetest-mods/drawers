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

local MP = core.get_modpath(core.get_current_modname())

local S = core.get_translator('drawers')
local NS = core.get_translator('drawers')

drawers = {}
drawers.drawer_visuals = {}
drawers.mcl_loaded = core.get_modpath("mcl_core") and mcl_core

drawers.WOOD_ITEMSTRING = "group:wood"
if core.get_modpath("default") and default then
	drawers.WOOD_SOUNDS = default.node_sound_wood_defaults()
	drawers.CHEST_ITEMSTRING = "default:chest"
elseif drawers.mcl_loaded then -- MineClone 2
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
function drawers.inventory_list(posy)
	local hotbar_row_posy = posy + 1.25
	local inventory_list= "list[current_player;main;0.5,"..posy..";8,1;]" ..
						  "list[current_player;main;0.5,"..hotbar_row_posy..";8,3;8]"
	if drawers.mcl_loaded then -- MCL2
		hotbar_row_posy = posy + 3.25
		inventory_list = "list[current_player;main;0,"..posy..";9,3;9]" ..
						 "list[current_player;main;0,"..hotbar_row_posy..";9,1;]"
	end
	return inventory_list
end

--
-- Load API
--

dofile(MP .. "/lua/helpers.lua")
dofile(MP .. "/lua/visual.lua")
dofile(MP .. "/lua/api.lua")
dofile(MP .. "/lua/controller.lua")
dofile(MP .. "/lua/compacting.lua")

-- eye_spy integration (optional)
if core.get_modpath("eye_spy") then
	dofile(MP .. "/lua/eye_spy.lua")
end


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

	-- Half drawers (MTG)
	drawers.register_drawer("drawers:wood", {
		description = S("Wooden"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_wood_front_1.png",
			"drawers_wood_half.png", "drawers_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_wood_front_2.png",
			"drawers_wood_half.png", "drawers_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_wood_front_4.png",
			"drawers_wood_half.png", "drawers_wood.png"),
		groups = {choppy = 3, oddly_breakable_by_hand = 2},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 16,
		material = drawers.WOOD_ITEMSTRING
	})
	drawers.register_drawer("drawers:acacia_wood", {
		description = S("Acacia Wood"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_acacia_wood_front_1.png",
			"drawers_acacia_wood_half.png", "drawers_acacia_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_acacia_wood_front_2.png",
			"drawers_acacia_wood_half.png", "drawers_acacia_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_acacia_wood_front_4.png",
			"drawers_acacia_wood_half.png", "drawers_acacia_wood.png"),
		groups = {choppy = 3, oddly_breakable_by_hand = 2},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 16,
		material = "default:acacia_wood"
	})
	drawers.register_drawer("drawers:aspen_wood", {
		description = S("Aspen Wood"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_aspen_wood_front_1.png",
			"drawers_aspen_wood_half.png", "drawers_aspen_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_aspen_wood_front_2.png",
			"drawers_aspen_wood_half.png", "drawers_aspen_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_aspen_wood_front_4.png",
			"drawers_aspen_wood_half.png", "drawers_aspen_wood.png"),
		groups = {choppy = 3, oddly_breakable_by_hand = 2},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 16,
		material = "default:aspen_wood"
	})
	drawers.register_drawer("drawers:junglewood", {
		description = S("Junglewood"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_junglewood_front_1.png",
			"drawers_junglewood_half.png", "drawers_junglewood.png"),
		tiles2 = drawers.node_tiles_half("drawers_junglewood_front_2.png",
			"drawers_junglewood_half.png", "drawers_junglewood.png"),
		tiles4 = drawers.node_tiles_half("drawers_junglewood_front_4.png",
			"drawers_junglewood_half.png", "drawers_junglewood.png"),
		groups = {choppy = 3, oddly_breakable_by_hand = 2},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 16,
		material = "default:junglewood"
	})
	drawers.register_drawer("drawers:pine_wood", {
		description = S("Pine Wood"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_pine_wood_front_1.png",
			"drawers_pine_wood_half.png", "drawers_pine_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_pine_wood_front_2.png",
			"drawers_pine_wood_half.png", "drawers_pine_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_pine_wood_front_4.png",
			"drawers_pine_wood_half.png", "drawers_pine_wood.png"),
		groups = {choppy = 3, oddly_breakable_by_hand = 2},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 16,
		material = "default:pine_wood"
	})
elseif drawers.mcl_loaded then
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

	-- Half drawers (MCL2)
	drawers.register_drawer("drawers:oakwood", {
		description = S("Oak Wood"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_oak_wood_front_1.png",
			"drawers_oak_wood_half.png", "drawers_oak_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_oak_wood_front_2.png",
			"drawers_oak_wood_half.png", "drawers_oak_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_oak_wood_front_4.png",
			"drawers_oak_wood_half.png", "drawers_oak_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 18,
		material = drawers.WOOD_ITEMSTRING,
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:acaciawood", {
		description = S("Acacia Wood"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_acacia_wood_mcl_front_1.png",
			"drawers_acacia_wood_mcl_half.png", "drawers_acacia_wood_mcl.png"),
		tiles2 = drawers.node_tiles_half("drawers_acacia_wood_mcl_front_2.png",
			"drawers_acacia_wood_mcl_half.png", "drawers_acacia_wood_mcl.png"),
		tiles4 = drawers.node_tiles_half("drawers_acacia_wood_mcl_front_4.png",
			"drawers_acacia_wood_mcl_half.png", "drawers_acacia_wood_mcl.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 18,
		material = "mcl_core:acaciawood",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:birchwood", {
		description = S("Birch Wood"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_birch_wood_front_1.png",
			"drawers_birch_wood_half.png", "drawers_birch_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_birch_wood_front_2.png",
			"drawers_birch_wood_half.png", "drawers_birch_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_birch_wood_front_4.png",
			"drawers_birch_wood_half.png", "drawers_birch_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 18,
		material = "mcl_core:birchwood",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:darkwood", {
		description = S("Dark Oak Wood"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_dark_oak_wood_front_1.png",
			"drawers_dark_oak_wood_half.png", "drawers_dark_oak_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_dark_oak_wood_front_2.png",
			"drawers_dark_oak_wood_half.png", "drawers_dark_oak_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_dark_oak_wood_front_4.png",
			"drawers_dark_oak_wood_half.png", "drawers_dark_oak_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 18,
		material = "mcl_core:darkwood",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:junglewood", {
		description = S("Junglewood"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_junglewood_mcl_front_1.png",
			"drawers_junglewood_mcl_half.png", "drawers_junglewood_mcl.png"),
		tiles2 = drawers.node_tiles_half("drawers_junglewood_mcl_front_2.png",
			"drawers_junglewood_mcl_half.png", "drawers_junglewood_mcl.png"),
		tiles4 = drawers.node_tiles_half("drawers_junglewood_mcl_front_4.png",
			"drawers_junglewood_mcl_half.png", "drawers_junglewood_mcl.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 18,
		material = "mcl_core:junglewood",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:sprucewood", {
		description = S("Spruce Wood"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_spruce_wood_front_1.png",
			"drawers_spruce_wood_half.png", "drawers_spruce_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_spruce_wood_front_2.png",
			"drawers_spruce_wood_half.png", "drawers_spruce_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_spruce_wood_front_4.png",
			"drawers_spruce_wood_half.png", "drawers_spruce_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 18,
		material = "mcl_core:sprucewood",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})

	-- Mangrove
	drawers.register_drawer("drawers:mangrovewood", {
		description = S("Mangrove Wood"),
		tiles1 = drawers.node_tiles_front_other("drawers_mangrove_wood_front_1.png",
			"drawers_mangrove_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_mangrove_wood_front_2.png",
			"drawers_mangrove_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_mangrove_wood_front_4.png",
			"drawers_mangrove_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36,
		material = "mcl_trees:wood_mangrove",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	-- Cherry
	drawers.register_drawer("drawers:cherrywood", {
		description = S("Cherry Wood"),
		tiles1 = drawers.node_tiles_front_other("drawers_cherry_wood_front_1.png",
			"drawers_cherry_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_cherry_wood_front_2.png",
			"drawers_cherry_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_cherry_wood_front_4.png",
			"drawers_cherry_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36,
		material = "mcl_trees:wood_cherry_blossom",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	-- Bamboo
	drawers.register_drawer("drawers:bamboowood", {
		description = S("Bamboo"),
		tiles1 = drawers.node_tiles_front_other("drawers_bamboo_wood_front_1.png",
			"drawers_bamboo_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_bamboo_wood_front_2.png",
			"drawers_bamboo_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_bamboo_wood_front_4.png",
			"drawers_bamboo_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36,
		material = "mcl_trees:wood_bamboo",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	-- Crimson
	drawers.register_drawer("drawers:crimsonwood", {
		description = S("Crimson"),
		tiles1 = drawers.node_tiles_front_other("drawers_crimson_wood_front_1.png",
			"drawers_crimson_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_crimson_wood_front_2.png",
			"drawers_crimson_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_crimson_wood_front_4.png",
			"drawers_crimson_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36,
		material = "mcl_trees:wood_crimson",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	-- Warped
	drawers.register_drawer("drawers:warpedwood", {
		description = S("Warped"),
		tiles1 = drawers.node_tiles_front_other("drawers_warped_wood_front_1.png",
			"drawers_warped_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_warped_wood_front_2.png",
			"drawers_warped_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_warped_wood_front_4.png",
			"drawers_warped_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36,
		material = "mcl_trees:wood_warped",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	-- Pale Oak
	drawers.register_drawer("drawers:paleoakwood", {
		description = S("Pale Oak Wood"),
		tiles1 = drawers.node_tiles_front_other("drawers_pale_oak_wood_front_1.png",
			"drawers_pale_oak_wood.png"),
		tiles2 = drawers.node_tiles_front_other("drawers_pale_oak_wood_front_2.png",
			"drawers_pale_oak_wood.png"),
		tiles4 = drawers.node_tiles_front_other("drawers_pale_oak_wood_front_4.png",
			"drawers_pale_oak_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 36,
		material = "mcl_trees:wood_pale_oak",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})

	-- Half drawers (MCL2 extended)
	drawers.register_drawer("drawers:mangrovewood", {
		description = S("Mangrove Wood"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_mangrove_wood_front_1.png",
			"drawers_mangrove_wood_half.png", "drawers_mangrove_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_mangrove_wood_front_2.png",
			"drawers_mangrove_wood_half.png", "drawers_mangrove_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_mangrove_wood_front_4.png",
			"drawers_mangrove_wood_half.png", "drawers_mangrove_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 18,
		material = "mcl_trees:wood_mangrove",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:cherrywood", {
		description = S("Cherry Wood"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_cherry_wood_front_1.png",
			"drawers_cherry_wood_half.png", "drawers_cherry_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_cherry_wood_front_2.png",
			"drawers_cherry_wood_half.png", "drawers_cherry_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_cherry_wood_front_4.png",
			"drawers_cherry_wood_half.png", "drawers_cherry_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 18,
		material = "mcl_trees:wood_cherry_blossom",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:bamboowood", {
		description = S("Bamboo"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_bamboo_wood_front_1.png",
			"drawers_bamboo_wood_half.png", "drawers_bamboo_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_bamboo_wood_front_2.png",
			"drawers_bamboo_wood_half.png", "drawers_bamboo_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_bamboo_wood_front_4.png",
			"drawers_bamboo_wood_half.png", "drawers_bamboo_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 18,
		material = "mcl_trees:wood_bamboo",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:crimsonwood", {
		description = S("Crimson"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_crimson_wood_front_1.png",
			"drawers_crimson_wood_half.png", "drawers_crimson_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_crimson_wood_front_2.png",
			"drawers_crimson_wood_half.png", "drawers_crimson_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_crimson_wood_front_4.png",
			"drawers_crimson_wood_half.png", "drawers_crimson_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 18,
		material = "mcl_trees:wood_crimson",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:warpedwood", {
		description = S("Warped"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_warped_wood_front_1.png",
			"drawers_warped_wood_half.png", "drawers_warped_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_warped_wood_front_2.png",
			"drawers_warped_wood_half.png", "drawers_warped_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_warped_wood_front_4.png",
			"drawers_warped_wood_half.png", "drawers_warped_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 18,
		material = "mcl_trees:wood_warped",
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
	drawers.register_drawer("drawers:paleoakwood", {
		description = S("Pale Oak Wood"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_pale_oak_wood_front_1.png",
			"drawers_pale_oak_wood_half.png", "drawers_pale_oak_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_pale_oak_wood_front_2.png",
			"drawers_pale_oak_wood_half.png", "drawers_pale_oak_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_pale_oak_wood_front_4.png",
			"drawers_pale_oak_wood_half.png", "drawers_pale_oak_wood.png"),
		groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 18,
		material = "mcl_trees:wood_pale_oak",
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
	drawers.register_drawer("drawers:wood", {
		description = S("Wooden"),
		half = true,
		tiles1 = drawers.node_tiles_half("drawers_wood_front_1.png",
			"drawers_wood_half.png", "drawers_wood.png"),
		tiles2 = drawers.node_tiles_half("drawers_wood_front_2.png",
			"drawers_wood_half.png", "drawers_wood.png"),
		tiles4 = drawers.node_tiles_half("drawers_wood_front_4.png",
			"drawers_wood_half.png", "drawers_wood.png"),
		groups = {choppy = 3, oddly_breakable_by_hand = 2},
		sounds = drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 16,
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
elseif drawers.mcl_loaded then
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
-- Register drawer trim variants
--

local function register_trim(name, texture, material, desc)
	local def = {
		description = desc,
		tiles = {texture},
		is_ground_content = false,
	}
	if drawers.mcl_loaded then
		def.groups = {drawer_connector = 1, handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1}
		def._mcl_blast_resistance = 15
		def._mcl_hardness = 2
	else
		def.groups = {drawer_connector = 1, choppy = 3, oddly_breakable_by_hand = 2}
	end
	core.register_node(name, def)

	core.register_craft({
		output = name .. " 6",
		recipe = {
			{"group:stick", material, "group:stick"},
			{material,      material, material     },
			{"group:stick", material, "group:stick"}
		}
	})
end

if core.get_modpath("default") and default then
	register_trim("drawers:trim_wood",       "drawers_oak_trim.png",       "default:wood",          S("Oak Trim"))
	register_trim("drawers:trim_acacia_wood", "drawers_acacia_trim.png",   "default:acacia_wood",   S("Acacia Trim"))
	register_trim("drawers:trim_aspen_wood",  "drawers_birch_trim.png",    "default:aspen_wood",    S("Birch Trim"))
	register_trim("drawers:trim_junglewood",  "drawers_jungle_trim.png",   "default:junglewood",    S("Jungle Trim"))
	register_trim("drawers:trim_pine_wood",   "drawers_spruce_trim.png",   "default:pine_wood",     S("Spruce Trim"))
	register_trim("drawers:trim_comp",        "drawers_comp_trim.png",     "group:wood",            S("Wooden Trim"))
	-- backwards compatibility
	core.register_alias("drawers:trim", "drawers:trim_comp")
elseif drawers.mcl_loaded then
	register_trim("drawers:trim_oakwood",      "drawers_oak_trim.png",       "mcl_trees:wood_oak",            S("Oak Trim"))
	register_trim("drawers:trim_sprucewood",   "drawers_spruce_trim.png",    "mcl_trees:wood_spruce",         S("Spruce Trim"))
	register_trim("drawers:trim_birchwood",    "drawers_birch_trim.png",     "mcl_trees:wood_birch",          S("Birch Trim"))
	register_trim("drawers:trim_junglewood",   "drawers_jungle_trim.png",    "mcl_trees:wood_jungle",         S("Jungle Trim"))
	register_trim("drawers:trim_acaciawood",   "drawers_acacia_trim.png",    "mcl_trees:wood_acacia",         S("Acacia Trim"))
	register_trim("drawers:trim_darkwood",     "drawers_dark_oak_trim.png",  "mcl_trees:wood_dark_oak",       S("Dark Oak Trim"))
	register_trim("drawers:trim_mangrovewood", "drawers_mangrove_trim.png",  "mcl_trees:wood_mangrove",       S("Mangrove Trim"))
	register_trim("drawers:trim_cherrywood",   "drawers_cherry_trim.png",    "mcl_trees:wood_cherry_blossom", S("Cherry Trim"))
	register_trim("drawers:trim_bamboowood",   "drawers_bamboo_trim.png",    "mcl_trees:wood_bamboo",         S("Bamboo Trim"))
	register_trim("drawers:trim_crimsonwood",  "drawers_crimson_trim.png",   "mcl_trees:wood_crimson",        S("Crimson Trim"))
	register_trim("drawers:trim_warpedwood",   "drawers_warped_trim.png",    "mcl_trees:wood_warped",         S("Warped Trim"))
	register_trim("drawers:trim_paleoakwood",  "drawers_pale_oak_trim.png",  "mcl_trees:wood_pale_oak",       S("Pale Oak Trim"))
	register_trim("drawers:trim_comp",         "drawers_comp_trim.png",      "group:wood",                    S("Wooden Trim"))
	-- backwards compatibility
	core.register_alias("drawers:trim", "drawers:trim_oakwood")
else
	register_trim("drawers:trim_comp", "drawers_comp_trim.png", "group:wood", S("Wooden Trim"))
	-- backwards compatibility
	core.register_alias("drawers:trim", "drawers:trim_comp")
end

--
-- Register compacting drawers
--

if drawers.mcl_loaded then
	drawers.register_compacting_drawer("drawers:compacting", {
		description = S("Stone"),
		groups = {pickaxey = 1, stone = 1, building_block = 1, material_stone = 1},
		sounds = (mcl_sounds and mcl_sounds.node_sound_stone_defaults) and mcl_sounds.node_sound_stone_defaults() or drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 32,
		_mcl_blast_resistance = 30,
		_mcl_hardness = 1.5,
	})
	drawers.register_compacting_drawer("drawers:compacting", {
		description = S("Stone"),
		half = true,
		groups = {pickaxey = 1, stone = 1, building_block = 1, material_stone = 1},
		sounds = (mcl_sounds and mcl_sounds.node_sound_stone_defaults) and mcl_sounds.node_sound_stone_defaults() or drawers.WOOD_SOUNDS,
		drawer_stack_max_factor = 32,
		_mcl_blast_resistance = 30,
		_mcl_hardness = 1.5,
	})
else
	drawers.register_compacting_drawer("drawers:compacting", {
		description = S("Stone"),
		groups = {cracky = 3, level = 2},
		drawer_stack_max_factor = 32,
	})
	drawers.register_compacting_drawer("drawers:compacting", {
		description = S("Stone"),
		half = true,
		groups = {cracky = 3, level = 2},
		drawer_stack_max_factor = 32,
	})
end

if drawers.mcl_loaded then
	core.register_craft({
		output = "drawers:compacting_2",
		recipe = {
			{"mcl_core:stone", "mcl_pistons:piston_off", "mcl_core:stone"},
			{"mcl_core:stone", "group:drawer_full",      "mcl_core:stone"},
			{"mcl_core:stone", "mcl_core:iron_ingot",    "mcl_core:stone"}
		}
	})
	core.register_craft({
		output = "drawers:compacting_3",
		recipe = {
			{"mcl_core:stone", "mcl_pistons:piston_off", "mcl_core:stone"},
			{"mcl_pistons:piston_off", "group:drawer_full", "mcl_pistons:piston_off"},
			{"mcl_core:stone", "mcl_core:iron_ingot",    "mcl_core:stone"}
		}
	})
	core.register_craft({
		output = "drawers:compacting_half_2",
		recipe = {
			{"mcl_core:stone", "mcl_pistons:piston_off", "mcl_core:stone"},
			{"mcl_core:stone", "group:drawer_half",      "mcl_core:stone"},
			{"mcl_core:stone", "mcl_core:iron_ingot",    "mcl_core:stone"}
		}
	})
	core.register_craft({
		output = "drawers:compacting_half_3",
		recipe = {
			{"mcl_core:stone", "mcl_pistons:piston_off", "mcl_core:stone"},
			{"mcl_pistons:piston_off", "group:drawer_half", "mcl_pistons:piston_off"},
			{"mcl_core:stone", "mcl_core:iron_ingot",    "mcl_core:stone"}
		}
	})
end

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

