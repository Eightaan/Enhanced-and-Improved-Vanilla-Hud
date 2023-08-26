if not IEVHUD.Options:GetValue("MENU/TeamLoadout") then 
    return
end

local preU143melee = false

local function CreateWeakValuedTable()
	return setmetatable({}, {__mode = "v"})
end

local function RoundToNearest(real)
	return real >= 0 and math.floor(real + 0.5) or math.ceil(real - 0.5)
end

local set_slot_outfit_actual = TeamLoadoutItem.set_slot_outfit
function TeamLoadoutItem:set_slot_outfit(slot, criminal_name, outfit, ...)
	local player_slot = self._player_slots[slot]
	if not player_slot or not outfit or not outfit.grenade then
		return set_slot_outfit_actual(self, slot, criminal_name, outfit, ...)
	end

	set_slot_outfit_actual(self, slot, criminal_name, outfit, ...)
	local childpanels = player_slot.panel:children()
	if childpanels == nil or #childpanels == 0 then
		log("[ThrowablesInTeamLoadout] TeamLoadoutItem:set_slot_outfit() | Error: No child panels were found for slot " .. tostring(slot) .. ", aborting")
		return
	end

	local texture_hashes = {}
	local item_index = {
		primary = 1,
		primary_perks = 2,
		secondary = 3,
		secondary_perks = 4,
		melee_weapon = 5,
		armor = 6,
		deployable = 7,
		secondary_deployable = 8,
		melee_primary = -1,
		melee_secondary = -2,
		shared_skin_background = -3,
		shared_weapon = -4,
		shared_weapon_and_melee = -5,
		throwable = -90
	}
	local panels = {
		CreateWeakValuedTable(),
		CreateWeakValuedTable(),
		CreateWeakValuedTable(),
		CreateWeakValuedTable(),
		CreateWeakValuedTable(),
		CreateWeakValuedTable(),
		CreateWeakValuedTable(),
		CreateWeakValuedTable()
	}

	local managers = _G.managers
	local blackmarket_manager = managers.blackmarket
	local weaponfactorymanager = managers.weapon_factory
	local tweakdata = _G.tweak_data
	local blackmarkettweakdata = tweakdata.blackmarket

	local throwable_texture = nil
	do
		local guis_catalog = "guis/"
		local bundle_folder = blackmarkettweakdata.projectiles[outfit.grenade] and blackmarkettweakdata.projectiles[outfit.grenade].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end
		throwable_texture = guis_catalog .. "textures/pd2/blackmarket/icons/grenades/" .. outfit.grenade
	end
	if throwable_texture ~= nil then
		texture_hashes[Idstring(throwable_texture):key()] = item_index.throwable
	else
		log("[ThrowablesInTeamLoadout] TeamLoadoutItem:set_slot_outfit() | Error: Failed to determine throwable texture for slot " .. tostring(slot) .. ", aborting")
		return
	end

	local has_primary_skin = false
	local has_secondary_skin = false
	local primary_texture = nil
	local secondary_texture = nil
	if outfit.primary.factory_id then
		local primary_id = weaponfactorymanager:get_weapon_id_by_factory_id(outfit.primary.factory_id)
		local rarity = nil
		primary_texture, rarity = blackmarket_manager:get_weapon_icon_path(primary_id, outfit.primary.cosmetics)
		texture_hashes[Idstring(primary_texture):key()] = item_index.primary
		if rarity then
			texture_hashes[Idstring(rarity):key()] = item_index.primary
			has_primary_skin = true
		end
	end
	if outfit.secondary.factory_id then
		local secondary_id = weaponfactorymanager:get_weapon_id_by_factory_id(outfit.secondary.factory_id)
		local rarity = nil
		secondary_texture, rarity = blackmarket_manager:get_weapon_icon_path(secondary_id, outfit.secondary.cosmetics)
		local secondarytexturehash = Idstring(secondary_texture):key()
		if texture_hashes[secondarytexturehash] == item_index.primary then
			texture_hashes[secondarytexturehash] = item_index.shared_weapon
		else
			texture_hashes[secondarytexturehash] = item_index.secondary
		end
		if rarity then
			local rarityhash = Idstring(rarity):key()
			if texture_hashes[rarityhash] == nil then
				texture_hashes[rarityhash] = item_index.secondary
			else
				texture_hashes[rarityhash] = item_index.shared_skin_background
			end
			has_secondary_skin = true
		end
	end
	if outfit.melee_weapon then
		local guis_catalog = "guis/"
		local bundle_folder = blackmarkettweakdata.melee_weapons[outfit.melee_weapon] and blackmarkettweakdata.melee_weapons[outfit.melee_weapon].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end
		if preU143melee and outfit.melee_weapon == "weapon" then
			if primary_texture and secondary_texture then
				if primary_texture ~= secondary_texture then
					texture_hashes[Idstring(primary_texture):key()] = item_index.melee_primary
					texture_hashes[Idstring(secondary_texture):key()] = item_index.melee_secondary
				else
					texture_hashes[Idstring(primary_texture):key()] = item_index.shared_weapon_and_melee
				end
			end
		else
			texture_hashes[Idstring(guis_catalog .. "textures/pd2/blackmarket/icons/melee_weapons/" .. outfit.melee_weapon):key()] = item_index.melee_weapon
		end
	end
	if outfit.armor then
		local guis_catalog = "guis/"
		local bundle_folder = blackmarkettweakdata.armors[outfit.armor] and blackmarkettweakdata.armors[outfit.armor].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end
		texture_hashes[Idstring(guis_catalog .. "textures/pd2/blackmarket/icons/armors/" .. outfit.armor):key()] = item_index.armor
	end
	local forceprimarydeployablevisible = false
	if outfit.deployable and outfit.deployable ~= "nil" then
		local guis_catalog = "guis/"
		local bundle_folder = blackmarkettweakdata.deployables[outfit.deployable] and blackmarkettweakdata.deployables[outfit.deployable].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end
		texture_hashes[Idstring(guis_catalog .. "textures/pd2/blackmarket/icons/deployables/" .. outfit.deployable):key()] = item_index.deployable
	else
		forceprimarydeployablevisible = true
		texture_hashes[Idstring("guis/textures/pd2/none_icon"):key()] = item_index.deployable
	end
	local secondary_deployable_texture = nil
	if outfit.secondary_deployable and outfit.secondary_deployable ~= "nil" then
		if outfit.secondary_deployable ~= outfit.deployable then
			local guis_catalog = "guis/"
			local bundle_folder = blackmarkettweakdata.deployables[outfit.secondary_deployable] and blackmarkettweakdata.deployables[outfit.secondary_deployable].texture_bundle_folder
			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end
			secondary_deployable_texture = guis_catalog .. "textures/pd2/blackmarket/icons/deployables/" .. outfit.secondary_deployable
			texture_hashes[Idstring(secondary_deployable_texture):key()] = item_index.secondary_deployable
		end
	end

	local previousitemindex = 1
	for index, panel in ipairs(childpanels) do
		if panel.type_name == "Bitmap" then
			local itemindex = texture_hashes[panel:texture_name():key()]
			if itemindex == item_index.melee_primary then
				itemindex = item_index.primary
				if #panels[itemindex] > 0 then
					itemindex = item_index.melee_weapon
				end
			end
			if itemindex == item_index.melee_secondary then
				itemindex = item_index.secondary
				if #panels[itemindex] > 0 then
					itemindex = item_index.melee_weapon
				end
			end
			if itemindex == item_index.shared_skin_background then
				itemindex = item_index.primary
				if #panels[itemindex] > 1 then
					itemindex = item_index.secondary
				end
			end
			if itemindex == item_index.shared_weapon then
				itemindex = item_index.primary
				if #panels[itemindex] > 0 then
					itemindex = item_index.secondary
				end
			end
			if itemindex == item_index.shared_weapon_and_melee then
				itemindex = item_index.primary
				if #panels[itemindex] > 0 then
					itemindex = item_index.secondary
					if #panels[itemindex] > 0 then
						itemindex = item_index.melee_weapon
					end
				end
			end
			if itemindex == item_index.throwable then
				log("[ThrowablesInTeamLoadout] TeamLoadoutItem:set_slot_outfit() | Warning: Throwable icon already exists, aborting")
				return
			end
			if itemindex ~= nil and itemindex > previousitemindex then
				previousitemindex = itemindex
			end
			if itemindex == nil then
				if previousitemindex == item_index.primary then
					itemindex = item_index.primary_perks
				elseif previousitemindex == item_index.secondary then
					itemindex = item_index.secondary_perks
				end
			end
			itemindex = itemindex or previousitemindex
			table.insert(panels[itemindex], panel)
		elseif panel.type_name == "Text" then
			if previousitemindex == item_index.deployable or previousitemindex == item_index.secondary_deployable and tostring(panel:text()):sub(1, 1) == "x" then
				table.insert(panels[previousitemindex], panel)
			end
		end
	end

	local slot_h = player_slot.panel:h()
	local aspect
	local x = player_slot.panel:w() / 2
	local y = player_slot.panel:h() / 20
	local w = slot_h / 6 * 0.9
	local h = w

	if outfit.primary.factory_id then
		local primary_bitmap = panels[item_index.primary][1]
		if alive(primary_bitmap) then
			primary_bitmap:set_h(h)
			aspect = primary_bitmap:texture_width() / math.max(1, primary_bitmap:texture_height())
			primary_bitmap:set_w(primary_bitmap:h(h) * aspect)
			primary_bitmap:set_center_x(x)
			primary_bitmap:set_center_y(y * 3)
			local rarity_bitmap = panels[item_index.primary][2]
			if alive(rarity_bitmap) then
				local tw = rarity_bitmap:texture_width()
				local th = rarity_bitmap:texture_height()
				local pw = primary_bitmap:w()
				local ph = primary_bitmap:h()
				local sw = math.min(pw, ph * (tw / th))
				local sh = math.min(ph, pw / (tw / th))
				rarity_bitmap:set_size(math.round(sw), math.round(sh))
				rarity_bitmap:set_center(primary_bitmap:center())
			end
		end
		for index, perk_object in ipairs(panels[item_index.primary_perks]) do
			if alive(perk_object) then
				local perk_index = index - 3
				perk_object:set_rightbottom(math.round(primary_bitmap:right() - perk_index * 16), math.round(primary_bitmap:bottom() - 5))
			end
		end
	end
	if outfit.secondary.factory_id then
		local secondary_bitmap = panels[item_index.secondary][1]
		if alive(secondary_bitmap) then
			secondary_bitmap:set_h(h)
			aspect = secondary_bitmap:texture_width() / math.max(1, secondary_bitmap:texture_height())
			secondary_bitmap:set_w(secondary_bitmap:h() * aspect)
			secondary_bitmap:set_center_x(x)
			secondary_bitmap:set_center_y(y * 6)
			local rarity_bitmap = panels[item_index.secondary][2]
			if alive(rarity_bitmap) then
				local tw = rarity_bitmap:texture_width()
				local th = rarity_bitmap:texture_height()
				local pw = secondary_bitmap:w()
				local ph = secondary_bitmap:h()
				local sw = math.min(pw, ph * (tw / th))
				local sh = math.min(ph, pw / (tw / th))
				rarity_bitmap:set_size(math.round(sw), math.round(sh))
				rarity_bitmap:set_center(secondary_bitmap:center())
			end
		end
		for index, perk_object in ipairs(panels[item_index.secondary_perks]) do
			if alive(perk_object) then
				local perk_index = index - 3
				perk_object:set_rightbottom(math.round(secondary_bitmap:right() - perk_index * 16), math.round(secondary_bitmap:bottom() - 5))
			end
		end
	end
	if outfit.melee_weapon then
		if preU143melee and outfit.melee_weapon == "weapon" then
			if primary_texture and secondary_texture then
				local primary = panels[item_index.melee_weapon][1]
				if alive(primary) then
					primary:set_h(h * 0.75)
					aspect = primary:texture_width() / math.max(1, primary:texture_height())
					primary:set_w(primary:h() * aspect)
					primary:set_center_x(x - primary:w() * 0.25)
					primary:set_center_y(y * 9)
				end
				local secondary = panels[item_index.melee_weapon][2]
				if alive(secondary) then
					secondary:set_h(h * 0.75)
					aspect = secondary:texture_width() / math.max(1, secondary:texture_height())
					secondary:set_w(secondary:h() * aspect)
					secondary:set_center_x(x + secondary:w() * 0.25)
					secondary:set_center_y(y * 9)
				end
			end
		else
			local melee_weapon_bitmap = panels[item_index.melee_weapon][1]
			if alive(melee_weapon_bitmap) then
				melee_weapon_bitmap:set_h(h)
				aspect = melee_weapon_bitmap:texture_width() / math.max(1, melee_weapon_bitmap:texture_height())
				melee_weapon_bitmap:set_w(melee_weapon_bitmap:h() * aspect)
				melee_weapon_bitmap:set_center_x(x)
				melee_weapon_bitmap:set_center_y(y * 9)
			end
		end
	end
	if outfit.armor then
		local armor_bitmap = panels[item_index.armor][1]
		if alive(armor_bitmap) then
			armor_bitmap:set_h(h)
			aspect = armor_bitmap:texture_width() / math.max(1, armor_bitmap:texture_height())
			armor_bitmap:set_w(armor_bitmap:h() * aspect)
			armor_bitmap:set_center_x(x)
			armor_bitmap:set_center_y(y * 15)
		end
	end
	local secondary_deployable_amount = tonumber(outfit.secondary_deployable_amount) or 0
	if secondary_deployable_amount < 1 or outfit.skills == nil or outfit.skills.skills == nil or (tonumber(outfit.skills.skills[7]) or 0) < 12 then
		secondary_deployable_texture = nil
	end

	if outfit.deployable and outfit.deployable ~= "nil" or forceprimarydeployablevisible then
		local deployable_bitmap = panels[item_index.deployable][1]
		if alive(deployable_bitmap) then
			deployable_bitmap:set_h(h)
			aspect = deployable_bitmap:texture_width() / math.max(1, deployable_bitmap:texture_height())
			deployable_bitmap:set_w(deployable_bitmap:h() * aspect)
			deployable_bitmap:set_center_x(RoundToNearest(secondary_deployable_texture == nil and x or x * 0.5))
			deployable_bitmap:set_center_y(y * 18)
			local deployable_text = panels[item_index.deployable][2]
			if secondary_deployable_texture ~= nil and alive(deployable_text) then
				deployable_text:set_x(RoundToNearest(deployable_text:x() - x * 0.85))
			end
		end
	end
	if secondary_deployable_texture ~= nil and outfit.secondary_deployable and outfit.secondary_deployable ~= "nil" then
		local secondary_deployable_bitmap = panels[item_index.secondary_deployable][1]
		if not alive(secondary_deployable_bitmap) then
			secondary_deployable_bitmap = player_slot.panel:bitmap({
				texture = secondary_deployable_texture,
				w = w,
				h = h,
				rotation = math.random(2) - 1.5,
				alpha = 0.8
			})
		else
			secondary_deployable_bitmap:set_h(h)
		end
		aspect = secondary_deployable_bitmap:texture_width() / math.max(1, secondary_deployable_bitmap:texture_height())
		secondary_deployable_bitmap:set_w(secondary_deployable_bitmap:h() * aspect)
		secondary_deployable_bitmap:set_center_x(RoundToNearest(x + x * 0.3))
		secondary_deployable_bitmap:set_center_y(y * 18)
		local secondary_deployable_amount_compensated = math.ceil(secondary_deployable_amount / 2)
		if secondary_deployable_amount_compensated > 1 then
			local secondary_deployable_text = panels[item_index.secondary_deployable][2]
			if not alive(secondary_deployable_text) then
				secondary_deployable_text = player_slot.panel:text({
					text = "x" .. tostring(secondary_deployable_amount_compensated),
					font_size = tweak_data.menu.pd2_small_font_size,
					font = tweak_data.menu.pd2_small_font,
					rotation = secondary_deployable_bitmap:rotation(),
					color = tweak_data.screen_colors.text
				})
				local _, _, w, h = secondary_deployable_text:text_rect()
				secondary_deployable_text:set_size(w, h)
				secondary_deployable_text:set_rightbottom(player_slot.panel:w(), player_slot.panel:h())
				secondary_deployable_text:set_position(math.round(secondary_deployable_text:x()) - 16, math.round(secondary_deployable_text:y()) - 5)
			end
			secondary_deployable_text:set_x(RoundToNearest(secondary_deployable_text:x() - x * 0.05))
		end
	end

	do
		local grenade_bitmap = player_slot.panel:bitmap({
			texture = throwable_texture,
			w = w,
			h = h,
			rotation = math.random(2) - 1.5,
			alpha = 0.8
		})
		aspect = grenade_bitmap:texture_width() / math.max(1, grenade_bitmap:texture_height())
		grenade_bitmap:set_w(grenade_bitmap:h() * aspect)
		grenade_bitmap:set_center_x(x)
		grenade_bitmap:set_center_y(y * 12)
	end
end