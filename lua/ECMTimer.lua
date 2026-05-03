if RequiredScript == "lib/managers/hudmanagerpd2" then
	HUDECMCounter = HUDECMCounter or class()
	function HUDECMCounter:init(hud)
		self._ecm_timer = 0
		self._hud_panel = hud.panel
		self._ecm_panel = self._hud_panel:panel({
			name = "ecm_counter_panel",
			alpha = 1,
			visible = false,
			w = 200,
			h = 200
		})
		self._ecm_panel:set_right(self._hud_panel:w() + 11)

		local ecm_box = HUDBGBox_create(self._ecm_panel, { w = 38, h = 38, },  {})
		if EIVHUD.Options:GetValue("HUD/TIMER/HideBox") then
			for _, child in ipairs({"bg", "left_top", "left_bottom", "right_top", "right_bottom"}) do
				ecm_box:child(child):hide()
			end
		end

		self._text = ecm_box:text({
			name = "text",
			text = "0",
			valign = "center",
			align = "center",
			vertical = "center",
			w = ecm_box:w(),
			h = ecm_box:h(),
			layer = 1,
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = tweak_data.hud_corner.numhostages_size * 0.9
		})

		self._icon = self._ecm_panel:bitmap({
			name = "ecm_icon",
			texture = "guis/textures/pd2/skilltree/icons_atlas",
			texture_rect = { 1 * 64, 4 * 64, 64, 64 },
			valign = "top",
			color = Color.white,
			layer = 1,
			w = ecm_box:w(),
			h = ecm_box:h()	
		})
		self._icon:set_right(ecm_box:parent():w())
		self._icon:set_center_y(ecm_box:h() / 2)
		ecm_box:set_right(self._icon:left())
		self._ecm_box = ecm_box

		self._show_hostages = 	EIVHUD.Options:GetValue("HUD/ShowHostages")
		self._ecm_casing_end_delay = self._ecm_casing_end_delay or 0
		self._last_state = nil

		-- Change the icon textures for ecms and pagers
		local skilltree_atlas = { "guis/textures/pd2/skilltree/icons_atlas", 1 * 64, 4 * 64, 64, 64 }
		local specialization_atlas = { "guis/textures/pd2/specialization/icons_atlas", 1 * 64, 4 * 64, 64, 64 }
		self._icons = {
			ecm = skilltree_atlas,
			pager = specialization_atlas
		}

		-- Set max number of pagers
		local tweak_data_pager = tweak_data.player.alarm_pager
		local has_upgarde = managers.player:has_category_upgrade("player", "corpse_alarm_pager_bluff")
		local max_pagers_data = has_upgarde and tweak_data_pager.bluff_success_chance_w_skill or tweak_data_pager.bluff_success_chance

		local max_num_pagers = #max_pagers_data

		for i, chance in ipairs(max_pagers_data) do
			if chance == 0 then
				max_num_pagers = i - 1
				break
			end
		end
		self._max_pagers = max_num_pagers

		-- Some jobs are not set as ghostable but pagers might still be nice to see
		self._show_pagers_jobs = {
			["welcome_to_the_jungle_2"] = true,
			["mallcrasher"] = true,
			["election_day_3_skip1"] = true
		}
		-- Some jobs are set as ghostable but pagers have no meaning
		self._hide_pagers_jobs = {
			["nmh"] = true,
			["welcome_to_the_jungle_1"] = true
		
		}
		-- Set if pagers should be shown or hidden on specific levels
		local level_id = Global.game_settings.level_id
		self._show_pagers = self._show_pagers_jobs[level_id]
		self._hide_pagers = self._hide_pagers_jobs[level_id]

		self._groupai = managers.groupai and managers.groupai:state()
		self._is_ghostable = managers.job:is_level_ghostable(managers.job:current_level_id())
		self._get_pager_bluffs = self._groupai and self._groupai.get_nr_successful_alarm_pager_bluffs

		self._hostages_panel = self._hud_panel:child("hostages_panel")
		self._assault_corner = managers.hud and managers.hud._hud_assault_corner
	end

	function HUDECMCounter:update()
		local current_time = TimerManager:game():time()
		local t = self._ecm_timer - current_time

		if not self:_update_panel_position(current_time) then
			return
		end

		local state = self:_get_state(t)

		self:_apply_state(state)
		self:_update_text(state, t)
	end

	function HUDECMCounter:_update_panel_position(current_time)
		local is_stealth = self._groupai and self._groupai:whisper_mode()

		if not is_stealth then
			self._ecm_panel:set_visible(false)
			return false
		end
		self._ecm_panel:set_visible(true)

		-- Change the panel position depending on if casing is active or if the hostages are hidden in the settings
		-- Probably a better way to handle this?
		if self._hostages_panel and alive(self._hostages_panel) and self._show_hostages == 1 then
			self._ecm_panel:set_top(self._hostages_panel:bottom() + 5)
		else
			local is_casing = self._assault_corner and self._assault_corner._casing
			-- Adding a delay to let the casing box complete its closing animation, clunky but works
			local delay = 1.5

			if self._was_casing and not is_casing then
				self._ecm_casing_end_delay = current_time + delay
			end
			self._was_casing = is_casing

			local in_delay = current_time < (self._ecm_casing_end_delay or 0)
			self._ecm_panel:set_top((is_casing or in_delay) and 50 or 0)
		end

		return true
	end

	function HUDECMCounter:_get_state(t)
		-- Set the current state to switch between ecms and pagers since they use the same box
		if t > 0.1 then
			return "ecm"
		end
		-- The pagers will only show if the heist is set as ghostable or if pagers should be shown or hidden on specific levels
		local setting = EIVHUD.Options:GetValue("HUD/TIMER/ShowPagers")
		if (self._show_pagers or self._is_ghostable) and setting and not self._hide_pagers then
			return "pager"
		end

		return "none"
	end
	function HUDECMCounter:_apply_state(state)
		-- Apply the sates, change visibility and the icon position since the pager icon needs to be moved to fit the screen
		if state == self._last_state then
			return
		end

		if state == "ecm" then
			self._icon:set_image(unpack(self._icons.ecm))
			self._icon:set_right(self._ecm_box:parent():w()) 
			self._ecm_box:set_right(self._icon:left())
			self:_set_visible(true)
		elseif state == "pager" then
			self._icon:set_image(unpack(self._icons.pager))
			self._icon:set_right(self._ecm_box:parent():w() - 5) 
			self._ecm_box:set_right(self._icon:left() + 5)
			self:_set_visible(true)
		else
			self:_set_visible(false)
		end

		self._last_state = state
	end
	
	function HUDECMCounter:_set_visible(visibility)
		-- Setting the visibility is just a way to make sure the boxes hide properly based on the settings, also probably a better way to handle this
		self._ecm_box:set_visible(visibility)
		self._icon:set_visible(visibility)
		self._text:set_visible(visibility)
	end

	function HUDECMCounter:_update_text(state, t)
		-- Set the text inside the box depending on what sate we are in
		if state == "ecm" then
			self._text:set_text(string.format(t < 10 and "%.1fs" or "%.fs", t))
		elseif state == "pager" then
			local pagers_used = 0
			if self._get_pager_bluffs and self._groupai then
				pagers_used = self._get_pager_bluffs(self._groupai)
			end

			self._text:set_text(pagers_used .. "/" .. self._max_pagers)
		end
	end

	--Setup
	Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "EIVHUD_ECM_setup_player_info_hud_pd2", function(self, ...)
		self._hud_ecm_counter = HUDECMCounter:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
		self:add_updator("EIVHUD_ECM_UPDATOR", callback(self._hud_ecm_counter, self._hud_ecm_counter, "update"))
	end)

elseif RequiredScript == "lib/units/equipment/ecm_jammer/ecmjammerbase" then
	--Check if pagers will block pagers
	local original_spawn = ECMJammerBase.spawn
	function ECMJammerBase.spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id, ...)
		local unit = original_spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id, ...)
		unit:base():SetPeersID(peer_id)
		return unit
	end

	Hooks:PostHook(ECMJammerBase, "set_server_information", "EIVHUD_ECMJammerBase_set_server_information", function(self, peer_id, ...)
		self:SetPeersID(peer_id)
	end)

	Hooks:PostHook(ECMJammerBase, "sync_setup", "EIVHUD_ECMJammerBase_sync_setup", function(self, upgrade_lvl, peer_id, ...)
		self:SetPeersID(peer_id)
	end)

	Hooks:PostHook(ECMJammerBase, "set_owner", "EIVHUD_ECMJammerBase_set_owner", function(self, ...)
		self:SetPeersID(self._owner_id or 0)
	end)

	function ECMJammerBase:SetPeersID(peer_id)
		local id = peer_id or 0
		self._EIVHUD_peer_id = id
		self._EIVHUD_local_peer = id == managers.network:session():local_peer():id()
	end

	--ECM Timer Host and Client
	Hooks:PostHook(ECMJammerBase, "set_active", "EIVHUD_ECMJammerBase_set_active", function(self, active, ...)
		if active and EIVHUD.Options:GetValue("HUD/TIMER/Infoboxes") then
			local battery_life = self:battery_life()
			if battery_life == 0 then
				return
			end
			local ecm_timer = TimerManager:game():time() + battery_life
			local jam_pagers = false
			if self._EIVHUD_local_peer then
				jam_pagers = managers.player:has_category_upgrade("ecm_jammer", "affects_pagers")
			elseif self._EIVHUD_peer_id ~= 0 then
				local peer = managers.network:session():peer(self._EIVHUD_peer_id)
				if peer and peer._unit and peer._unit.base then
					jam_pagers = peer._unit:base():upgrade_value("ecm_jammer", "affects_pagers")
				end
			end
			if jam_pagers or not EIVHUD.Options:GetValue("HUD/TIMER/PagerJam") then
				managers.hud._hud_ecm_counter._ecm_timer = ecm_timer
			else
				return
			end
		end
	end)

elseif RequiredScript == "lib/units/beings/player/playerinventory" then
	-- Pocket ECM
	Hooks:PostHook(PlayerInventory, "_start_jammer_effect", "EIVHUD_PlayerInventory_start_jammer_effect", function(self, end_time, ...)
		local ecm_timer = end_time or TimerManager:game():time() + self:get_jammer_time()
		if ecm_timer > managers.hud._hud_ecm_counter._ecm_timer and EIVHUD.Options:GetValue("HUD/TIMER/Infoboxes") then
			managers.hud._hud_ecm_counter._ecm_timer = ecm_timer
		end
	end)
end