if _G.IS_VR then
    return
end

local Color = Color
local math_lerp = math.lerp
if RequiredScript == "lib/managers/hudmanagerpd2" then

	Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "EIVHUD_bufflist_setup_player_info_hud_pd2", function(self, ...)
        self._hud_buff_list = HUDBuffList:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
    end)

    function HUDManager:update_inspire_timer(buff)
        self._hud_buff_list:update_inspire_timer(buff)
    end
	
	function HUDManager:Set_bloodthirst(buff)
       self._hud_buff_list:Set_bloodthirst(buff)
    end

	HUDBuffList = HUDBuffList or class()
	function HUDBuffList:init()
		local Skilltree2 = "guis/textures/pd2/skilltree_2/icons_atlas_2"
		local TimeBackground = "guis/textures/pd2/crimenet_marker_glow"
		
		if managers.hud ~= nil then 
		    self.hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
            self._cooldown_panel = self.hud.panel:panel({
                name = "cooldown_panel",
                x = 0,
                y = 0
            })
            self.cooldown_text = self._cooldown_panel:text({
                layer = 2,
                visible = false,
                text = "",
                font = tweak_data.hud.medium_font_noshadow,
                font_size = 16,
                x = 13,
                y = 25,
                color = Color.white
            })
            self._inspire_cooldown_icon = self._cooldown_panel:bitmap({
                name = "inspire_cooldown_icon",
                texture = Skilltree2,
                texture_rect = { 4 * 80, 9 * 80, 80, 80 },
                w = 28,
                h = 28,
                x = 0,
                y = 0,
                color = Color.white,
                visible = false,
                layer = 1
            })
            self._inspire_cooldown_timer_bg = self._cooldown_panel:bitmap({
                name = "inspire_cooldown_timer_bg",
                texture = TimeBackground,
                texture_rect = { 1, 1, 62, 62 }, 
                w = 40,
                h = 40,
                x = 0,
                y = 13,
                color = Color("66ffff"),
                visible = false,
                layer = 0
            })
			self._bloodthirst_panel = self.hud.panel:panel({
				name = "bloodthirst_panel",
				x = 0,
				y = 0
			})
			self.bloodthirst_text = self._bloodthirst_panel:text({
				layer = 2,
				visible = false,
				text = "0.0",
				font = tweak_data.hud.medium_font_noshadow,
				font_size = 16,
				x = 12,
				y = 25,
				color = Color.white
			})
			self._bloodthirst_icon = self._bloodthirst_panel:bitmap({
				name = "bloodthirst_icon",
				texture = Skilltree2,
				texture_rect = { 11* 80, 6 * 80, 80, 80 },
				w = 28,
				h = 28,
				x = 0,
				y = 0,
				color = Color.white,
				visible = false,
				layer = 1
			})
			self._bloodthirst_bg = self._bloodthirst_panel:bitmap({
				name = "bloodthirst_bg",
				texture = TimeBackground,
				texture_rect = { 1, 1, 62, 62 }, 
				w = 37,
				h = 37,
				x = 0,
				y = 15,
				color = Color("66ffff"),
				alpha = 0.5,
				visible = false,
				layer = 0
			})
		end
	end
	
	function HUDBuffList:update_timer_visibility_and_position()
        local inspire_visible = EIVHUD.Options:GetValue("HUD/BUFFLIST/Inspire")
        self.cooldown_text:set_visible(inspire_visible)
        self._inspire_cooldown_timer_bg:set_visible(inspire_visible)
        self._inspire_cooldown_icon:set_visible(inspire_visible)

        local pos_x = 10 * (EIVHUD.Options:GetValue("HUD/BUFFLIST/TimerX") or 0)
        local pos_y = 10 * (EIVHUD.Options:GetValue("HUD/BUFFLIST/TimerY") or 0)
        self._cooldown_panel:set_x(pos_x)
        self._cooldown_panel:set_y(pos_y)
    end

    function HUDBuffList:update_inspire_timer(duration)
        local timer = self.cooldown_text
        local timer_bg = self._inspire_cooldown_timer_bg
        local icon = self._inspire_cooldown_icon

        timer:set_alpha(1)
        timer_bg:set_alpha(0.5)
        icon:set_alpha(1)

        if duration and duration > 1 then
            timer:stop()
            timer:animate(function(o)
                local t_left = duration
				self:update_timer_visibility_and_position()

                while t_left >= 0 do
                    if t_left <= 0.1 then
                        self:fade_out("inspire")
                        return
                    end
                    t_left = t_left - coroutine.yield()
                    o:set_text(string.format(t_left < 9.9 and "%.1f" or "%.f", t_left))
                    self:update_timer_visibility_and_position()
                end
            end)
        end
    end
	
	function HUDBuffList:fade_out(buff_type)
		local start_time = os.clock()
		local text, bg, icon
		local duration

		if buff_type == "inspire" then
			text = self.cooldown_text
			bg = self._inspire_cooldown_timer_bg
			icon = self._inspire_cooldown_icon
			duration = 0.1  -- Fade out duration for Inspire
		elseif buff_type == "bloodthirst" then
			text = self.bloodthirst_text
			bg = self._bloodthirst_bg
			icon = self._bloodthirst_icon
			duration = 0.3  -- Fade out duration for Bloodthirst
		end

		if text and bg and icon then
			text:animate(function()
				while true do
					local alpha = math.max(1 - (os.clock() - start_time) / duration, 0)
					text:set_alpha(alpha)
					bg:set_alpha(0.5 * alpha)
					icon:set_alpha(alpha)

					if alpha <= 0 then
						icon:set_visible(false)
						bg:set_visible(false)
						text:set_text("")
						break
					end

					coroutine.yield()
				end
			end)
		end
	end
	function HUDBuffList:update_bloodthirst_position()
		local panel = self._bloodthirst_panel
		local x_position = 10 * (EIVHUD.Options:GetValue("HUD/BUFFLIST/BloodthirstX") or 0)
		local y_position = 10 * (EIVHUD.Options:GetValue("HUD/BUFFLIST/BloodthirstY") or 0)
		panel:set_x(x_position)
		panel:set_y(y_position)
	end

	LocalizationManager:add_localized_strings({["EIVH_bloodthirst_multiplier"] = "$NUM"})
	function HUDBuffList:Set_bloodthirst(buff)
		local panel = self._bloodthirst_panel
		local bloodthirst_text = self.bloodthirst_text
		local bloodthirst_icon = self._bloodthirst_icon
		local bloodthirst_timer_bg = self._bloodthirst_bg

		bloodthirst_text:set_alpha(1)
		bloodthirst_icon:set_alpha(1)
		bloodthirst_timer_bg:set_alpha(0.5)

		if buff >= EIVHUD.Options:GetValue("HUD/BUFFLIST/BloodthirstMinKills") and EIVHUD.Options:GetValue("HUD/BUFFLIST/Bloodthirst") then
			bloodthirst_text:set_visible(true)
			bloodthirst_icon:set_visible(true)
			bloodthirst_timer_bg:set_visible(true)

			self:update_bloodthirst_position()
        
			bloodthirst_text:set_text(managers.localization:to_upper_text("EIVH_bloodthirst_multiplier", { NUM = buff }).."x")

			bloodthirst_text:animate(function(o)
				over(1, function(p)
					local n = 1 - math.sin((p / 2) * 180)
					o:set_font_size(math_lerp(16, 16 * 1.16, n))
				end)
			end)
		else
			self:fade_out("bloodthirst")
		end
	end

	Hooks:PostHook(HUDManager, "feed_heist_time", "EIVHUD_HUDManager_feed_heist_time", function (self, time, ...)
		if self._hud_statsscreen and self._hud_statsscreen.feed_heist_time then
			self._hud_statsscreen:feed_heist_time(time)
		end
	end)

	Hooks:PostHook(HUDManager, "modify_heist_time", "EIVHUD_HUDManager_modify_heist_time", function (self, time, ...)
		if self._hud_statsscreen and self._hud_statsscreen.modify_heist_time then
			self._hud_statsscreen:modify_heist_time(time)
		end
	end)
	
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
	
	local Scale_option = EIVHUD.Options:GetValue("HUD/Scale") or 1
	if Scale_option ~= 1 then
		Hooks:PreHook(HUDManager, "_setup_player_info_hud_pd2", "EIVHUD_Scale_setup_player_info_hud_pd2", function(self)
			managers.gui_data:layout_scaled_fullscreen_workspace(self._saferect, Scale_option)
		end)
		
		Hooks:PostHook(HUDPlayerCustody , "set_negotiating_visible", "EIVHUD_HUDPlayerCustody_set_negotiating_visible", function(self, ...)
			self._hud.trade_text2:set_visible(false)
		end)

		Hooks:PostHook(HUDPlayerCustody , "set_can_be_trade_visible", "EIVHUD_HUDPlayerCustody_set_can_be_trade_visible", function(self, ...)
			self._hud.trade_text1:set_visible(false)
		end)

		Hooks:PostHook(HUDManager, "resolution_changed", "EIVHUD_ResolutionChanged", function(self)
			managers.gui_data:layout_scaled_fullscreen_workspace(self._saferect, Scale_option)
		end)

		core:module("CoreGuiDataManager")
		function GuiDataManager:layout_scaled_fullscreen_workspace(ws, scale)
			local base_res = {x = 1280, y = 720}
			local res = RenderSettings.resolution
			local scale = scale or 1
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
		end
	end
elseif RequiredScript == "lib/units/beings/player/playerdamage" then
	local PlayerDamage_restore_health = PlayerDamage.restore_health
	function PlayerDamage:restore_health(health_restored, ...)
		if health_restored * self._healing_reduction == 0 then
			return
		end
		return PlayerDamage_restore_health(self, health_restored, ...)
	end
elseif RequiredScript == "lib/managers/playermanager" then
	Hooks:PreHook(PlayerManager, "activate_temporary_upgrade", "activate_temporary_upgrade_armor_timer", function (self, category, upgrade)
		if upgrade == "armor_break_invulnerable" then
			local upgrade_value = self:upgrade_value(category, upgrade)
			if upgrade_value == 0 then return end
			local teammate_panel = managers.hud:get_teammate_panel_by_peer()
			if teammate_panel then
			    if EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") and EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownRadial") and teammate_panel.update_cooldown_timer then
				    teammate_panel:update_cooldown_timer(upgrade_value[2])
				end
				if EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownRadial") and teammate_panel.animate_invulnerability then
				    teammate_panel:animate_invulnerability(upgrade_value[1])
				end
			end
		end
		if upgrade == "mrwi_health_invulnerable" then
			local upgrade_value = self:upgrade_value(category, upgrade)
			if upgrade_value == 0 then return end
			local teammate_panel = managers.hud:get_teammate_panel_by_peer()
			if teammate_panel then
			    if EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") and EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownRadial") and teammate_panel.health_cooldown_timer then
				    teammate_panel:health_cooldown_timer(2)
				end
				if EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownRadial") and teammate_panel.animate_health_invulnerability then
				    teammate_panel:animate_health_invulnerability(2)
				end
			end
		end
	end)

	Hooks:PostHook(PlayerManager, "add_to_temporary_property", "add_to_temporary_property_hophud", function (self, name)
		if not EIVHUD.Options:GetValue("HUD/PLAYER/Bulletstorm") or name ~= "bullet_storm" then
			return
		end

		local bullet_storm = self._temporary_properties._properties[name]
		if not bullet_storm then
			return
		end

		local teammate_panel = managers.hud:get_teammate_panel_by_peer()
		if teammate_panel and teammate_panel.animate_bulletstorm then
			teammate_panel:animate_bulletstorm(bullet_storm[2] - Application:time())
		end
	end)
	
	Hooks:PostHook(PlayerManager, "disable_cooldown_upgrade", "EIVHUD_PlayerManager_disable_cooldown_upgrade", function(self, category, upgrade)
        local upgrade_value = self:upgrade_value(category, upgrade)
        if upgrade_value and upgrade_value[1] ~= 0 and EIVHUD.Options:GetValue("HUD/BUFFLIST/Inspire") then
            managers.hud:update_inspire_timer(upgrade_value[2])
        end
    end)
	
	Hooks:PostHook(PlayerManager, 'set_melee_dmg_multiplier', "EIVHUD_update_Bloodthirst", function(self, ...)
		if not self:has_category_upgrade("player", "melee_damage_stacking") then return end
		if self._melee_dmg_mul ~= 1 then
			managers.hud:Set_bloodthirst(self._melee_dmg_mul)
		end
	end)
elseif RequiredScript == "lib/managers/hud/hudteammate" then
	Hooks:PostHook(HUDTeammate, "init", "EIVHUD_Stamina_init", function (self, ...)
		if self._main_player then
			self:_create_circle_stamina()
		end
		if EIVHUD.Options:GetValue("HUD/PLAYER/Team_bg") then
			self._panel:child("name_bg"):set_visible(false)
			self._cable_ties_panel:child("bg"):set_visible(false)
			self._deployable_equipment_panel:child("bg"):set_visible(false)
			self._grenades_panel:child("bg"):set_visible(false)
			self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("bg"):set_visible(false)
			self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("bg"):set_visible(false)
		end
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

	Hooks:PostHook(HUDTeammate, "set_ammo_amount_by_type", "EIVHUD_HUDTeammate_set_ammo_amount_by_type", function(self, type, max_clip, current_clip, current_left, max, weapon_panel)
		if EIVHUD.Options:GetValue("HUD/PLAYER/Trueammo") then
			local weapon_panel = self._player_panel:child("weapons_panel"):child(type .. "_weapon_panel")
			local ammo_clip = weapon_panel:child("ammo_clip")

			if self._alt_ammo and ammo_clip:visible() then
				current_left = math.max(0, current_left - max_clip - (current_clip - max_clip))
			end

			local low_ammo_color = Color(1, 0.9, 0.9, 0.3)
			local total_ammo_color = Color.white
			local clip_ammo_color = Color.white
			local low_ammo = current_left <= math.round(max_clip / 2)
			local low_clip = current_clip <= math.round(max_clip / 4)
			local out_of_clip = current_clip <= 0
			local out_of_ammo = current_left <= 0
			local color_total = out_of_ammo and Color(1 , 0.9 , 0.3 , 0.3)
			local color_clip = out_of_clip and Color(1 , 0.9 , 0.3 , 0.3)
			local ammo_total = weapon_panel:child("ammo_total")
			local zero = current_left < 10 and "00" or current_left < 100 and "0" or ""
			local zero_clip = current_clip < 10 and "00" or current_clip < 100 and "0" or ""
			local ammo_font = string.len(current_left) < 4 and 24 or 20
			color_total = color_total or low_ammo and (low_ammo_color)
			color_total = color_total or (total_ammo_color)
			color_clip = color_clip or low_clip and (low_ammo_color)
			color_clip = color_clip or (clip_ammo_color)

			ammo_total:set_text(zero ..tostring(current_left))
			ammo_total:set_color(color_total)
			ammo_total:set_range_color(0, string.len(zero), color_total:with_alpha(0.5))
			ammo_total:set_font_size(ammo_font)
			ammo_clip:set_color(color_clip)
			ammo_clip:set_range_color(0, string.len(zero_clip), color_clip:with_alpha(0.5))

			ammo_total:stop()
			ammo_clip:stop()
				
			if not self._last_ammo then
				self._last_ammo = {}
				self._last_ammo[type] = current_left
			end

			if not self._last_clip then
				self._last_clip = {}
				self._last_clip[type] = current_clip
			end

			if self._last_ammo and self._last_ammo[type] and self._last_ammo[type] < current_left then
				ammo_total:animate(function(o)
					local s = self._last_ammo[type]
					local e = current_left
					over(0.5, function(p)
						local value = math_lerp(s, e, p)
						local text = string.format("%.0f", value)
						local zero = math.round(value) < 10 and "00" or math.round(value) < 100 and "0" or ""
						local low_ammo = value <= math.round(max_clip / 2)
						local out_of_ammo = value <= 0
						local color_total = out_of_ammo and Color(1, 0.9, 0.3, 0.3)
						color_total = color_total or low_ammo and low_ammo_color
						color_total = color_total or (total_ammo_color)

						ammo_total:set_text(zero .. text)
						ammo_total:set_color(color_total)
						ammo_total:set_range_color(0, string.len(zero), color_total:with_alpha(0.5))
					end)
					over(1 , function(p)
						local n = 1 - math.sin((p / 2 ) * 180)
						ammo_total:set_font_size(math_lerp(ammo_font, ammo_font + 4, n))
					end)
				end)
			end

			if self._last_clip and self._last_clip[type] and self._last_clip[type] < current_clip and not self._infinite_ammo then
				ammo_clip:animate(function(o)
					local s = self._last_clip[type]
					local e = current_clip
					over(0.25, function(p)
						local value = math_lerp(s, e, p)
						local text = string.format( "%.0f", value)
						local zero = math.round(value) < 10 and "00" or math.round(value) < 100 and "0" or ""
						local low_clip = value <= math.round(max_clip / 4)
						local out_of_clip = value <= 0
						local color_clip = out_of_clip and Color(1, 0.9, 0.3, 0.3)

						color_clip = color_clip or low_clip and low_ammo_color
						color_clip = color_clip or (clip_ammo_color)

						ammo_clip:set_text(zero .. text)
						ammo_clip:set_color(color_clip)
						ammo_clip:set_range_color(0, string.len(zero), color_clip:with_alpha(0.5))
					end)
				end)
			end
			self._last_ammo[type] = current_left
			self._last_clip[type] = current_clip
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
				y = -4,
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
			if self._stamina_circle then
				self._stamina_circle:set_alpha(0)
			end
        	timer:animate(function(o)
            	o:set_visible(true)
            	local t_left = t
				local health_icon = self._health_cooldown_icon 
				local armor_icon = self._cooldown_icon 
            	while t_left >= 0.1 do
					self._armor_invulnerability_timer = true
                	t_left = t_left - coroutine.yield()
					t_format = t_left < 9.9 and "%.1f" or "%.f"
                	o:set_text(string.format(t_format, t_left))
					o:set_color(EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimerColor") or Color.blue)
            	end
				self._armor_invulnerability_timer = false
            	o:set_visible(false)
				armor_icon:set_visible(false)
				health_icon:set_visible(self._health_timer)
				self._stamina_circle:set_alpha(not self._health_timer and 1 or 0)
        	end)
    	end
	end

	function HUDTeammate:animate_invulnerability(duration)
	    if not self._radial_health_panel:child("radial_armor") then return end
  		self._radial_health_panel:child("radial_armor"):animate(function (o)
		    local armor_icon = self._cooldown_icon 
    		o:set_color(Color(1, 1, 1, 1))
			self._stamina_circle:set_alpha(0)
			self._armor_invulnerability_timer = true
			armor_icon:set_visible(self._armor_invulnerability_timer and not self._health_timer)
			armor_icon:set_alpha(not EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") and 1 or 0.4)
    		o:set_visible(true)
    		over(duration, function (p)
      			o:set_color(Color(1, 1 - p, 1, 1))
    		end)
			if not EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") then
				self._stamina_circle:set_alpha(1) 
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
			if self._stamina_circle then
				self._stamina_circle:set_alpha(0)
			end
        	timer:animate(function(o)
            	o:set_visible(true)
            	local t_left = t + 13
				local health_icon = self._health_cooldown_icon
				local armor_icon = self._cooldown_icon				
            	while t_left >= 0.1 do
					self._health_timer = true
                	t_left = t_left - coroutine.yield()
					t_format = t_left < 9.9 and "%.1f" or "%.f"
                	o:set_text(string.format(t_format, t_left))
					o:set_color(EIVHUD.Options:GetValue("HUD/PLAYER/GraceCooldownTimerColor") or Color.green)
            	end
				self._health_timer = false
				armor_icon:set_visible(self._armor_invulnerability_timer)
            	o:set_visible(false)
				health_icon:set_visible(self._health_timer)
				self._stamina_circle:set_alpha(not self._armor_invulnerability_timer and 1 or 0)
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
			self._stamina_circle:set_alpha(0)
	  	    self._health_timer = true
			armor_icon:set_visible(not self._health_timer)
			health_icon:set_visible(self._health_timer)
			health_icon:set_alpha(not EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") and 1 or 0.4)
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
				health_icon:set_visible(self._health_timer)
				armor_icon:set_visible(self._armor_invulnerability_timer)
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
			local stamina_alpha = self._health_timer and 0 or 1
			if self._stamina_circle then
				self._stamina_circle:set_alpha(progress > 0 and 0 or stamina_alpha) 
			end
			if self._radial_health_panel:child("animate_health_circle") then
				self._radial_health_panel:child("animate_health_circle"):set_alpha(progress > 0 and 0 or 1)
			end
			if progress > 0 then
				self._health_cooldown_icon:set_visible(false)
				self._cooldown_health_timer:set_visible(false)
			else
				self._cooldown_health_timer:set_visible(EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") and self._health_timer)
				self._health_cooldown_icon:set_visible(self._health_timer)
			end
    	end
    end)
	
	Hooks:PostHook(HUDTeammate, "activate_ability_radial", "EIVHUD_HUDTeammate_activate_ability_radial", function (self, time_left, ...)
      	self._radial_health_panel:child("radial_custom"):animate(function (o)
        	over(time_left, function (p)
	    	    if self._main_player then
					self._stamina_circle:set_alpha(0)
					self._radial_health_panel:child("animate_health_circle"):set_alpha(0)
					self._health_cooldown_icon:set_visible(false)
					self._cooldown_health_timer:set_visible(false)
	    		end
        	end)
			if not self._health_timer then
				self._stamina_circle:set_alpha(1) 
			end
			self._radial_health_panel:child("animate_health_circle"):set_alpha(1)
			self._cooldown_health_timer:set_visible(EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") and self._health_timer)
			self._health_cooldown_icon:set_visible(self._health_timer)
     	end)
    end)
	
	Hooks:PostHook(HUDTeammate, "set_revives_amount", "EIVHUD_HUDTeammate_set_revives_amount", function(self, revive_amount, ...)
        if EIVHUD.Options:GetValue("HUD/PLAYER/Downs") and revive_amount then
            local teammate_panel = self._panel:child("player")
            local revive_panel = teammate_panel:child("revive_panel")
            local revive_amount_text = revive_panel:child("revive_amount")
            local revive_arrow = revive_panel:child("revive_arrow")
            local revive_bg = revive_panel:child("revive_bg")
            local team_color = self._peer_id and tweak_data.chat_colors[self._peer_id] or (not self._ai and tweak_data.chat_colors[managers.network:session():local_peer():id()]) or Color.white
			local bg_alpha = EIVHUD.Options:GetValue("HUD/PLAYER/Team_bg") and 0 or 0.6
			
            if revive_amount_text then
                revive_amount_text:set_text(tostring(math.max(revive_amount - 1, 0)))
                revive_amount_text:set_color(revive_amount > 1 and team_color or Color.red)
				revive_amount_text:set_font_size(17)
				
				if revive_arrow then
					revive_arrow:set_color(revive_amount > 1 and team_color or Color.red)
				end
				
				if revive_bg then
					revive_bg:set_color(Color.black / 3)
					revive_bg:set_alpha(bg_alpha)
				end
            end
        end
    end)
end