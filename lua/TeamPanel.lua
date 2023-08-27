if _G.IS_VR then
    return
end

local Color = Color
if RequiredScript == "lib/managers/hudmanagerpd2" then
	Hooks:PostHook(HUDManager, "set_teammate_custom_radial", "EIVHUD_HUDManager_set_teammate_custom_radial", function (self, i, data, ...)
    	local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    	if not hud.panel:child("swan_song_left") then
    		local swan_song_left = hud.panel:bitmap({
	    		name = "swan_song_left",
	    		visible = false,
    			texture = "EIVHUD/screeneffect",
	    		layer = 0,
		    	color = Color(0, 0.7, 1),
		    	blend_mode = "add",
		    	w = hud.panel:w(),
		    	h = hud.panel:h(),
		    	x = 0,
		    	y = 0 
		    })
	    end

	    local swan_song_left = hud.panel:child("swan_song_left")
	    if i == 4 and data.current < data.total and data.current > 0 and swan_song_left then
		    swan_song_left:set_visible(EIVHUD.Options:GetValue("HUD/ScreenEffect"))
	    	local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
    		swan_song_left:animate(hudinfo.flash_icon, 4000000000)
    	elseif hud.panel:child("swan_song_left") then
	    	swan_song_left:stop()
		    swan_song_left:set_visible(false)
    	end
	    if swan_song_left and data.current == 0 then
	    	swan_song_left:set_visible(false)
	    end
    end)

    Hooks:PostHook(HUDManager, "set_teammate_ability_radial", "EIVHUD_HUDManager_set_teammate_ability_radial", function (self, i, data, ...)
	    local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
	    if not hud.panel:child("chico_injector_left") then
		    local chico_injector_left = hud.panel:bitmap({
		    	name = "chico_injector_left",
		    	visible = false,
		    	texture = "EIVHUD/screeneffect",
		    	layer = 0,
		    	color = Color(1, 0.6, 0),
		    	blend_mode = "add",
		    	w = hud.panel:w(),
		    	h = hud.panel:h(),
		    	x = 0,
		    	y = 0 
		    })
	    end

	    local chico_injector_left = hud.panel:child("chico_injector_left")
	    if i == 4 and data.current < data.total and data.current > 0 and chico_injector_left then
		    chico_injector_left:set_visible(EIVHUD.Options:GetValue("HUD/ScreenEffect"))
		    local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		    chico_injector_left:animate(hudinfo.flash_icon, 4000000000)
	    elseif hud.panel:child("chico_injector_left") then
		    chico_injector_left:stop()
		    chico_injector_left:set_visible(false)
	    end
	    if chico_injector_left and data.current == 0 then
		    chico_injector_left:set_visible(false)
	    end
    end)
	
	if EIVHUD.Options:GetValue("HUD/Scale") ~= 1 then
		Hooks:PreHook(HUDManager, "_setup_player_info_hud_pd2", "HMH_Scale_setup_player_info_hud_pd2", function(self, ...)
			managers.gui_data:layout_scaled_fullscreen_workspace(managers.hud._saferect)
		end)

		core:module("CoreGuiDataManager")
		Hooks:OverrideFunction(GuiDataManager, "layout_scaled_fullscreen_workspace", function(self, ws)
			local scale = _G.EIVHUD.Options:GetValue("HUD/Scale")
			local base_res = {x = 1280, y = 720}
			local res = RenderSettings.resolution
			local sc = (2 - scale)
			local aspect_width = base_res.x / self:_aspect_ratio()
			local h = math.round(sc * math.max(base_res.y, aspect_width))
			local w = math.round(sc * math.max(base_res.x, aspect_width / h))
			local safe_w = math.round(0.95 * res.x)
			local safe_h = math.round(0.95 * res.y)   
			local sh = math.min(safe_h, safe_w / (w / h))
			local sw = math.min(safe_w, safe_h * (w / h))
			local x = res.x / 2 - sh * (w / h) / 2
			local y = res.y / 2 - sw / (w / h) / 2
			ws:set_screen(w, h, x, y, math.min(sw, sh * (w / h)))
		end)
	end
elseif RequiredScript == "lib/managers/playermanager" then
	Hooks:PreHook(PlayerManager, "activate_temporary_upgrade", "activate_temporary_upgrade_armor_timer", function (self, category, upgrade)
		if upgrade == "armor_break_invulnerable" then
			local upgrade_value = self:upgrade_value(category, upgrade)
			if upgrade_value == 0 then return end
			local teammate_panel = managers.hud:get_teammate_panel_by_peer()
			if teammate_panel then
			    if EIVHUD.Options:GetValue("HUD/ArmorerCooldownTimer") and EIVHUD.Options:GetValue("HUD/ArmorerCooldownRadial") then
				    teammate_panel:update_cooldown_timer(upgrade_value[2])
				end
				if EIVHUD.Options:GetValue("HUD/ArmorerCooldownRadial") then
				    teammate_panel:animate_invulnerability(upgrade_value[1])
				end
			end
		end
		if upgrade == "mrwi_health_invulnerable" then
			local upgrade_value = self:upgrade_value(category, upgrade)
			if upgrade_value == 0 then return end
			local teammate_panel = managers.hud:get_teammate_panel_by_peer()
			if teammate_panel then
			    if EIVHUD.Options:GetValue("HUD/ArmorerCooldownTimer") and EIVHUD.Options:GetValue("HUD/ArmorerCooldownRadial") then
				    teammate_panel:health_cooldown_timer(2)
				end
				if EIVHUD.Options:GetValue("HUD/ArmorerCooldownRadial") then
				    teammate_panel:animate_health_invulnerability(2)
				end
			end
		end
	end)

	Hooks:PostHook(PlayerManager, "add_to_temporary_property", "add_to_temporary_property_hophud", function (self, name)
		if not EIVHUD.Options:GetValue("HUD/Bulletstorm") or name ~= "bullet_storm" then
			return
		end

		local bullet_storm = self._temporary_properties._properties[name]
		if not bullet_storm then
			return
		end

		local teammate_panel = managers.hud:get_teammate_panel_by_peer()
		if teammate_panel then
			teammate_panel:animate_bulletstorm(bullet_storm[2] - Application:time())
		end
	end)

elseif RequiredScript == "lib/managers/hud/hudteammate" then
	function HUDTeammate:_animate_bullet_storm(weapons_panel, duration)
		if not weapons_panel then
			return
		end

		local ammo_text = weapons_panel:child("ammo_clip")
		local panel = weapons_panel:child("bulletstorm")
		if not panel then
			panel = weapons_panel:panel({
				name = "bulletstorm",
				w = ammo_text:w() * 1.5,
				h = ammo_text:h() * 1.5
			})
			panel:set_world_center(ammo_text:world_center_x(), weapons_panel:world_center_y())

			panel:bitmap({
				name = "effect",
				texture = "guis/textures/pd2/crimenet_marker_glow",
				layer = 0,
				alpha = 0,
				w = panel:w(),
				h = panel:h(),
				color = tweak_data.screen_colors.button_stage_3
			})

			local text = panel:text({
				layer = 1,
				text = "8",
				font = tweak_data.hud_players.ammo_font,
				font_size = ammo_text:font_size(),
				rotation = 90
			})
			text:set_shape(text:text_rect())
			text:set_center(panel:w() * 0.5, panel:h() * 0.5)
		end

		local effect = panel:child("effect")
		weapons_panel:stop()
		weapons_panel:animate(function ()
			ammo_text:hide()
			panel:show()
			local t = 0
			while t < duration do
				t = t + coroutine.yield()
				local a = math.map_range(math.sin(t * 650), -1, 1, 0, 1)
				effect:set_alpha(a)
			end

			panel:hide()
			ammo_text:show()
		end)
	end

	function HUDTeammate:animate_bulletstorm(duration)
		local weapons_panel = self._player_panel:child("weapons_panel")
		if not weapons_panel then
			return
		end

		self:_animate_bullet_storm(weapons_panel:child("primary_weapon_panel"), duration)
		self:_animate_bullet_storm(weapons_panel:child("secondary_weapon_panel"), duration)
	end

	Hooks:PostHook(HUDTeammate, "set_ammo_amount_by_type", "EIVHUD_HUDTeammateSetAmmoAmountByType", function(self, type, max_clip, current_clip, current_left, max, weapon_panel)
        local weapon_panel = self._player_panel:child("weapons_panel"):child(type .. "_weapon_panel")
		local zero = current_left < 10 and "00" or current_left < 100 and "0" or ""

	    if self._main_player and EIVHUD.Options:GetValue("HUD/Trueammo") then
		    if current_left - current_clip >= 0 then
		    	current_left = current_left - current_clip
	    	end
			weapon_panel:child("ammo_total"):set_text(zero ..tostring(current_left))
	    end
    end)
	
	Hooks:PostHook(HUDTeammate, "set_custom_radial", "EIVHUD_HUDTeammate_set_custom_radial", function (self, data, ...)
        local duration = data.current / data.total

		if self._main_player and self._cooldown_timer then
		    if duration > 0 then
				self._cooldown_timer:set_visible(false)
				self._cooldown_health_timer:set_visible(false)
				self._cooldown_icon:set_visible(false)
				self._health_cooldown_icon:set_visible(false)
				if self._radial_health_panel:child("radial_armor") then
					self._radial_health_panel:child("radial_armor"):set_alpha(0)
					self._radial_health_panel:child("animate_health_circle"):set_alpha(0)
				end
			else
				self._cooldown_timer:set_visible(self._armor_invulnerability_timer)
				self._cooldown_health_timer:set_visible(self._health_timer)
				self._cooldown_icon:set_visible(self._armor_invulnerability_timer and not self._health_timer)
				self._health_cooldown_icon:set_visible(self._health_timer)
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
				y = 10,
				font = tweak_data.hud.medium_font_noshadow,
				font_size = 16,
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
				y = -7,
				font = tweak_data.hud.medium_font_noshadow,
				font_size = 16,
				alpha = 1,
				layer = 4
			})
			self._cooldown_icon = self._health_panel:bitmap({
				name = "cooldown_icon",
				texture = "guis/dlcs/opera/textures/pd2/specialization/icons_atlas",
				texture_rect = {0, 0, 64, 64},
				valign = "center",
				x = 14,
				y = 15,
				w = 40,
				h = 40,
				color = Color.white,
				visible = false,
				align = "center",
				alpha = 0.4,
				layer = 3
			})
			self._health_cooldown_icon = self._health_panel:bitmap({
				name = "health_cooldown_icon",
				texture = "EIVHUD/health_cooldown_icon",
				valign = "center",
				x = 9.5,
				y = 19,
				w = 48,
				h = 29,
				color = Color.white,
				visible = false,
				align = "center",
				alpha = 0.4,
				layer = 3
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

	function HUDTeammate:update_cooldown_timer(t)
		local timer = self._cooldown_timer
    	if t and t > 1 and timer then
        	timer:stop()
        	timer:animate(function(o)
            	o:set_visible(true)
            	local t_left = t
				local health_icon = self._health_cooldown_icon 
				local armor_icon = self._cooldown_icon 
            	while t_left >= 0.1 do
					self._armor_invulnerability_timer = true
                	t_left = t_left - coroutine.yield()
					t_format = t_left < 10 and "%.1f" or "%.f"
                	o:set_text(string.format(t_format, t_left))
					o:set_color(EIVHUD.Options:GetValue("HUD/ArmorerCooldownTimerColor") or Color.blue)
            	end
				self._armor_invulnerability_timer = false
            	o:set_visible(false)
				armor_icon:set_visible(false)
				health_icon:set_visible(self._health_timer)
        	end)
    	end
	end

	function HUDTeammate:animate_invulnerability(duration)
	    if not self._radial_health_panel:child("radial_armor") then return end
  		self._radial_health_panel:child("radial_armor"):animate(function (o)
		    local armor_icon = self._cooldown_icon 
    		o:set_color(Color(1, 1, 1, 1))
			self._armor_invulnerability_timer = true
			armor_icon:set_visible(self._armor_invulnerability_timer and not self._health_timer)
			armor_icon:set_alpha(not EIVHUD.Options:GetValue("HUD/ArmorerCooldownTimer") and 1 or 0.4)
    		o:set_visible(true)
    		over(duration, function (p)
      			o:set_color(Color(1, 1 - p, 1, 1))
    		end)
			if not EIVHUD.Options:GetValue("HUD/ArmorerCooldownTimer") then 
				self._armor_invulnerability_timer = false
				armor_icon:set_visible(self._armor_invulnerability_timer)
			end
    		o:set_visible(false)
  		end)
	end
	
	function HUDTeammate:health_cooldown_timer(t)
		local timer = self._cooldown_health_timer
    	if t and t > 1 and timer then
			timer:stop()
        	timer:animate(function(o)
            	o:set_visible(true)
            	local t_left = t + 13
				local health_icon = self._health_cooldown_icon
				local armor_icon = self._cooldown_icon				
            	while t_left >= 0.1 do
					self._health_timer = true
                	t_left = t_left - coroutine.yield()
					t_format = t_left < 10 and "%.1f" or "%.f"
                	o:set_text(string.format(t_format, t_left))
					o:set_color(EIVHUD.Options:GetValue("HUD/GraceCooldownTimerColor") or Color.green)
            	end
				self._health_timer = false
				armor_icon:set_visible(self._armor_invulnerability_timer)
            	o:set_visible(false)
				health_icon:set_visible(self._health_timer)
        	end)
    	end
	end
	
	function HUDTeammate:animate_health_invulnerability(duration)
	    if not self._radial_health_panel:child("animate_health_circle") then return end
  		self._radial_health_panel:child("animate_health_circle"):animate(function (o)
		    local health_icon = self._health_cooldown_icon
			local armor_icon = self._cooldown_icon
    		o:set_color(Color(1, 1, 1, 1))
			self._radial_health_panel:child("animate_health_circle"):set_alpha(1)
	  	    self._health_timer = true
			armor_icon:set_visible(not self._health_timer)
			health_icon:set_visible(self._health_timer)
			health_icon:set_alpha(not EIVHUD.Options:GetValue("HUD/ArmorerCooldownTimer") and 1 or 0.4)
    		o:set_visible(true)
    		over(duration, function (p)
      			o:set_color(Color(1, 1 - p, 1, 1))
    		end)
    		o:set_visible(false)
			if not EIVHUD.Options:GetValue("HUD/ArmorerCooldownTimer") then
			    self._health_timer = false
				health_icon:set_visible(self._health_timer)
				armor_icon:set_visible(self._armor_invulnerability_timer)
			end
			o:set_visible(false)
  		end)
	end

	Hooks:PostHook(HUDTeammate, "set_condition", "EIVHUD_HUDTeammate_set_condition", function (self, icon_data, ...)
	    local custody = icon_data ~= "mugshot_normal"
		local timer = self._cooldown_timer
		local health_timer = self._cooldown_health_timer
		local icon = self._cooldown_icon
		local health_icon = self._health_cooldown_icon
		if self._main_player and timer then
			timer:set_alpha(custody and 0 or 1)
			health_timer:set_alpha(custody and 0 or 1)
			icon:set_visible(not custody and self._armor_invulnerability_timer and not self._health_timer)
			health_icon:set_visible(not custody and self._health_timer)
		end
    end)
	
	Hooks:PostHook(HUDTeammate, "set_ability_radial", "EIVHUD_HUDTeammate_set_ability_radial", function (self, data, ...)
        local progress = data.current / data.total
        if self._main_player then
			if self._radial_health_panel:child("animate_health_circle") then
				self._radial_health_panel:child("animate_health_circle"):set_alpha(progress > 0 and 0 or 1)
			end
			if progress > 0 then
				self._health_cooldown_icon:set_visible(false)
				self._cooldown_health_timer:set_visible(false)
			else
				self._cooldown_health_timer:set_visible(EIVHUD.Options:GetValue("HUD/ArmorerCooldownTimer") and self._health_timer)
				self._health_cooldown_icon:set_visible(self._health_timer)
			end
    	end
    end)
	
	Hooks:PostHook(HUDTeammate, "activate_ability_radial", "EIVHUD_HUDTeammate_activate_ability_radial", function (self, time_left, ...)
      	self._radial_health_panel:child("radial_custom"):animate(function (o)
        	over(time_left, function (p)
	    	    if self._main_player then
					self._radial_health_panel:child("animate_health_circle"):set_alpha(0)
					self._health_cooldown_icon:set_visible(false)
					self._cooldown_health_timer:set_visible(false)
	    		end
        	end)
			self._radial_health_panel:child("animate_health_circle"):set_alpha(1)
			self._cooldown_health_timer:set_visible(EIVHUD.Options:GetValue("HUD/ArmorerCooldownTimer") and self._health_timer)
			self._health_cooldown_icon:set_visible(self._health_timer)
     	end)
    end)
end