if _G.IS_VR then
	return
end

local Color = Color

if RequiredScript == "lib/managers/hudmanagerpd2" then
	Hooks:PostHook(HUDManager, "set_stamina_value", "EIVHUD_HUDManager_set_stamina_value", function (self, value, ...)
		if EIVHUD.Options:GetValue("HUD/PLAYER/Stamina") and self._teammate_panels[self.PLAYER_PANEL].set_stamina_current then --VHUDPlus Compatibility
			self._teammate_panels[self.PLAYER_PANEL]:set_stamina_current(value)
		elseif self._teammate_panels[self.PLAYER_PANEL].set_stamina_visibility then --VHUDPlus Compatibility
			self._teammate_panels[self.PLAYER_PANEL]:set_stamina_visibility(false)
		end
	end)

	Hooks:PostHook(HUDManager, "set_max_stamina", "EIVHUD_HUDManager_set_max_stamina", function (self, value, ...)
		if EIVHUD.Options:GetValue("HUD/PLAYER/Stamina") and self._teammate_panels[self.PLAYER_PANEL] then --VHUDPlus Compatibility
			self._teammate_panels[self.PLAYER_PANEL]:set_stamina_max(value)
		end
	end)

	function HUDManager:animate_invulnerability(duration)
		if self._teammate_panels[self.PLAYER_PANEL]._animate_invulnerability then
			self._teammate_panels[self.PLAYER_PANEL]:_animate_invulnerability(duration)		
		end
	end

	function HUDManager:update_cooldown_timer(duration)
		if self._teammate_panels[self.PLAYER_PANEL]._update_cooldown_timer then
			self._teammate_panels[self.PLAYER_PANEL]:_update_cooldown_timer(duration)		
		end
	end

	function HUDManager:health_cooldown_timer(duration)
		if self._teammate_panels[self.PLAYER_PANEL]._health_cooldown_timer then
			self._teammate_panels[self.PLAYER_PANEL]:_health_cooldown_timer(duration)		
		end
	end

	function HUDManager:animate_health_invulnerability(duration)
		if self._teammate_panels[self.PLAYER_PANEL]._animate_health_invulnerability then
			self._teammate_panels[self.PLAYER_PANEL]:_animate_health_invulnerability(duration)		
		end
	end	

elseif RequiredScript == "lib/managers/playermanager" then
	Hooks:PreHook(PlayerManager, "activate_temporary_upgrade", "activate_temporary_upgrade_armor_timer", function (self, category, upgrade)
		if upgrade == "armor_break_invulnerable" then
			local upgrade_value = self:upgrade_value(category, upgrade)
			if upgrade_value == 0 then return end

			if EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") and EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownRadial") then
				managers.hud:update_cooldown_timer(upgrade_value[2])
			end
			if EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownRadial") then
				managers.hud:animate_invulnerability(upgrade_value[1])
			end
		end
		if upgrade == "mrwi_health_invulnerable" then
			local upgrade_value = self:upgrade_value(category, upgrade)
			if upgrade_value == 0 then return end

			if EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") and EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownRadial") then
				managers.hud:health_cooldown_timer(2)
			end
			if EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownRadial") then
				managers.hud:animate_health_invulnerability(2)
			end
		end
	end)
	
elseif RequiredScript == "lib/managers/hud/hudteammate" then
	Hooks:PostHook(HUDTeammate, "init", "EIVHUD_Stamina_init", function (self, ...)
		if self._main_player then
			self:_create_circle_stamina()
		end
		self._invulnerability = false
		self._armor_time_left = 0
		self._grace_time_left = 0
	end)
	
	function HUDTeammate:_create_circle_stamina()
		local radial_health_panel = self._panel:child("player"):child("radial_health_panel")
		self._stamina_circle = radial_health_panel:bitmap({
			name = "radial_stamina",
			texture = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_fg",
			render_template = "VertexColorTexturedRadial",
			w = radial_health_panel:w() * 0.7,
			visible = true,
			h = radial_health_panel:h() * 0.7,
			layer = 3,
		})
		self._stamina_circle:set_center(radial_health_panel:child("radial_health"):center())
	end
	
	Hooks:PostHook(HUDTeammate, "set_custom_radial", "EIVHUD_HUDTeammate_set_custom_radial", function (self, data, ...)
		local duration = data.current / data.total
		local aced = managers.player:upgrade_level("player", "berserker_no_ammo_cost", 0) == 1

		if self._main_player and EIVHUD.Options:GetValue("HUD/PLAYER/Bulletstorm") and aced then
			if duration > 0 then
				managers.hud:set_infinite_ammo(true)
			else
				managers.hud:set_infinite_ammo(false)
			end
		end
		
		if self._main_player and self._cooldown_timer and self._invulnerability then
			if duration > 0 then
				self._cooldown_timer:set_visible(false)
				self._cooldown_health_timer:set_visible(false)
				if self._radial_health_panel:child("radial_armor") then
					self._radial_health_panel:child("radial_armor"):set_alpha(0)
					self._radial_health_panel:child("animate_health_circle"):set_alpha(0)
				end
			else
				self._cooldown_timer:set_visible(self._armor_invulnerability_timer)
				self._cooldown_health_timer:set_visible(self._health_timer)


				if self._radial_health_panel:child("radial_armor") then
					self._radial_health_panel:child("radial_armor"):set_alpha(1)
					self._radial_health_panel:child("animate_health_circle"):set_alpha(1)
				end
			end
		end
	end)

	Hooks:PostHook(HUDTeammate, "_create_condition", "EIVHUD_HUDTeammate_create_condition", function (self, ...)
		self._health_panel = self._health_panel or self._player_panel:child("radial_health_panel")
		if self._main_player then
			self._cooldown_timer = self._health_panel:text({
				name = "cooldown_timer",
				text = "",
				color = Color.white,
				visible = false,
				align = "center",
				vertical = "center",
				font = tweak_data.menu.pd2_large_font,
				font_size = 20,
				alpha = 1,
				layer = 4
			})
			self._cooldown_health_timer = self._health_panel:text({
				name = "cooldown_health_timer",
				text = "",
				color = Color.white,
				visible = false,
				align = "center",
				vertical = "center",
				font = tweak_data.menu.pd2_large_font,
				font_size = 20,
				alpha = 1,
				layer = 4
			})
		end
	end)

	Hooks:PreHook(HUDTeammate, "_create_radial_health", "_create_radial_health_armor_radial", function (self, radial_health_panel)
		self._radial_health_panel = radial_health_panel
		local radial_armor = radial_health_panel:bitmap({
			texture = "guis/textures/pd2/hud_swansong",
			name = "radial_armor",
			blend_mode = "add",
			visible = false,
			render_template = "VertexColorTexturedRadial",
			layer = 5,
			color = Color(1, 0, 0, 0),
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})
		local animate_health_circle = radial_health_panel:bitmap({
			texture = "EIVHUD/animate_health_circle",
			name = "animate_health_circle",
			blend_mode = "add",
			visible = false,
			render_template = "VertexColorTexturedRadial",
			layer = 5,
			color = Color(1, 0, 0, 0),
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})
	end)

	function HUDTeammate:_update_cooldown_timer(t)
		local timer = self._cooldown_timer
		if t and t > 1 and timer then
			self._invulnerability = true
			timer:stop()
			self._armor_time_left = 0
			if self._stamina_circle then
				self._stamina_circle:set_alpha(0)
			end
			timer:animate(function(o)
				local t_left = t
				while t_left >= 0.1 do
					self._armor_invulnerability_timer = true
					t_left = t_left - coroutine.yield()
					self._armor_time_left = t_left
					if self._grace_time_left <= 0 or t_left <= self._grace_time_left then
						o:set_visible(true)
						self._cooldown_health_timer:set_visible(false)
						local t_format = t_left < 9.9 and "%.1f" or "%.f"
						o:set_text(string.format(t_format, t_left))
						o:set_color(EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimerColor") or Color.blue)
					else
						o:set_visible(false)
					end
				end
				self._armor_time_left = 0
				self._armor_invulnerability_timer = false
				o:set_visible(false)
				self._stamina_circle:set_alpha(not self._health_timer and 1 or 0)
			end)
		end
	end

	function HUDTeammate:_animate_invulnerability(duration)
		if not self._radial_health_panel:child("radial_armor") then return end
		self._invulnerability = true
		self._radial_health_panel:child("radial_armor"):animate(function (o)
			o:set_color(Color(1, 1, 1, 1))
			self._stamina_circle:set_alpha(0)
			self._armor_invulnerability_timer = true


			o:set_visible(true)
			over(duration, function (p)
				o:set_color(Color(1, 1 - p, 1, 1))
			end)
			if not EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") then
				self._stamina_circle:set_alpha(1) 
				self._armor_invulnerability_timer = false
			end
			o:set_visible(false)
		end)
	end
	
	function HUDTeammate:_health_cooldown_timer(t)
		local timer = self._cooldown_health_timer
		if t and t > 1 and timer then
			self._invulnerability = true
			timer:stop()
			self._grace_time_left = 0
			if self._stamina_circle then
				self._stamina_circle:set_alpha(0)
			end
			timer:animate(function(o)
				local t_left = t + 13
				while t_left >= 0.1 do
					self._health_timer = true
					t_left = t_left - coroutine.yield()
					self._grace_time_left = t_left
					if self._armor_time_left <= 0 or t_left < self._armor_time_left then
						o:set_visible(true)
						self._cooldown_timer:set_visible(false)

						local t_format = t_left < 9.9 and "%.1f" or "%.f"
						o:set_text(string.format(t_format, t_left))
						o:set_color(EIVHUD.Options:GetValue("HUD/PLAYER/GraceCooldownTimerColor") or Color.green)
					else
						o:set_visible(false)
					end
				end

				self._grace_time_left = 0
				self._health_timer = false

				o:set_visible(false)

				self._stamina_circle:set_alpha(not self._armor_invulnerability_timer and 1 or 0)
			end)
		end
	end
	
	function HUDTeammate:_animate_health_invulnerability(duration)
		if not self._radial_health_panel:child("animate_health_circle") then return end
		self._invulnerability = true
		self._radial_health_panel:child("animate_health_circle"):animate(function (o)

			o:set_color(Color(1, 1, 1, 1))
			self._radial_health_panel:child("animate_health_circle"):set_alpha(1)
			self._stamina_circle:set_alpha(0)
			self._health_timer = true

			o:set_visible(true)
			over(duration, function (p)
				o:set_color(Color(1, 1 - p, 1, 1))
			end)
			o:set_visible(false)
			if not EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") then
				if not (self._armor_invulnerability_timer or self._injector_active or self._active_ability) then
					self._stamina_circle:set_alpha(1)
				end
				self._health_timer = false

			end
			o:set_visible(false)
		end)
	end
	
	function HUDTeammate:set_stamina_max(value)
		if not self._max_stamina or self._max_stamina ~= value then
			self._max_stamina = value
		end
		-- Hides the stamina display used by VHUDPlus
		if self._stamina_bar and self._stamina_line then
			self._stamina_bar:set_alpha(0)
			self._stamina_line:set_alpha(0)
		end
	end
	
	function HUDTeammate:set_stamina_current(value)
		if self._stamina_circle then
			self._stamina_circle:set_color(Color(1, value/self._max_stamina, 0, 0))
			self:set_stamina_visibility(not self._condition_icon:visible())
		end
	end
	
	function HUDTeammate:set_stamina_visibility(value)
		if self._stamina_circle and self._stamina_circle:visible() ~= value then
			self._stamina_circle:set_visible(value)
		end
	end

	Hooks:PostHook(HUDTeammate, "set_condition", "EIVHUD_HUDTeammate_set_condition", function (self, icon_data, ...)
		local custody = icon_data ~= "mugshot_normal"
		self:set_stamina_visibility(not custody and EIVHUD.Options:GetValue("HUD/PLAYER/Stamina"))
		local timer = self._cooldown_timer
		local health_timer = self._cooldown_health_timer
		if self._main_player and timer and self._invulnerability then
			timer:set_alpha(custody and 0 or 1)
			health_timer:set_alpha(custody and 0 or 1)
		end
	end)
	
	Hooks:PostHook(HUDTeammate, "set_ability_radial", "EIVHUD_HUDTeammate_set_ability_radial", function (self, data, ...)
		local progress = data.current / data.total
		if self._main_player then
			local stamina_alpha = self._health_timer and 0 or 1
			if self._stamina_circle then
				self._stamina_circle:set_alpha(progress > 0 and 0 or stamina_alpha) 
			end
			if self._radial_health_panel:child("animate_health_circle") and self._invulnerability then
				self._radial_health_panel:child("animate_health_circle"):set_alpha(progress > 0 and 0 or 1)
			end
			if self._invulnerability then
				if progress > 0 then
					self._cooldown_health_timer:set_visible(false)
				else
					self._cooldown_health_timer:set_visible(EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") and self._health_timer)
				end
			end
		end
	end)
	
	Hooks:PostHook(HUDTeammate, "activate_ability_radial", "EIVHUD_HUDTeammate_activate_ability_radial", function (self, time_left, ...)
		self._radial_health_panel:child("radial_custom"):animate(function (o)
			over(time_left, function (p)
				if self._main_player then
					self._stamina_circle:set_alpha(0)
					if self._invulnerability then
						self._radial_health_panel:child("animate_health_circle"):set_alpha(0)
						self._cooldown_health_timer:set_visible(false)
					end
				end
			end)
			if not self._health_timer then
				self._stamina_circle:set_alpha(1) 
			end
			if self._invulnerability then
				self._radial_health_panel:child("animate_health_circle"):set_alpha(1)
				self._cooldown_health_timer:set_visible(EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") and self._health_timer)
			end
		end)
	end)
end