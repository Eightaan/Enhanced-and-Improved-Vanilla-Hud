if ArmStatic and MUIMenu and MUIMenu:ClassEnabled("MUIStats") and MUIStats then
    Hooks:Add("HUDManagerSetupPlayerInfoHudPD2", "EIVHUD_MUI_setup", function(self)
		dofile(EIVHUD.ModPath .. "lua/compatibility/MUI/MUIStats.lua")
    end)
end
