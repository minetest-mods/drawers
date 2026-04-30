-- Compacting Drawers logic for Luanti / Mineclonia
-- Compacting drawer tier logic

local S = core.get_translator('drawers')

-- Static tier registry: lower -> higher conversion rules for Mineclonia
local static_rules = {
	{lower = "mcl_core:clay_ball",           higher = "mcl_core:clay",                rate = 4},
	{lower = "mcl_core:snowball",            higher = "mcl_core:snow",                rate = 4},
	{lower = "mcl_core:glowstone_dust",      higher = "mcl_core:glowstone",           rate = 4},
	{lower = "mcl_core:brick",               higher = "mcl_core:brick_block",         rate = 4},
	{lower = "mcl_nether:nether_brick",      higher = "mcl_nether:nether_bricks",     rate = 4},
	{lower = "mcl_nether:nether_wart_item",  higher = "mcl_nether:nether_wart_block", rate = 9},
	{lower = "mcl_core:quartz",              higher = "mcl_core:quartz_block",        rate = 4},
	{lower = "mcl_farming:melon_slice",      higher = "mcl_melon:melon",              rate = 9},
	{lower = "mcl_bamboo:bamboo",            higher = "mcl_bamboo:bamboo_block",      rate = 9},
	{lower = "mcl_core:iron_nugget",         higher = "mcl_core:iron_ingot",          rate = 9},
	{lower = "mcl_core:iron_ingot",          higher = "mcl_core:ironblock",           rate = 9},
	{lower = "mcl_core:gold_nugget",         higher = "mcl_core:gold_ingot",          rate = 9},
	{lower = "mcl_core:gold_ingot",          higher = "mcl_core:goldblock",           rate = 9},
	{lower = "mcl_copper:copper_ingot",      higher = "mcl_copper:copper_block",      rate = 9},
	{lower = "mcl_core:diamond",             higher = "mcl_core:diamondblock",        rate = 9},
	{lower = "mcl_core:emerald",             higher = "mcl_core:emeraldblock",        rate = 9},
	{lower = "mcl_redstone:redstone",        higher = "mcl_redstone:redstone_block",  rate = 9},
	{lower = "mcl_core:coal_lump",           higher = "mcl_core:coalblock",           rate = 9},
	{lower = "mcl_core:lapis",               higher = "mcl_core:lapisblock",          rate = 9},
	{lower = "mcl_nether:netherite_ingot",   higher = "mcl_nether:netherite_block",   rate = 9},
	{lower = "mcl_farming:wheat_item",       higher = "mcl_farming:hay_block",        rate = 9},
	{lower = "mcl_raw_ores:raw_iron",        higher = "mcl_raw_ores:raw_iron_block",  rate = 9},
	{lower = "mcl_raw_ores:raw_gold",        higher = "mcl_raw_ores:raw_gold_block",  rate = 9},
	{lower = "mcl_raw_ores:raw_copper",      higher = "mcl_raw_ores:raw_copper_block",rate = 9},
	{lower = "mcl_mobitems:slimeball",       higher = "mcl_core:slimeblock",          rate = 9},
	{lower = "mcl_bone_meal:bone_meal",      higher = "mcl_core:bone_block",          rate = 9},
	{lower = "mcl_ocean:dried_kelp",         higher = "mcl_ocean:dried_kelp_block",   rate = 9},
	{lower = "mcl_potions:awkward",          higher = "mcl_potions:awkward_splash",   rate = 1},
}

drawers.compact_tiers = {}

function drawers.init_compact_tiers()
	for _, rule in ipairs(static_rules) do
		if not drawers.compact_tiers[rule.lower] then
			drawers.compact_tiers[rule.lower] = {}
		end
		drawers.compact_tiers[rule.lower].higher = rule.higher
		drawers.compact_tiers[rule.lower].rate   = rule.rate

		if not drawers.compact_tiers[rule.higher] then
			drawers.compact_tiers[rule.higher] = {}
		end
		drawers.compact_tiers[rule.higher].lower = rule.lower
		drawers.compact_tiers[rule.higher].rate   = rule.rate
	end
end

-- Cache for discovered tier chains
local tier_cache = {}

local function find_higher_tier(item_name)
	-- 1. Static registry
	local st = drawers.compact_tiers[item_name]
	if st and st.higher then
		return {name = st.higher, rate = st.rate}
	end

	-- 2. Auto-discovery 3x3
	local items_3 = {}
	for i = 1, 9 do items_3[i] = ItemStack(item_name) end
	local ok3, result3 = pcall(core.get_craft_result, {method = "normal", width = 3, items = items_3})
	if ok3 and result3 and result3.item and not result3.item:is_empty() then
		local inv_items = {result3.item}
		local ok_inv, inv_result = pcall(core.get_craft_result, {method = "normal", width = 1, items = inv_items})
		if ok_inv and inv_result and inv_result.item and inv_result.item:get_name() == item_name then
			return {name = result3.item:get_name(), rate = 9}
		end
	end

	-- 3. Auto-discovery 2x2
	local items_2 = {}
	for i = 1, 4 do items_2[i] = ItemStack(item_name) end
	local ok2, result2 = pcall(core.get_craft_result, {method = "normal", width = 2, items = items_2})
	if ok2 and result2 and result2.item and not result2.item:is_empty() then
		local inv_items = {result2.item}
		local ok_inv, inv_result = pcall(core.get_craft_result, {method = "normal", width = 1, items = inv_items})
		if ok_inv and inv_result and inv_result.item and inv_result.item:get_name() == item_name then
			return {name = result2.item:get_name(), rate = 4}
		end
	end

	return nil
end

local function find_lower_tier(item_name)
	-- 1. Static registry
	local st = drawers.compact_tiers[item_name]
	if st and st.lower then
		return {name = st.lower, rate = st.rate}
	end

	-- 2. Auto-discovery via get_all_craft_recipes
	local ok_recipes, recipes = pcall(core.get_all_craft_recipes, item_name)
	if not ok_recipes or not recipes then return nil end

	for _, recipe in ipairs(recipes) do
		if recipe.type == "normal" and (recipe.width == 2 or recipe.width == 3) then
			local uniform = true
			local first_item = nil
			local count = 0
			for _, ri in ipairs(recipe.items) do
				if ri ~= "" then
					count = count + 1
					if not first_item then
						first_item = ri
					elseif first_item ~= ri then
						uniform = false
						break
					end
				end
			end

			if uniform and first_item and (count == 4 or count == 9) then
				local check_items = {}
				for i = 1, count do check_items[i] = ItemStack(first_item) end
				local width = count == 4 and 2 or 3
				local ok_check, check_result = pcall(core.get_craft_result, {
					method = "normal",
					width = width,
					items = check_items
				})
				if ok_check and check_result and check_result.item
				   and check_result.item:get_name() == item_name then
					return {name = first_item, rate = count}
				end
			end
		end
	end

	return nil
end

-- Build a tier chain for an item
-- Returns a table: { [1] = {name="block", rate=81}, [2] = {name="ingot", rate=9}, [3] = {name="nugget", rate=1} }
-- Slot 1 is always the highest visible tier; rates are cumulative from the lowest tier = 1.
function drawers.find_compact_tiers(item_name, slot_count)
	local cache_key = item_name .. "#" .. slot_count
	if tier_cache[cache_key] then
		return tier_cache[cache_key]
	end

	-- Build upward chain from pivot
	local upward_stack = {}
	local current = item_name
	for i = 1, slot_count - 1 do
		local higher = find_higher_tier(current)
		if not higher then break end
		table.insert(upward_stack, higher)
		current = higher.name
	end

	-- Build slots from discovered tiers
	local names = {}
	local rates = {}
	local index = 1

	-- Upward: pop from stack (highest first)
	for i = #upward_stack, 1, -1 do
		local result = upward_stack[i]
		names[index] = result.name
		rates[index] = result.rate
		-- Multiply all LOWER rates by this result's conversion size
		for j = 1, index - 1 do
			rates[j] = rates[j] * result.rate
		end
		index = index + 1
	end

	-- Pivot
	names[index] = item_name
	rates[index] = 1
	index = index + 1

	-- Downward
	current = item_name
	for i = index, slot_count do
		local lower = find_lower_tier(current)
		if lower and lower.name ~= "" then
			names[index] = lower.name
			rates[index] = 1
			-- Multiply all HIGHER rates by this lower's conversion size
			for j = 1, index - 1 do
				rates[j] = rates[j] * lower.rate
			end
			index = index + 1
			current = lower.name
		else
			names[index] = ""
			rates[index] = 0
			index = index + 1
		end
	end

	local result = {}
	for i = 1, slot_count do
		result[i] = {name = names[i] or "", rate = rates[i] or 0}
	end

	tier_cache[cache_key] = result
	return result
end

-- Helper to get compacting drawer meta values
function drawers.get_compacting_meta(pos)
	local meta = core.get_meta(pos)
	local node = core.get_node(pos)
	local ndef = core.registered_nodes[node.name]
	local slots = ndef.groups.compacting_drawer or 2

	local tiers = {}
	for i = 1, slots do
		tiers[i] = {
			name = meta:get_string("comp_name_" .. i),
			rate = meta:get_int("comp_rate_" .. i),
		}
	end

	return {
		slots = slots,
		pooled = meta:get_int("comp_pooled_count"),
		max_pooled = meta:get_int("comp_max_pooled"),
		tiers = tiers,
	}
end

-- Update all compacting visuals at a position after pooled count changes
function drawers.update_compacting_visuals(pos)
	local drawer_visuals = drawers.drawer_visuals[core.hash_node_position(pos)]
	if not drawer_visuals then return end
	local meta = core.get_meta(pos)
	local pooled = meta:get_int("comp_pooled_count")
	local max_pooled = meta:get_int("comp_max_pooled")

	for _, visual in pairs(drawer_visuals) do
		if visual.is_compacting then
			visual.pooledCount = pooled
			-- Reload per-slot data from meta (needed when drawer was empty and
			-- got initialized by a click on a different visual slot)
			local slot = visual.compSlot or 1
			visual.itemName = meta:get_string("comp_name_" .. slot)
			visual.convRate = meta:get_int("comp_rate_" .. slot)
			visual.itemStackMax = meta:get_int("comp_stack_max_" .. slot)
			if visual.itemStackMax == 0 then visual.itemStackMax = 64 end
			if visual.convRate > 0 then
				visual.count = math.floor(pooled / visual.convRate)
				visual.maxCount = math.floor(max_pooled / visual.convRate)
				visual.stackMaxFactor = math.floor(visual.maxCount / visual.itemStackMax)
			else
				visual.count = 0
				visual.maxCount = 0
			end
			visual:updateInfotext()
			visual:updateTexture()
		end
	end
end

-- Construct
function drawers.compacting_on_construct(pos)
	local node = core.get_node(pos)
	local ndef = core.registered_nodes[node.name]
	local slots = ndef.groups.compacting_drawer or 2
	local factor = ndef.drawer_stack_max_factor or 32

	local meta = core.get_meta(pos)
	meta:set_int("comp_pooled_count", 0)
	meta:set_int("comp_max_pooled", 64 * factor) -- base rate=1, will be recalculated on first insert

	for i = 1, slots do
		meta:set_string("comp_name_" .. i, "")
		meta:set_int("comp_rate_" .. i, 0)
		meta:set_int("comp_stack_max_" .. i, 64)
		meta:set_string("entity_infotext_" .. i, drawers.gen_info_text(S("Empty"), 0, factor, 64))
	end

	meta:get_inventory():set_size("upgrades", 5)
	meta:set_string("formspec", drawers.drawer_formspec)

	drawers.spawn_visuals(pos)
end

-- Destruct
function drawers.compacting_on_destruct(pos)
	drawers.remove_visuals(pos)
	if drawers.drawer_visuals[core.hash_node_position(pos)] then
		drawers.drawer_visuals[core.hash_node_position(pos)] = nil
	end
end

-- Dig: drop upgrades + decompose pooled count into items intelligently
function drawers.compacting_on_dig(pos, node, player)
	local name = player and player:get_player_name() or ""
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return false
	end

	local meta = core.get_meta(pos)
	local inv = player and player:get_inventory()
	local slots = core.get_item_group(node.name, "compacting_drawer") or 2

	local function give_or_drop(stack)
		if stack:is_empty() then return end
		local leftover = stack
		if inv then
			leftover = inv:add_item("main", stack)
		end
		if not leftover:is_empty() then
			if player then
				core.item_drop(leftover, player, drawers.randomize_pos(pos))
			else
				core.add_item(drawers.randomize_pos(pos), leftover)
			end
		end
	end

	-- Drop upgrades
	local upgrade_inv = meta:get_inventory()
	local upgrades = upgrade_inv:get_list("upgrades")
	if upgrades then
		for _, stack in ipairs(upgrades) do
			give_or_drop(stack)
		end
	end

	-- Drop contents: decompose pooled count from highest tier downward
	local pooled = meta:get_int("comp_pooled_count")
	for i = 1, slots do
		local item_name = meta:get_string("comp_name_" .. i)
		local rate = meta:get_int("comp_rate_" .. i)
		if item_name ~= "" and rate > 0 then
			local stack_max = ItemStack(item_name):get_stack_max()
			local extractable = math.floor(pooled / rate)
			while extractable > 0 do
				local batch = math.min(extractable, stack_max)
				local stack = ItemStack(item_name)
				stack:set_count(batch)
				give_or_drop(stack)
				pooled = pooled - batch * rate
				extractable = math.floor(pooled / rate)
			end
		end
	end

	core.node_dig(pos, node, player)
end

-- Register a compacting drawer type
function drawers.register_compacting_drawer(name, def)
	def.description = def.description or S("Compacting Drawer")
	def.drawtype = "nodebox"
	def.groups = def.groups or {}
	def.is_ground_content = false
	def.drawer_stack_max_factor = def.drawer_stack_max_factor or 32

	local is_half = def.half == true
	local suffix = is_half and "_half" or ""

	if is_half then
		def.node_box = {type = "fixed", fixed = drawers.node_box_half}
		def.collision_box = {type = "fixed", fixed = drawers.node_box_half}
		def.selection_box = {type = "fixed", fixed = drawers.node_box_half}
		def.groups.drawer_half = 1
	else
		def.node_box = {type = "fixed", fixed = drawers.node_box_simple}
		def.collision_box = {type = "regular"}
		def.selection_box = {type = "fixed", fixed = drawers.node_box_simple}
	end

	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.legacy_facedir_simple = true

	def.on_construct = drawers.compacting_on_construct
	def.on_destruct = drawers.compacting_on_destruct
	def.on_dig = drawers.compacting_on_dig
	def.allow_metadata_inventory_put = drawers.drawer_allow_metadata_inventory_put
	def.allow_metadata_inventory_take = drawers.drawer_allow_metadata_inventory_put
	def.on_metadata_inventory_put = drawers.add_drawer_upgrade
	def.on_metadata_inventory_take = drawers.remove_drawer_upgrade

	if core.get_modpath("screwdriver") and screwdriver then
		def.on_rotate = function(pos, node, user, mode, new_param2)
			if mode ~= screwdriver.ROTATE_FACE then
				return false
			end
			node.param2 = new_param2
			core.swap_node(pos, node)
			drawers.remove_visuals(pos)
			drawers.spawn_visuals(pos)
			return true
		end
	end

	if core.get_modpath("pipeworks") and pipeworks then
		def.groups.tubedevice = 1
		def.groups.tubedevice_receiver = 1
		def.tube = def.tube or {}
		def.tube.insert_object = def.tube.insert_object or drawers.drawer_insert_object_from_tube
		def.tube.can_insert = def.tube.can_insert or drawers.drawer_can_insert_stack_from_tube
		def.tube.connect_sides = {left = 1, right = 1, back = 1, top = 1, bottom = 1}
		def.after_place_node = pipeworks.after_place
		def.after_dig_node = pipeworks.after_dig
	end

	local has_mesecons_mvps = core.get_modpath("mesecons_mvps")

	for _, slot_count in ipairs({2, 3}) do
		local d = table.copy(def)
		if is_half then
			d.drawer_stack_max_factor = math.floor((def.drawer_stack_max_factor or 32) / 2)
		end
		if slot_count == 2 then
			d.description = is_half
				and S("@1 Half Compacting Drawer (2 Tier)", def.description)
				or  S("@1 Compacting Drawer (2 Tier)", def.description)
			d.tiles = drawers.node_tiles_front_other("drawers_comp2_front.png", "drawers_comp_side.png")
		else
			d.description = is_half
				and S("@1 Half Compacting Drawer (3 Tier)", def.description)
				or  S("@1 Compacting Drawer (3 Tier)", def.description)
			d.tiles = drawers.node_tiles_front_other("drawers_comp3_front.png", "drawers_comp_side.png")
		end
		d.groups.drawer = slot_count
		d.groups.compacting_drawer = slot_count
		core.register_node(name .. suffix .. "_" .. slot_count, d)
		if has_mesecons_mvps then
			mesecon.register_mvps_stopper(name .. suffix .. "_" .. slot_count)
		end
	end
end

-- Initialize static tier registry on mod load
drawers.init_compact_tiers()
