if not _G.EIVH then
    _G.EIVH = {}
	EIVH.TotalKills = 0
	EIVH.CivKill = 0
end

EIVHUD.show_hostages = {
	"Show_on_hud",
	"Tabstats",
	"Hide_hostages"
}
EIVHUD.show_timer = {
	"Show_on_hud",
	"Tabstats",
	"both"
}
EIVHUD.show_objectives = {
	"Show_on_hud",
	"Tabstats",
	"both"
}

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