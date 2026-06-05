if EIVHUD.Options:GetValue("HUD/Converts") and EIVHUD.Options:GetValue("HUD/ShowHostages") == 1 then
	if RequiredScript == "lib/managers/hudmanagerpd2" then
		Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "convert_setup_player_info_hud_pd2", function(self, ...)
			self._hud_converts = HUDConverts:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
		end)

		HUDConverts = HUDConverts or class()
		function HUDConverts:init(hud)
			self._hud_panel = hud.panel
			local assault_corner = managers.hud and managers.hud._hud_assault_corner
			local waves = assault_corner and assault_corner:should_display_waves() and EIVHUD.Options:GetValue("HUD/ShowWaves") == 1
			self._parent = waves and self._hud_panel:child("wave_panel") or self._hud_panel:child("hostages_panel")

			self._convert_panel = self._hud_panel:panel({
				name = "convert_panel",
				alpha =	1,
				visible = false,
				w = 200,
				h = 200
			})
			self._convert_panel:set_right(self._parent:left())
			self._convert_panel:set_top(self._parent:top())
			
			local convert_box = HUDBGBox_create(self._convert_panel, { w = 38, h = 38, },  {})

			self._text = convert_box:text({
				name = "text",
				text = "0",
				valign = "center",
				align = "center",
				vertical = "center",
				w = convert_box:w(),
				h = convert_box:h(),
				layer = 1,
				color = Color.white,
				font = tweak_data.hud_corner.assault_font,
				font_size = tweak_data.hud_corner.numhostages_size * 0.9
			})

			local icon_scale = 6
			local convert_icon = self._convert_panel:bitmap({
				name = "convert_icon",
				texture = "guis/textures/pd2/skilltree/icons_atlas",
				texture_rect = { 6 * 64, 8 * 64, 64, 64 },
				valign = "top",
				color = Color.white,
				layer = 1,
				w = convert_box:w() - icon_scale,
				h = convert_box:h() - icon_scale
			})
			convert_icon:set_right(convert_box:parent():w())
			convert_icon:set_center_y(convert_box:h() / 2)
			convert_box:set_right(convert_icon:left())
			self:change_position()
		end
		
		function HUDConverts:_refresh_minion_text()
			self:change_visibility()
			local converts = managers.player:has_category_upgrade("player", "convert_enemies")
			if not converts then
				return
			end
			self._text:set_text(tostring(managers.player:num_local_minions()))
			self._convert_panel:set_right(self._parent:left())
			self._convert_panel:set_top(self._parent:top())
		end

		function HUDConverts:change_position()
			if alive(self._convert_panel) then
				self._convert_panel:stop()
				self._convert_panel:animate(callback(self, self, "_follow_hostages"))
			end
		end
		
		function HUDConverts:change_visibility()
			local is_stealth = managers.groupai and managers.groupai:state():whisper_mode()
			local converts = managers.player:has_category_upgrade("player", "convert_enemies")
			local hostage_panel = self._hud_panel:child("hostages_panel")
			local hostages_visible = alive(hostage_panel) and hostage_panel:visible()
			local show_converts = hostages_visible and converts and not is_stealth or false
			if alive(self._convert_panel) then
				self._convert_panel:set_visible(show_converts)
			end
		end

		function HUDConverts:_follow_hostages(panel)
			local t = 0
			local duration = 0.2

			while t < duration do
				local dt = coroutine.yield()
				t = t + dt

				if alive(self._parent) then
					panel:set_right(self._parent:left())
					panel:set_top(self._parent:top())
				end
			end

			if alive(self._parent) then
				panel:set_right(self._parent:left())
				panel:set_top(self._parent:top())
			end
		end

	elseif RequiredScript == "lib/managers/playermanager" then
		Hooks:PostHook(PlayerManager, "count_up_player_minions", "EIVHUD_count_up_player_minions", function(self)
			if managers.hud and managers.hud._hud_converts then
				managers.hud._hud_converts:_refresh_minion_text()
			end
		end)

		Hooks:PostHook(PlayerManager, "count_down_player_minions", "EIVHUD_count_down_player_minions", function(self)
			if managers.hud and managers.hud._hud_converts then
				managers.hud._hud_converts:_refresh_minion_text()
			end
		end)

	elseif RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then

	Hooks:PostHook(GroupAIStateBase, "set_whisper_mode", "EIVHUD_convert_set_whisper_mode", function(self, enabled)
		if managers.hud and managers.hud._hud_converts and not enabled then
			managers.hud._hud_converts:_refresh_minion_text()
		end
	end)

	elseif RequiredScript == "lib/managers/hud/hudassaultcorner" then		
		Hooks:PostHook(HUDAssaultCorner, "_set_hostage_offseted", "EIVHUD_follow_hostage_panel", function(self, is_offseted)
			if managers.hud and managers.hud._hud_converts then
				managers.hud._hud_converts:change_position()
			end
		end)

		Hooks:PostHook(HUDAssaultCorner, "show_point_of_no_return_timer", "EIVHUD_show_point_of_no_return_timer", function(self, ...)
			if managers.hud and managers.hud._hud_converts then
				managers.hud._hud_converts:change_visibility()
			end
		end)

		Hooks:PostHook(HUDAssaultCorner, "hide_point_of_no_return_timer", "EIVHUD_hide_point_of_no_return_timer", function(self, ...)
			if managers.hud and managers.hud._hud_converts then
				managers.hud._hud_converts:change_visibility()
			end
		end)
	end
end