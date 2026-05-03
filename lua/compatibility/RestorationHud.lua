if not restoration then return end
if RequiredScript == "lib/managers/hud/hudteammate" and restoration:all_enabled("HUD/MainHUD", "HUD/Teammate") then
	function HUDTeammate:infinite_ammo_glow()
		self._prim_ammo = self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):bitmap({
			align = "center",
			w = 55,
			h = 40,
			name = "primary_ammo",
			visible = false,
			texture = "guis/textures/pd2/crimenet_marker_glow",
			texture_rect = { 1, 1, 62, 62 }, 
			color = Color("00AAFF"),
			layer = 2,
			blend_mode = "add"
		})
		self._sec_ammo = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):bitmap({
			align = "center",
			w = 55,
			h = 40,
			name = "secondary_ammo",
			visible = false,
			texture = "guis/textures/pd2/crimenet_marker_glow",
			texture_rect = { 1, 1, 62, 62 }, 
			color = Color("00AAFF"),
			layer = 2,
			blend_mode = "add"
		})
		self._prim_ammo:set_center_y(self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):y() + self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):h() / 2)
		self._sec_ammo:set_center_y(self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):y() + self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):h() / 2)
		self._prim_ammo:set_center_x(self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):x() + self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):w() / 2- 2)
		self._sec_ammo:set_center_x(self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):x() + self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):w() / 2 - 2)
	end

elseif RequiredScript == "lib/managers/hudmanagerpd2" and restoration:all_enabled("HUD/MainHUD", "HUD/AssaultPanel") then
	function HUDInspire:update_position()
		self._inspire_panel:set_top(200)
	end

	function HUDECMCounter:update()
		local is_stealth = managers.groupai and managers.groupai:state():whisper_mode()

		local current_time = TimerManager:game():time()
		local t = self._ecm_timer - current_time

		self._ecm_panel:set_visible(is_stealth and t > 0)

		if not is_stealth then
			return
		end
		
		self._ecm_panel:set_top(200)

		if t > 0.1 then
			self._text:set_text(string.format(t < 10 and "%.1fs" or "%.fs", t))
		end
	end
	
	if EIVHUD.Options:GetValue("HUD/Converts") and EIVHUD.Options:GetValue("HUD/ShowHostages") == 1 then
		function HUDConverts:update()
			self._convert_panel:set_visible(false)
		end
	end

elseif RequiredScript == "lib/managers/hud/hudassaultcorner" and restoration:all_enabled("HUD/MainHUD", "HUD/AssaultPanel") then
	function HUDAssaultCorner:wave_display()
		local waves = self._hud_panel:child("wave_panel")
		if waves and EIVHUD.Options:GetValue("HUD/ShowWaves") ~= 1 then
			waves:set_alpha(0)
		end
	end
end