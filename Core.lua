EIVHUD.show_hostages = {
	"Show_on_hud",
	"Tabstats",
	"Hide"
}
EIVHUD.show_waves = {
	"Show_on_hud",
	"Tabstats",
	"Hide"
}
EIVHUD.show_timer = {
	"Show_on_hud",
	"Tabstats",
	"Hide"
}
EIVHUD.show_objectives = {
	"Show_on_hud",
	"Tabstats",
	"Hide"
}

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_EIVH", function(loc)
	local localized_strings = {}
	if EIVHUD.Options:GetValue("MENU/SkipBlackscreen") then
		localized_strings["hud_skip_blackscreen"] = ""
	end
	localized_strings["hud_instruct_mask_on"] = ""
	loc:add_localized_strings(localized_strings)
end)