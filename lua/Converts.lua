if EIVHUD.Options:GetValue("HUD/Converts") and EIVHUD.Options:GetValue("HUD/ShowHostages") == 1 then
	Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "convert_setup_player_info_hud_pd2", function(self, ...)
		self._hud_converts = HUDConverts:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
		self:add_updator("EIVHUD_CONVERTS_UPDATOR", callback(self._hud_converts, self._hud_converts, "update"))
	end)

	HUDConverts = HUDConverts or class()
	function HUDConverts:init(hud)
		self._hud_panel = hud.panel
		local assault_corner = managers.hud and managers.hud._hud_assault_corner
		local waves = assault_corner and assault_corner:should_display_waves() and EIVHUD.Options:GetValue("HUD/ShowWaves") == 1
		self._parent = waves and self._hud_panel:child("wave_panel") or self._hud_panel:child("hostages_panel")

		self._convert_panel = self._hud_panel:panel({
			name = "convert_panel",
			alpha =	1,
			visible = false,
			w = 200,
			h = 200
		})
		self._convert_panel:set_right(self._parent:left())
		self._convert_panel:set_top(self._parent:top())
		
		local convert_box = HUDBGBox_create(self._convert_panel, { w = 38, h = 38, },  {})

		self._text = convert_box:text({
			name = "text",
			text = "0",
			valign = "center",
			align = "center",
			vertical = "center",
			w = convert_box:w(),
			h = convert_box:h(),
			layer = 1,
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = tweak_data.hud_corner.numhostages_size * 0.9
		})

		local icon_scale = 6
		local convert_icon = self._convert_panel:bitmap({
			name = "convert_icon",
			texture = "guis/textures/pd2/skilltree/icons_atlas",
			texture_rect = { 6 * 64, 8 * 64, 64, 64 },
			valign = "top",
			color = Color.white,
			layer = 1,
			w = convert_box:w() - icon_scale,
			h = convert_box:h() - icon_scale
		})
		convert_icon:set_right(convert_box:parent():w())
		convert_icon:set_center_y(convert_box:h() / 2)
		convert_box:set_right(convert_icon:left())
	end
	
	function HUDConverts:update()
		local is_stealth = managers.groupai and managers.groupai:state():whisper_mode()
		local converts = managers.player:has_category_upgrade("player", "convert_enemies")
		self._convert_panel:set_visible(converts and not is_stealth)
		if not converts or is_stealth then
			return
		end

		self._text:set_text(tostring(managers.player:num_local_minions()))
		self._convert_panel:set_right(self._parent:left())
		self._convert_panel:set_top(self._parent:top())
	end
end