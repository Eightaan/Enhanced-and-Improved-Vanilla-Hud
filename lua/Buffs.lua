if _G.IS_VR then
	return
end

if RequiredScript == "lib/managers/hudmanagerpd2" then
	function HUDManager:set_infinite_ammo(state)
		if self._teammate_panels[self.PLAYER_PANEL]._set_infinite_ammo then
			self._teammate_panels[self.PLAYER_PANEL]:_set_infinite_ammo(state)		
		end
		-- Hides the bulletstorm display used by VHUDPlus		
		if self._teammate_panels[self.PLAYER_PANEL]._set_bulletstorm then
			self._teammate_panels[self.PLAYER_PANEL]:_set_bulletstorm(false)
		end
	end

	Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "inspire_timer_setup_player_info_hud_pd2", function(self, ...)
		self._hud_inspire_timer = HUDInspire:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
	end)

	function HUDManager:inspire_timer(buff)
		self._hud_inspire_timer:inspire_timer(buff)
	end

	HUDInspire = HUDInspire or class()
	function HUDInspire:init(hud)
		self._hud_panel = hud.panel
		self.hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
		self._inspire_panel = self.hud.panel:panel({
			name = "inspire_timer_panel",
			alpha =	1,
			visible = false,
			w = 200,
			h = 200
		})
		
		local inspire_box = HUDBGBox_create(self._inspire_panel, { w = 38, h = 38, },  {})
		if EIVHUD.Options:GetValue("HUD/TIMER/HideBox") then
			for _, child in ipairs({"bg", "left_top", "left_bottom", "right_top", "right_bottom"}) do
				inspire_box:child(child):hide()
			end
		end

		self._text = inspire_box:text({
			name = "text",
			text = "0",
			valign = "center",
			align = "center",
			vertical = "center",
			w = inspire_box:w(),
			h = inspire_box:h(),
			layer = 1,
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = tweak_data.hud_corner.numhostages_size * 0.9
		})

		local inspire_icon = self._inspire_panel:bitmap({
			name = "inspire_icon",
			texture = "guis/textures/pd2/skilltree/icons_atlas",
			texture_rect = { 4 * 64, 9 * 64, 64, 64 },
			valign = "top",
			color = Color.white,
			layer = 1,
			w = inspire_box:w(),
			h = inspire_box:h()	
		})
		inspire_icon:set_right(inspire_box:parent():w())
		inspire_icon:set_center_y(inspire_box:h() / 2)
		inspire_box:set_right(inspire_icon:left())

		self._show_hostages = EIVHUD.Options:GetValue("HUD/ShowHostages")
	end

	function HUDInspire:inspire_timer(duration)
		if duration and duration > 0.1 then
			self._inspire_panel:set_visible(true)
			self._text:stop()
			self._text:animate(function(o)
				local t_left = duration

				while true do
					t_left = t_left - coroutine.yield()
				self:update_position()
					if t_left <= 0 then
						self._inspire_panel:set_visible(false)
						break
					end

					o:set_text(string.format(
						t_left < 9.9 and "%.1f" or "%.f",
						t_left
					))
				end
			end)
		end
	end

	function HUDInspire:update_position()
		local offset = 30
		local top_pos = 22

		local hostages_panel = self._hud_panel:child("hostages_panel")
		if hostages_panel and alive(hostages_panel) and self._show_hostages == 1 then
			self._inspire_panel:set_top(hostages_panel:bottom() + offset)
			self._inspire_panel:set_right(hostages_panel:right() + (offset + top_pos))
			return
		end

		local assault_corner = managers.hud and managers.hud._hud_assault_corner
		if assault_corner and assault_corner._assault and self._show_hostages ~= 1 then
			local assault_panel = self._hud_panel:child("assault_panel")
			if assault_panel and alive(assault_panel) then
				local delay = 1.5
				self._assault_end_delay = TimerManager:game():time() + delay

				self._inspire_panel:set_top(assault_panel:bottom() - offset)
				return
			end
		end

		if self._assault_end_delay and TimerManager:game():time() < self._assault_end_delay then
			return
		end

		self._inspire_panel:set_top(top_pos)
		self._inspire_panel:set_right(self.hud.panel:w() - offset)
	end
	
elseif RequiredScript == "lib/managers/playermanager" then
	function PlayerManager:_clbk_bulletstorm_expire()
		self._infinite_ammo_clbk = nil
		managers.hud:set_infinite_ammo(false)

		if managers.player and managers.player:player_unit() and managers.player:player_unit():inventory() then
			for id, weapon in pairs(managers.player:player_unit():inventory():available_selections()) do
				managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
			end
		end
	end

	Hooks:PostHook(PlayerManager, "add_to_temporary_property", "EIVHUD_PlayerManager_add_to_temporary_property", function (self, name, time, ...)
		if EIVHUD.Options:GetValue("HUD/PLAYER/Bulletstorm") and name == "bullet_storm" and time then
			if not self._infinite_ammo_clbk then
				self._infinite_ammo_clbk = "infinite"
				managers.hud:set_infinite_ammo(true)
				managers.enemy:add_delayed_clbk(self._infinite_ammo_clbk, callback(self, self, "_clbk_bulletstorm_expire"), TimerManager:game():time() + time)
			end
		end
	end)
	
	Hooks:PostHook(PlayerManager, "disable_cooldown_upgrade", "EIVHUD_PlayerManager_disable_cooldown_upgrade", function(self, category, upgrade)
		local upgrade_value = self:upgrade_value(category, upgrade)
		if upgrade_value and upgrade_value[1] ~= 0 and EIVHUD.Options:GetValue("HUD/TIMER/Inspire") then
			managers.hud:inspire_timer(upgrade_value[2])
		end
	end)
end