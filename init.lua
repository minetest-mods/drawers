--[[
Minetest Mod Storage Drawers - A Mod adding storage drawers

Copyright (C) 2017 LNJ <git@lnj.li>

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
drawers.drawer_visuals = {}

if default then
	drawers.WOOD_SOUNDS = default.node_sound_wood_defaults()
	drawers.WOOD_ITEMSTRING = "group:wood"
	drawers.CHEST_ITEMSTRING = "default:chest"
elseif mcl_core then -- MineClone 2
	drawers.WOOD_ITEMSTRING = "group:wood"
	drawers.CHEST_ITEMSTRING = "mcl_chests:chest"
	if mcl_sounds then
		drawers.WOOD_SOUNDS = mcl_sounds.node_sound_wood_defaults()
	end
else
	drawers.WOOD_ITEMSTRING = "wood"
	drawers.CHEST_ITEMSTRING = "chest"
end


drawers.enable_1x1 = not core.setting_getbool("drawers_disable_1x1")
drawers.enable_1x2 = not core.setting_getbool("drawers_disable_1x2")
drawers.enable_2x2 = not core.setting_getbool("drawers_disable_2x2")

--
-- Load files
--

local modpath = core.get_modpath("drawers")
dofile(modpath .. "/lua/helpers.lua")
dofile(modpath .. "/lua/visual.lua")
dofile(modpath .. "/lua/api.lua")


--
-- Register drawers
--

drawers.register_drawer("drawers:wood", {
	description = "Wooden",
	tiles1 = {"drawers_wood.png", "drawers_wood.png", "drawers_wood.png",
		"drawers_wood.png", "drawers_wood.png", "drawers_wood_front_1.png"},
	tiles2 = {"drawers_wood.png", "drawers_wood.png", "drawers_wood.png",
		"drawers_wood.png", "drawers_wood.png", "drawers_wood_front_2.png"},
	tiles4 = {"drawers_wood.png", "drawers_wood.png", "drawers_wood.png",
		"drawers_wood.png", "drawers_wood.png", "drawers_wood_front_4.png"},
	groups = {choppy = 3, oddly_breakable_by_hand = 2},
	sounds = drawers.WOOD_SOUNDS,
	drawer_stack_max_factor = 3 * 8, -- normal chest size
	material = drawers.WOOD_ITEMSTRING
})
