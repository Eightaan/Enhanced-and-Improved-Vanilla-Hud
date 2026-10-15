if not Holo and Holo.ShouldModify and Holo:ShouldModify("HUD", "Teammate") then
	return
end

if RequiredScript == "lib/managers/hudmanagerpd2" then
	local original_set_teammate_ammo_amount = HUDManager.set_teammate_ammo_amount

	function HUDManager:set_teammate_ammo_amount(id, selection_index, max_clip, current_clip, current_left, max_left)
		original_set_teammate_ammo_amount(self, id, selection_index, max_clip, current_clip, current_left, max_left)
		local teammate = self._teammate_panels and self._teammate_panels[id]
		if teammate and teammate.set_inf_ammo_amount_by_type then
			teammate:set_inf_ammo_amount_by_type()
		end
	end

elseif RequiredScript == "lib/managers/hud/hudteammate" then
	local function get_ammo_clip(self, weapon)
		local player_panel = self._player_panel
		local weapons_panel = alive(player_panel) and player_panel:child("weapons_panel")
		local weapon_panel = alive(weapons_panel) and weapons_panel:child(weapon .. "_weapon_panel")
		return alive(weapon_panel) and weapon_panel:child("ammo_clip")
	end

	function HUDTeammate:_set_infinite_ammo(state)
		self._infinite_ammo = state
		self:set_inf_ammo_amount_by_type()
	end

	function HUDTeammate:set_inf_ammo_amount_by_type()
		if not self._main_player then
			return
		end

		for _, weapon in ipairs({"primary", "secondary"}) do
			local ammo_clip = get_ammo_clip(self, weapon)
			if alive(ammo_clip) then
				if self._infinite_ammo then
					ammo_clip:set_text("8")
					ammo_clip:set_color(Color.white)
					ammo_clip:set_rotation(90)
				else
					ammo_clip:set_rotation(0)
				end
			end
		end
	end

	local original_set_ammo_amount_by_type = HUDTeammate.set_ammo_amount_by_type
	function HUDTeammate:set_ammo_amount_by_type(...)
		original_set_ammo_amount_by_type(self, ...)
		self:set_inf_ammo_amount_by_type()
	end
end