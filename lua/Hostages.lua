local new_option = EIVHUD.Options:GetValue("HUD/ShowHostages") > 1
if not new_option then 
	return
end

Hooks:PostHook(HUDAssaultCorner, "init", "HMH_HUDAssaultCorner_init", function(self, hud, ...)
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

Hooks:PostHook(HUDAssaultCorner, "show_casing", "HMH_HUDAssaultCorner_show_casing", function(self, ...)
	managers.hud._hud_ecm_counter._ecm_panel:set_top(50)
end)

Hooks:PostHook(HUDAssaultCorner, "hide_casing", "HMH_HUDAssaultCorner_hide_casing", function(self, ...)
	managers.hud._hud_ecm_counter._ecm_panel:set_top(0)
end)