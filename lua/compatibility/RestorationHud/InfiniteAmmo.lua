if restoration and restoration:all_enabled("HUD/MainHUD", "HUD/Teammate") then
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
end