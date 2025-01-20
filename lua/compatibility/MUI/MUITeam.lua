if ArmStatic and MUIMenu and MUIMenu:ClassEnabled("MUITeammate") and MUIMenu:ClassEnabled("MUILegend") and MUIMenu:ClassEnabled("AnimatedList") then
	if RequiredScript == "lib/managers/hud/hudteammate" then
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

			function HUDTeammate:_update_cooldown_timer(t)
				local timer = self._condition_timer;
				if t and t > 1 and timer then
					timer:stop();
					timer:animate(function(o)
						o:set_visible(true);
						local t_left = t;
						while t_left >= 0.1 do
							self._armor_invulnerability_timer = true;
							t_left = t_left - coroutine.yield();
							t_format = t_left < 9.9 and "%.1f" or "%.f";
							o:set_text(string.format(t_format, t_left));
							o:set_color(EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimerColor") or Color.blue);
							o:set_alpha(self._main_player and not self._custardy and 1 or 0);
						end
						self._armor_invulnerability_timer = false;
						o:set_visible(false);
					end)
				end
			end

			function HUDTeammate:_animate_invulnerability(duration)
				 self._ability_meter:animate(function(o)
					o:set_color(Color(1, 1, 1, 1));
					self._armor_invulnerability_timer = true;
					o:set_visible(true);
					over(duration, function(p)
						o:set_color(Color(1, 1 - p, 1, 1));
						o:set_alpha(self._main_player and not self._custardy and 1 or 0);
					end)
					if not EIVHUD.Options:GetValue("HUD/PLAYER/ArmorerCooldownTimer") then
						self._armor_invulnerability_timer = false;
					end
					o:set_visible(false);
				end)
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

	elseif RequiredScript == "lib/managers/hudmanagerpd2" then
		function HUDManager:set_teammate_ammo_amount(id, selection_index, max_clip, current_clip, current_left, max_left)
			self._teammate_panels[id]:set_ammo_amount_by_type(selection_index, max_clip, current_clip, current_left, max_left)
			self._teammate_panels[id]:set_inf_ammo_amount_by_type()
		end
	end
end