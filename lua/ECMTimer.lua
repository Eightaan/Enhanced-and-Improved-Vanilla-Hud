if RequiredScript == "lib/managers/hudmanagerpd2" then
	StealthPanel = StealthPanel or class()
	function StealthPanel:init(hud)
		self._ecm_timer = 0
		self._hud_panel = hud.panel
		self._stealth_panel = self._hud_panel:panel({
			name = "stealth_panel",
			alpha = 1,
			visible = false,
			w = 200,
			h = 200
		})
		self._stealth_panel:set_right(self._hud_panel:w() + 11)

		local box = HUDBGBox_create(self._stealth_panel, { w = 38, h = 38, },  {})
		if EIVHUD.Options:GetValue("HUD/TIMER/HideBox") then
			for _, child in ipairs({"bg", "left_top", "left_bottom", "right_top", "right_bottom"}) do
				box:child(child):hide()
			end
		end

		self._text = box:text({
			name = "text",
			text = "0",
			valign = "center",
			align = "center",
			vertical = "center",
			w = box:w(),
			h = box:h(),
			layer = 1,
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = tweak_data.hud_corner.numhostages_size * 0.9
		})

		self._icon = self._stealth_panel:bitmap({
			name = "icon",
			texture = "guis/textures/pd2/skilltree/icons_atlas",
			texture_rect = { 1 * 64, 4 * 64, 64, 64 },
			valign = "top",
			color = Color.white,
			layer = 1,
			w = box:w(),
			h = box:h()	
		})
		self._icon:set_right(box:parent():w())
		self._icon:set_center_y(box:h() / 2)
		box:set_right(self._icon:left())

		-- Change the icon textures for ecms and pagers
		local skilltree_atlas = { "guis/textures/pd2/skilltree/icons_atlas", 64, 4*64, 64, 64 }
		local specialization_atlas = { "guis/textures/pd2/specialization/icons_atlas", 10+64, 4*64, 64, 64 }
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
			["welcome_to_the_jungle_1"] = true,
			["firestarter_1"] = true
		
		}
		-- Set if pagers should be shown or hidden on specific levels
		local level_id = Global.game_settings.level_id
		self._show_pagers = self._show_pagers_jobs[level_id]
		self._hide_pagers = self._hide_pagers_jobs[level_id]

		self._groupai = managers.groupai and managers.groupai:state()
		self._is_ghostable = managers.job:is_level_ghostable(managers.job:current_level_id())
		self._get_pager_bluffs = self._groupai and self._groupai.get_nr_successful_alarm_pager_bluffs

		self._hostages_panel = self._hud_panel:child("hostages_panel")
		self:_refresh_pager_text()
		self:_set_panel_position(false)
	end
	
	function StealthPanel:_set_panel_position(is_casing)
		local enabled = EIVHUD.Options:GetValue("HUD/ShowHostages")
		if self._hostages_panel and alive(self._hostages_panel) and enabled == 1 then
			self._stealth_panel:set_top(self._hostages_panel:bottom() + 5)
			return
		end
		self._stealth_panel:set_top(is_casing and 50 or 0)
	end

	function StealthPanel:start_ecm_timer(end_time)
		local is_stealth = self._groupai and self._groupai:whisper_mode()

		if not is_stealth then
			return
		end
		self._ecm_active = true
		self._stealth_panel:set_visible(true)
		self._ecm_timer = end_time
		self._icon:set_image(unpack(self._icons.ecm))

		self._text:stop()
		self._text:animate(function(o)
			while alive(o) do
				local t = self._ecm_timer - TimerManager:game():time()
				if t <= 0 then
					break
				end

				o:set_text(
					string.format(
						t < 10 and "%.1fs" or "%.0fs",
						t
					)
				)

				coroutine.yield()
			end
			self._ecm_active = false
			self:_refresh_pager_text()
		end)
	end
	
	function StealthPanel:_refresh_pager_text()
		local enabled = EIVHUD.Options:GetValue("HUD/TIMER/ShowPagers")
		local is_stealth = self._groupai and self._groupai:whisper_mode()

		if not ((self._show_pagers or self._is_ghostable) and enabled and not self._hide_pagers) or not is_stealth then
			self._stealth_panel:set_visible(false)
			return
		end

		local pagers_used = 0

		if self._get_pager_bluffs and self._groupai then
			pagers_used = self._get_pager_bluffs(self._groupai)
		end

		if not self._ecm_active then
			self._icon:set_image(unpack(self._icons.pager))
		end
		self._text:set_text(pagers_used .. "/" .. self._max_pagers)
		self._stealth_panel:set_visible(true)
	end

	--Setup
	Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "EIVHUD_ECM_setup_player_info_hud_pd2", function(self, ...)
		self._hud_stealth_panel = StealthPanel:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
		--self:add_updator("EIVHUD_STEALTH_UPDATOR", callback(self._hud_stealth_panel, self._hud_stealth_panel, "update"))
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
				local end_time = TimerManager:game():time() + battery_life
				managers.hud._hud_stealth_panel:start_ecm_timer(end_time)
			else
				return
			end
		end
	end)

elseif RequiredScript == "lib/units/beings/player/playerinventory" then
	-- Pocket ECM
	Hooks:PostHook(PlayerInventory, "_start_jammer_effect", "EIVHUD_PlayerInventory_start_jammer_effect", function(self, end_time, ...)
		if not EIVHUD.Options:GetValue("HUD/TIMER/Infoboxes") then
			return
		end

		local ecm_end_time = end_time or (TimerManager:game():time() + self:get_jammer_time())
		local stealth_panel = managers.hud and managers.hud._hud_stealth_panel

		if not stealth_panel then
			return
		end

		if ecm_end_time <= (stealth_panel._ecm_timer or 0) then
			return
		end

		stealth_panel:start_ecm_timer(ecm_end_time)
	end)

elseif RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then
	Hooks:PostHook(GroupAIStateBase, "on_successful_alarm_pager_bluff", "EIVHUD_on_successful_alarm_pager_bluff", function(self)
		if not EIVHUD.Options:GetValue("HUD/TIMER/ShowPagers") then
			return
		end
		local stealth_panel = managers.hud and managers.hud._hud_stealth_panel

		if not stealth_panel then
			return
		end
		managers.hud._hud_stealth_panel:_refresh_pager_text()
	end)

	Hooks:PostHook(GroupAIStateBase, "set_whisper_mode", "EIVHUD_set_whisper_mode", function(self, enabled)
		local stealth_panel = managers.hud and managers.hud._hud_stealth_panel
		if stealth_panel and alive(stealth_panel._stealth_panel) then
			stealth_panel._stealth_panel:set_visible(enabled)
		end
	end)

elseif RequiredScript == "lib/managers/hud/hudassaultcorner" then
	Hooks:PostHook(HUDAssaultCorner, "_animate_show_casing", "EIVHUD_animate_show_casing", function(self, ...)
		local stealth_panel = managers.hud and managers.hud._hud_stealth_panel
		if stealth_panel and alive(stealth_panel._stealth_panel) then
			stealth_panel:_set_panel_position(true)
		end
	end)

	Hooks:PostHook(HUDAssaultCorner, "hide_casing", "EIVHUD_hide_casing", function(self)
		local stealth_panel = managers.hud and managers.hud._hud_stealth_panel

		if stealth_panel then
			DelayedCalls:Add("EIVHUD_CasingDelay", 1.2, function()
				if stealth_panel and alive(stealth_panel._stealth_panel) then
					stealth_panel:_set_panel_position(false)
				end
			end)
		end
	end)
end
