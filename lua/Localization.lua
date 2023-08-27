Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_EIVH", function(loc)
    local localized_strings = {}
	if EIVHUD.Options:GetValue("MENU/SkipBlackscreen") then
	    localized_strings["hud_skip_blackscreen"] = ""
	end
	if EIVHUD.Options:GetValue("HUD/HideMaskInstruction") then
		localized_strings["hud_instruct_mask_on"] = ""
	end
	localized_strings["menu_st_points_total"] = ""
    loc:add_localized_strings(localized_strings)
end)