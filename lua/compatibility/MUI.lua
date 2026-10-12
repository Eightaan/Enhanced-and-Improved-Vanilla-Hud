if MUIMenu then
	if RequiredScript == "lib/managers/hudmanagerpd2" then
		if MUIMenu:ClassEnabled("MUIStats") and MUIStats then
			local MUIStats = MUIStats
			if EIVHUD and EIVHUD.Options:GetValue("HUD/Tab") then
				local _MUI_loot_value_updated = MUIStats.loot_value_updated
				function MUIStats:loot_value_updated()
					_MUI_loot_value_updated(self)
					local loot = self._bag_panel:child("amount")
					local secured = managers.loot:get_secured_mandatory_bags_amount() + managers.loot:get_secured_bonus_bags_amount()
					local carrying, loot_amount = managers.interaction:get_current_carry_count(), managers.interaction:get_current_total_loot_count()
					local total = loot_amount + carrying + secured
					local loot_text = total > 0 and "/" .. total or ""
					local total_crates = managers.interaction:get_current_crate_count()
					local crate_text = total_crates > 0 and " + (" .. total_crates .. ")" or ""

					loot:set_text(tostring(secured) .. loot_text .. crate_text)
					self:resize_loot()
				end
			end

			if EIVHUD.Options:GetValue("HUD/Converts") and EIVHUD.Options:GetValue("HUD/ShowHostages") == 1 then
				function HUDConverts:init(hud) end
				function HUDConverts:_refresh_minion_text() end
			end

			function HUDInspire:update_position()
				local offset = 5
				self._inspire_panel:set_top(0)
				self._inspire_panel:set_right(self._hud_panel:w() + offset)
			end
		end
		if MUIMenu:ClassEnabled("MUITeammate") then
			function HUDManager:set_teammate_ammo_amount(id, selection_index, max_clip, current_clip, current_left, max_left)
				self._teammate_panels[id]:set_ammo_amount_by_type(selection_index, max_clip, current_clip, current_left, max_left)
				self._teammate_panels[id]:set_inf_ammo_amount_by_type()
			end
		end

	elseif RequiredScript == "lib/managers/hud/hudteammate" then
		if MUIMenu:ClassEnabled("MUITeammate") then
			function HUDTeammate:_set_infinite_ammo(state)
				self._infinite_ammo = state;
				if self._infinite_ammo then
					self._primary_ammo_clip:set_color(Color.white);
					self._primary_ammo_clip:set_text("8");
					self._primary_ammo_clip:set_rotation(90);
					self._secondary_ammo_clip:set_color(Color.white);
					self._secondary_ammo_clip:set_text("8");
					self._secondary_ammo_clip:set_rotation(90);
				end
			end
			
			function HUDTeammate:_update_condition_display()
				local timer = self._condition_timer
				local armorer = self._armorer_time_left
				local grace = self._grace_time_left
				if not armorer and not grace then
				timer:set_visible(false)
					return
				end

				local t_left, color
				if armorer and (not grace or armorer < grace) then
					t_left = armorer
					color = EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimerColor") or Color.blue
				else
					t_left = grace
					color = EIVHUD.Options:GetValue("HUD/PLAYER/GraceCooldownTimerColor") or Color.green
				end

				timer:set_visible(true)
				timer:set_text(string.format(t_left < 9.9 and "%.1f" or "%.f", t_left))
				timer:set_color(color)
				timer:set_alpha(self._main_player and not self._custardy and 1 or 0)
			end

			function HUDTeammate:_update_cooldown_timer(t)
				if not t or t <= 1 then
					return
				end

				if not self._radial_armor then
					self:create_radial_display()
				end
				self._radial_armor:animate(function()
					local t_left = t
					while t_left >= 0.1 do
						t_left = t_left - coroutine.yield()
						self._armorer_time_left = t_left

						self:_update_condition_display()
					end
					self._armorer_time_left = nil
					self:_update_condition_display()
				end)
			end
			function HUDTeammate:_health_cooldown_timer(t)
				if not t or t <= 1 then
					return
				end

				if not self._radial_grace then
					self:create_radial_display()
				end

				self._radial_grace:animate(function()
					local t_left = t + 13

					while t_left >= 0.1 do
						t_left = t_left - coroutine.yield()

						self._grace_time_left = t_left

						self:_update_condition_display()
					end

					self._grace_time_left = nil

					self:_update_condition_display()
				end)
			end
			function HUDTeammate:_animate_invulnerability(duration)
				if not self._radial_armor then self:create_radial_display() end
				self._radial_armor:animate(function(o)
					o:set_color(Color(1, 1, 1, 1));
					o:set_visible(true);
					over(duration, function(p)
						o:set_color(Color(1, 1 - p, 1, 1));
						o:set_alpha(self._main_player and not self._custardy and 1 or 0);
					end)
					o:set_visible(false);
				end)
			end
			
			function HUDTeammate:_animate_health_invulnerability(duration)
				if not self._radial_health_panel then return; end
				if not self._radial_grace then self:create_radial_display() end
				self._radial_grace:animate(function (o)
					o:set_color(Color(1, 1, 1, 1))
					o:set_alpha(self._main_player and not self._custardy and 1 or 0);
					o:set_visible(true)
					over(duration, function (p)
						o:set_color(Color(1, 1 - p, 1, 1))
					end)
					o:set_visible(false)
				end)
			end

			function HUDTeammate:create_radial_display()
				local panel = self._radial_health_panel
				self._radial_armor = panel:bitmap({
					texture = "guis/textures/pd2/hud_swansong",
					name = "radial_armor",
					blend_mode = "add",
					visible = false,
					render_template = "VertexColorTexturedRadial",
					layer = 5,
					color = Color(1, 0, 0, 0),
					w = panel:w(),
					h = panel:h()
				})
				self._radial_grace = panel:bitmap({
					texture = "EIVHUD/animate_health_circle",
					name = "radial_health",
					blend_mode = "add",
					visible = false,
					render_template = "VertexColorTexturedRadial",
					layer = 5,
					color = Color(1, 0, 0, 0),
					w = panel:w(),
					h = panel:h()
				})
			end

			function HUDTeammate:set_inf_ammo_amount_by_type()
				if self._main_player and self._infinite_ammo then
					self._primary_ammo_clip:set_text("8");
					self._secondary_ammo_clip:set_text("8");

					self._primary_ammo_clip:set_color(Color.white);
					self._secondary_ammo_clip:set_color(Color.white);

					self._primary_ammo_clip:set_rotation(90);
					self._secondary_ammo_clip:set_rotation(90);
				else
					self._primary_ammo_clip:set_rotation(0);
					self._secondary_ammo_clip:set_rotation(0);
				end
			end
		end
	end
end