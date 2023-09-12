if EIVHUD.Options:GetValue("HUD/ShowHostages") > 1 then 
	Hooks:PostHook(HUDAssaultCorner, "init", "EIVHUD_HUDAssaultCorner_init", function(self, hud, ...)
		if self._hostages_bg_box then
			local hostages_icon = self._hud_panel:child("hostages_panel"):child( "hostages_icon" )
			self._hostages_bg_box:hide()
			self._hostages_bg_box:set_alpha(0)		
			hostages_icon:set_visible(false)
			hostages_icon:set_alpha(0)
		end
		self._hud_panel = hud.panel
		self:setup_wave_display(0, self._hud_panel:w() + 9)
	end)

	Hooks:PostHook(HUDAssaultCorner, "show_casing", "EIVHUD_HUDAssaultCorner_show_casing", function(self, ...)
		managers.hud._hud_ecm_counter._ecm_panel:set_top(50)
	end)

	Hooks:PostHook(HUDAssaultCorner, "hide_casing", "EIVHUD_HUDAssaultCorner_hide_casing", function(self, ...)
		managers.hud._hud_ecm_counter._ecm_panel:set_top(0)
	end)
end

if EIVHUD.Options:GetValue("HUD/ShowWaves") == 2 then
	Hooks:PostHook(HUDAssaultCorner, "setup_wave_display", "EIVHUD_HUDAssaultCorner_setup_wave_display", function(self, ...)
		if self:should_display_waves() then
			local wave_panel = self._hud_panel:child("wave_panel")
			local waves_icon = wave_panel:child("waves_icon")
			local num_waves = self._wave_bg_box:child("num_waves")
			wave_panel:set_visible(false)
			self._wave_bg_box:child("bg"):hide()
			self._wave_bg_box:child("left_top"):hide()
			self._wave_bg_box:child("left_bottom"):hide()
			self._wave_bg_box:child("right_top"):hide()
			self._wave_bg_box:child("right_bottom"):hide()
			waves_icon:set_alpha(0)
			num_waves:set_alpha(0)
		end
	end)
end