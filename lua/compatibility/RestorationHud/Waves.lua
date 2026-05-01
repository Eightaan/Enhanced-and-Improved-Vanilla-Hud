if restoration and restoration:all_enabled("HUD/MainHUD", "HUD/AssaultPanel") then
	function HUDAssaultCorner:wave_display()
		local waves = self._hud_panel:child("wave_panel")
		if waves and EIVHUD.Options:GetValue("HUD/ShowWaves") ~= 1 then
			waves:set_alpha(0)
		end
	end
end