if ArmStatic and MUIMenu and MUIMenu:ClassEnabled("MUIStats") and MUIStats then
    Hooks:Add("HUDManagerSetupPlayerInfoHudPD2", "EIVHUD_MUI_setup", function(self)
		dofile(EIVHUD.ModPath .. "lua/compatibility/MUI/MUIStats.lua")
    end)

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
