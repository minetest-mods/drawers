-- drawers/lua/eye_spy.lua
-- Integration with the eye_spy mod: shows drawer contents when pointing at
-- either the visual entity (drawers:visual) or the drawer node itself.

if not core.get_modpath("eye_spy") then
	return
end

drawers.eye_spy_loaded = true

local S = core.get_translator('drawers')

local function get_item_description(name)
	local def = core.registered_items[name]
	if def and def.description and def.description ~= "" then
		-- Take only the first line and strip Luanti escape codes
		-- (colour, translation, formatting) so only the item name remains.
		local first = def.description:match("^[^\n]*") or def.description
		local clean = first:gsub("\x1b(%([^)]*%))", ""):gsub("\x1b[%a]", "")
		if clean ~= "" then return clean end
	end
	return name
end

-- Build content_rows for a drawer at position `pos`.
local function build_drawer_content_rows(pos, node, view_model)
	local def = core.registered_nodes[node.name]
	local has_any = false
	local is_compacting = (def and def.groups.compacting_drawer or 0) > 0
	local icon_size = eye_spy.config.content_row_icon_size or 16

	view_model.content_rows = {}

	if is_compacting then
		local meta = drawers.get_compacting_meta(pos)
		if meta then
			for i = 1, meta.slots do
				local tier = meta.tiers[i]
				if tier and tier.name ~= "" and tier.rate > 0 then
					local count = math.floor(meta.pooled / tier.rate)
					if count > 0 then
						has_any = true
						local maxCount = math.floor(meta.max_pooled / tier.rate)
						local percent = math.floor(count / math.max(maxCount, 1) * 100 + 0.5)
						local desc = get_item_description(tier.name)
						-- Row 1: icon + name
						view_model.content_rows[#view_model.content_rows + 1] = {
							elements = {
								{ type = "image", texture = drawers.get_inv_image(tier.name), size = icon_size },
								{ type = "text",  text = desc, color = 0xFFFFFF, scale = 1.0 },
							}
						}
						-- Row 2: info (indented under name)
						view_model.content_rows[#view_model.content_rows + 1] = {
							elements = {
								{ type = "image", texture = "blank.png", size = icon_size },
								{ type = "text",  text = string.format("%d / %d (%d%%)", count, maxCount, percent), color = 0xAAAAAA, scale = 0.9 },
							}
						}
					end
				end
			end
		end
	else
		local drawerType = (def and def.groups.drawer) or 1
		for i = 1, drawerType do
			local vid = (drawerType == 1) and "" or tostring(i)
			local content = drawers.drawer_get_content(pos, vid)
			if content and content.count > 0 then
				has_any = true
				local percent = math.floor(content.count / math.max(content.maxCount, 1) * 100 + 0.5)
				local desc = get_item_description(content.name)
				-- Row 1: icon + name
				view_model.content_rows[#view_model.content_rows + 1] = {
					elements = {
						{ type = "image", texture = drawers.get_inv_image(content.name), size = icon_size },
						{ type = "text",  text = desc, color = 0xFFFFFF, scale = 1.0 },
					}
				}
				-- Row 2: info (indented under name)
				view_model.content_rows[#view_model.content_rows + 1] = {
					elements = {
						{ type = "image", texture = "blank.png", size = icon_size },
						{ type = "text",  text = string.format("%d / %d (%d%%)", content.count, content.maxCount, percent), color = 0xAAAAAA, scale = 0.9 },
					}
				}
			end
		end
	end

	if not has_any then
		view_model.content_rows[#view_model.content_rows + 1] = {
			elements = {
				{ type = "image", texture = "blank.png", size = icon_size },
				{ type = "text",  text = S("Empty drawer"), color = 0xAAAAAA, scale = 1.0 },
			}
		}
	end
end

-- Enricher for when the player points at the visual entity (drawers:visual).
eye_spy.enrichers.register("drawers_visual", {
	enabled = function(_, target)
		if not eye_spy.config.show_content_rows then
			return false
		end
		if target.kind ~= "entity" then
			return false
		end
		return target.name == "drawers:visual"
	end,

	takeover = true,

	apply = function(_, target, view_model)
		local ref = target.ref
		if not ref then
			return
		end

		local entity = ref:get_luaentity()
		if not entity or not entity.drawer_pos then
			return
		end

		local pos = entity.drawer_pos
		local node = core.get_node(pos)
		local def = core.registered_nodes[node.name]

		view_model.title = (def and def.description) or S("Drawer")
		view_model.title_color = 0xFFFFFF
		view_model.subtitle = ""

		local drawer_texture = drawers.get_inv_image(node.name)
		if drawer_texture and drawer_texture ~= "" and drawer_texture ~= "blank.png" then
			view_model.icon = {
				text = drawer_texture .. "^[resize:32x32",
				scale = { x = 20 / 32, y = 20 / 32 },
			}
		end

		build_drawer_content_rows(pos, node, view_model)

		eye_spy.enrichers.set_post_apply(view_model, function(vm)
			vm.subtitle = ""
		end)
	end,
})

-- Enricher for when the player points at the drawer node itself.
eye_spy.enrichers.register("drawers_node", {
	enabled = function(_, target)
		if not eye_spy.config.show_content_rows then
			return false
		end
		if target.kind ~= "node" then
			return false
		end
		local def = core.registered_nodes[target.name]
		if not def or not def.groups then
			return false
		end
		return (def.groups.drawer or 0) > 0 or (def.groups.compacting_drawer or 0) > 0
	end,

	takeover = true,

	apply = function(_, target, view_model)
		local def = core.registered_nodes[target.name]

		view_model.title = (def and def.description) or S("Drawer")
		view_model.title_color = 0xFFFFFF
		view_model.subtitle = S("Drawer")
		view_model.subtitle_color = 0xAAAAAA

		build_drawer_content_rows(target.pos, target.node or { name = target.name }, view_model)

		local drawer_texture = drawers.get_inv_image(target.name)
		if drawer_texture and drawer_texture ~= "" and drawer_texture ~= "blank.png" then
			view_model.icon = {
				text = drawer_texture .. "^[resize:32x32",
				scale = { x = 20 / 32, y = 20 / 32 },
			}
		end
	end,
})
