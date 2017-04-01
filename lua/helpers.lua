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

function drawers.gen_info_text(basename, count, factor, stack_max)
	local maxCount = stack_max * factor
	local percent = count / maxCount * 100
	-- round the number (float -> int)
	percent = math.floor(percent + 0.5)

	return tostring(count) .. " " .. basename .. " (" .. tostring(percent) .. "% full)"
end

function drawers.get_inv_image(name)
	local texture = "drawers_empty.png"
	local def = core.registered_items[name]
	if name ~= "air" and def then
		if def.inventory_image and #def.inventory_image > 0 then
			texture = def.inventory_image
		else
			if not def.tiles then return texture end

			local c = #def.tiles or 0
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

function drawers.spawn_visual(pos)
	local node = core.get_node(pos)

	-- data for the new visual
	drawers.last_drawer_pos = pos
	drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name"))

	local bdir = core.facedir_to_dir(node.param2)
	local fdir = vector.new(-bdir.x, 0, -bdir.z)
	local pos2 = vector.add(pos, vector.multiply(fdir, 0.438))

	obj = core.add_entity(pos2, "drawers:visual")

	if bdir.x < 0 then obj:setyaw(0.5 * math.pi) end
	if bdir.z < 0 then obj:setyaw(math.pi) end
	if bdir.x > 0 then obj:setyaw(1.5 * math.pi) end

	drawers.last_texture = nil
end
