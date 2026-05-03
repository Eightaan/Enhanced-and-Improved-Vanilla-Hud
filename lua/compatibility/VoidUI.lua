if not VoidUI then return end
if RequiredScript == "lib/managers/hud/hudteammate" and VoidUI.options.teammate_panels then
	local init_original = HUDTeammate.init
	local set_ammo_amount_by_type_original = HUDTeammate.set_ammo_amount_by_type
	local set_custom_radial_orig = HUDTeammate.set_custom_radial

	function HUDTeammate:infinite_ammo_glow()
		local hud_scale = VoidUI.options.hud_main_scale 
		self._primary_ammo = self._custom_player_panel:child("weapons_panel"):child("primary_ammo_panel"):bitmap({
			align           = "center",
			w 				= 100 * hud_scale,
			h 				= 45 * hud_scale,
			name 			= "primary_ammo",
			visible 		= false,
			texture 		= "guis/textures/pd2/crimenet_marker_glow",
			color 			= Color("00AAFF"),
			layer 			= 2,
			blend_mode 		= "add"
		})
		self._primary_ammo_text = self._custom_player_panel:child("weapons_panel"):child("primary_ammo_panel"):text({
			align = "center",
			name = "primary_ammo_text",
			visible = false,
			text = "8",
			font = tweak_data.menu.pd2_large_font,
			font_size = tweak_data.menu.pd2_large_font_size * hud_scale,
			color = Color.white,
			rotation = 90,
			layer = 4
		})
		self._secondary_ammo = self._custom_player_panel:child("weapons_panel"):child("secondary_ammo_panel"):bitmap({
			align           = "center",
			w 				= 100 * hud_scale,
			h 				= 45 * hud_scale,
			name 			= "secondary_ammo",
			visible 		= false,
			texture 		= "guis/textures/pd2/crimenet_marker_glow",
			color 			= Color("00AAFF"),
			layer 			= 2,
			blend_mode 		= "add"
		})
		self._secondary_ammo_text = self._custom_player_panel:child("weapons_panel"):child("secondary_ammo_panel"):text({
			align = "center",
			name = "primary_ammo_text",
			visible = false,
			text = "8",
			font = tweak_data.menu.pd2_large_font,
			font_size = tweak_data.menu.pd2_large_font_size * hud_scale,
			color = Color.white,
			rotation = 90,
			layer = 4
		})
		self._primary_ammo:set_center_y(self._custom_player_panel:child("weapons_panel"):child("primary_ammo_panel"):child("primary_ammo_amount"):y() + self._custom_player_panel:child("weapons_panel"):child("primary_ammo_panel"):child("primary_ammo_amount"):h() / 2)
		self._primary_ammo:set_center_x(self._custom_player_panel:child("weapons_panel"):child("primary_ammo_panel"):child("primary_ammo_amount"):x() + self._custom_player_panel:child("weapons_panel"):child("primary_ammo_panel"):child("primary_ammo_amount"):w() / 3.5)
		self._primary_ammo_text:set_center_y(self._custom_player_panel:child("weapons_panel"):child("primary_ammo_panel"):child("primary_ammo_amount"):y() + self._custom_player_panel:child("weapons_panel"):child("primary_ammo_panel"):child("primary_ammo_amount"):h() / 2)
		self._primary_ammo_text:set_center_x(self._custom_player_panel:child("weapons_panel"):child("primary_ammo_panel"):child("primary_ammo_amount"):x() + self._custom_player_panel:child("weapons_panel"):child("primary_ammo_panel"):child("primary_ammo_amount"):w() / 3.5)
		
		self._secondary_ammo:set_center_y(self._custom_player_panel:child("weapons_panel"):child("secondary_ammo_panel"):child("secondary_ammo_amount"):y() + self._custom_player_panel:child("weapons_panel"):child("secondary_ammo_panel"):child("secondary_ammo_amount"):h() / 2)
		self._secondary_ammo:set_center_x(self._custom_player_panel:child("weapons_panel"):child("secondary_ammo_panel"):child("secondary_ammo_amount"):x() + self._custom_player_panel:child("weapons_panel"):child("secondary_ammo_panel"):child("secondary_ammo_amount"):w() / 3.5)
		self._secondary_ammo_text:set_center_y(self._custom_player_panel:child("weapons_panel"):child("secondary_ammo_panel"):child("secondary_ammo_amount"):y() + self._custom_player_panel:child("weapons_panel"):child("secondary_ammo_panel"):child("secondary_ammo_amount"):h() / 2)
		self._secondary_ammo_text:set_center_x(self._custom_player_panel:child("weapons_panel"):child("secondary_ammo_panel"):child("secondary_ammo_amount"):x() + self._custom_player_panel:child("weapons_panel"):child("secondary_ammo_panel"):child("secondary_ammo_amount"):w() / 3.5)
	end

	function HUDTeammate:set_ammo_amount_by_type(type, ...)
		set_ammo_amount_by_type_original(self, type, ...)
		
		local selected_ammo_panel = self._custom_player_panel:child("weapons_panel"):child(type.."_ammo_panel")
		local ammo_amount = selected_ammo_panel:child(type.."_ammo_amount")
		if self._main_player and self._bullet_storm then
			ammo_amount:set_text( "" )
		end
	end 

	function HUDTeammate:_set_infinite_ammo(state)
		self._bullet_storm = state
	 
		if self._bullet_storm then
			local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
			local weapons_panel = self._custom_player_panel:child("weapons_panel")
			local primary_ammo_panel = weapons_panel:child("primary_ammo_panel")
			local secondary_ammo_panel = weapons_panel:child("secondary_ammo_panel")
			local primary_ammo_amount = primary_ammo_panel:child("primary_ammo_amount")
			local secondary_ammo_amount = secondary_ammo_panel:child("secondary_ammo_amount")

			self._primary_ammo:set_visible(true)
			self._secondary_ammo:set_visible(true)
			self._primary_ammo_text:set_visible(true)
			self._secondary_ammo_text:set_visible(true)
			self._primary_ammo:animate(hudinfo.flash_icon, 4000000000)
			self._secondary_ammo:animate(hudinfo.flash_icon, 4000000000)
			primary_ammo_amount:set_text( "" )
			secondary_ammo_amount:set_text( "" )
		else
			self._primary_ammo:set_visible(false)
			self._secondary_ammo:set_visible(false)		
			self._primary_ammo_text:set_visible(false)
			self._secondary_ammo_text:set_visible(false)
		end
	end

	function HUDTeammate:set_custom_radial(data)
		set_custom_radial_orig(self, data)
		local duration = data.current / data.total
		local aced = managers.player:upgrade_level("player", "berserker_no_ammo_cost", 0) == 1
		if self._main_player and EIVHUD.Options:GetValue("HUD/PLAYER/Bulletstorm") and aced then
			if duration > 0 then
				managers.hud:set_bulletstorm(true)
			else
				managers.hud:set_bulletstorm(false)
			end
		end
	end

	function HUDTeammate:_animate_invulnerability(duration)
		local custom_bar = self._custom_player_panel:child("health_panel"):child("custom_bar")
		if not custom_bar then return end
		custom_bar:animate(function(o)
			o:set_color(Color(1, 0.7, 0.85, 1))
			o:set_visible(true)
			over(duration, function(p)
				o:set_h(math.lerp(self._bg_h, 0, p))
				o:set_texture_rect(203, math.lerp(0, 472, p),202,math.lerp(472, 0, p))
				o:set_bottom(self._custom_player_panel:child("health_panel"):child("health_background"):bottom())
			end)
			o:set_visible(false)
		end)
	end

	function HUDTeammate:_update_cooldown_timer(t)
		local condition_timer = self._custom_player_panel:child("condition_timer")
		local health_panel = self._custom_player_panel:child("health_panel")
		local armor_value = health_panel:child("armor_value")
		local health_value = health_panel:child("health_value")
		local timer = condition_timer
		if t and t > 1 and timer then
			timer:stop()
			timer:animate(function(o)
				o:set_visible(true)
				if self._main_player and VoidUI.options.main_health then
					armor_value:set_visible(false)
					health_value:set_visible(false)
				end
				local t_left = t
				while t_left >= 0.1 do
					self._armor_invulnerability_timer = true
					t_left = t_left - coroutine.yield()
					t_format = t_left < 9.9 and "%.1f" or "%.f"
					o:set_text(string.format(t_format, t_left))
					o:set_color(EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimerColor") or Color.blue)
				end
				self._armor_invulnerability_timer = false
				o:set_visible(false)
				if self._main_player and VoidUI.options.main_health then
				armor_value:set_visible(true)
				health_value:set_visible(true)
				end
			end)
		end
	end

elseif RequiredScript == "lib/managers/hudmanagerpd2" and VoidUI.options.enable_assault then
	function HUDInspire:init(hud)
			local assault_corner = managers.hud and managers.hud._hud_assault_corner	
			local icons_panel = assault_corner._custom_hud_panel:child("icons_panel")
			local cuffed_panel = icons_panel:child("cuffed_panel")
			local hostages_panel = icons_panel:child("hostages_panel")
			local parent_panel = (VoidUI.options.hostages or assault_corner:should_display_waves()) and cuffed_panel or hostages_panel
			local highlight_texture = "guis/textures/VoidUI/hud_highlights"
			self._scale = VoidUI.options.hud_assault_scale
			local panel_w, panel_h = 44 * self._scale, 38 * self._scale
			self._hud_panel = hud.panel
			self._inspire_panel = icons_panel:panel({
				name = "inspire_timer_panel",
				alpha =	1,
				visible = false,
				w = panel_w,
				h = panel_h
			})
			self._inspire_panel:set_right(parent_panel:left())

			self._inspire_panel_bg = self._inspire_panel:bitmap({
				name = "kills_background",
				texture = highlight_texture,
				texture_rect = {0,316,171,150},
				layer = 1,
				w = panel_w,
				h = panel_h,
				color = Color.black
			})
			
			self._inspire_panel_border = self._inspire_panel:bitmap({
				name = "kills_border",
				texture = highlight_texture,
				texture_rect = {172,316,171,150},
				layer = 2,
				w = panel_w,
				h = panel_h,
			})
			
			self._text = self._inspire_panel:text({
				name = "text",
				text = "0",
				valign = "center",
				vertical = "bottom",
				align = "right",
				w = panel_w / 1.2,
				h = panel_h,
				layer = 3,
				x = 0,
				y = 0,
				color = Color.white,
				font = "fonts/font_medium_shadow_mf",
				font_size = panel_h / 2
			})
			
			local inspire_icon = self._inspire_panel:bitmap({
				name = "inspire_icon",
				texture = "EIVHUD/hud_icon_inspire",
				valign = "top",
				alpha = 0.6,
				layer = 2,
				w = panel_w / 2.2,
				h = panel_h / 1.8,
				x = 0,
				y = 0
			})

			inspire_icon:set_center(self._inspire_panel_border:center())

			self._show_hostages = EIVHUD.Options:GetValue("HUD/ShowHostages")
			self._show_waves = EIVHUD.Options:GetValue("HUD/ShowWaves")
	end

	function HUDInspire:update_position()
		return
	end

	function HUDECMCounter:update() 
		return 
	end
	if EIVHUD.Options:GetValue("HUD/Converts") and EIVHUD.Options:GetValue("HUD/ShowHostages") == 1 then
		function HUDConverts:update()
			self._convert_panel:set_visible(false)
		end
	end

elseif RequiredScript == "lib/managers/hud/newhudstatsscreen" then
	if EIVHUD and EIVHUD.Options:GetValue("HUD/Tab") and VoidUI.options.enable_stats then
		local _HUDStatsScreen_update_stats_screen_loot = HUDStatsScreen._update_stats_screen_loot
		function HUDStatsScreen:_update_stats_screen_loot(extras_panel, top_panel)
			_HUDStatsScreen_update_stats_screen_loot(self, extras_panel, top_panel)

			local secured_amount = managers.loot:get_secured_mandatory_bags_amount()
			local bonus_amount = managers.loot:get_secured_bonus_bags_amount()
			local body_bag = managers.groupai and managers.groupai:state():whisper_mode() and managers.localization:text("hud_body_bags")..": "..tostring(managers.player:get_body_bags_amount()).." | " or ""
			local hit_accuracy = managers.statistics:session_hit_accuracy()
			local small_loot = managers.loot:get_real_total_small_loot_value()
			local instant_cash = small_loot > 0 and " Ї "..managers.localization:text("hud_instant_cash")..": "..managers.experience:cash_string(small_loot) or ""
			local accuracy = VoidUI.options.scoreboard_accuracy and hit_accuracy and utf8.to_lower(managers.localization:text("menu_stats_hit_accuracy")):gsub("^%l", string.upper).." ".. hit_accuracy.."%" or ""
			local trade_delay = managers.money:get_trade_delay() > 30
			local delay = VoidUI.options.scoreboard_delay and trade_delay and " | "..managers.localization:text("hud_trade_delay", {TIME = self:_trade_delay_time()}) or ""
			local loot_amount = "";
			if managers.interaction:get_current_total_loot_count() > 0 then
				local border_crossing_fix = Global.game_settings.level_id == "mex" and  managers.interaction:get_current_total_loot_count() > 41 and "/4";
				loot_amount = border_crossing_fix or "/" .. managers.interaction:get_current_total_loot_count();
			end
			local secured_loot = secured_amount + bonus_amount
			local bags = " | "..utf8.to_lower(managers.localization:text("hud_stats_bags_secured")):gsub("^%l", string.upper)..": "..tostring(secured_loot .. loot_amount)
			top_panel:child("loot_stats"):set_text(body_bag..accuracy..delay..bags..instant_cash)
			top_panel:child("loot_stats_shadow"):set_text(body_bag..accuracy..delay..bags..instant_cash)
		end
	end
	
elseif RequiredScript == "lib/managers/hud/hudobjectives" then
	if EIVHUD.Options:GetValue("HUD/ShowObjectives") ~= 1 and VoidUI.options.enable_objectives then
		Hooks:OverrideFunction(HUDObjectives, "activate_objective", function(self, data)
			if data.id == self._active_objective_id then
				return
			end
			local objectives_panel = self._hud_panel:child("objectives_panel")
			local objective_panel = self._objectives[#self._objectives]
			self._active_objective_id = data.id	
			if objective_panel ~= nil and objective_panel:child("objective_border"):alpha() ~= 1 then
				objective_panel:animate(callback(self, self, "_animate_complete_objective"))
			end
			
			if #self._objectives > self._max_objectives then 
				self._objectives[1]:animate(callback(self, self, "_animate_remove_objective"))
				table.remove(self._objectives, 1)
				for i = 1, #self._objectives do
					self._objectives[i]:animate(callback(self, self, "_animate_objective_list"), i - 1)
				end
			end
			self:create_objective(data.id, data)
			if data.amount then
				self:update_amount_objective(data)
			end
		end)
	end

elseif RequiredScript == "lib/managers/hud/hudheisttimer" then
	if EIVHUD.Options:GetValue("HUD/ShowTimer") ~= 1 and VoidUI.options.enable_timer then
		function HUDHeistTimer:set_timer_text()
			return
		end
	end
end