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
EIVHUD.show_waves = {
	"Show_on_hud",
	"Tabstats",
	"Both"
}
EIVHUD.show_timer = {
	"Show_on_hud",
	"Tabstats",
	"Both"
}
EIVHUD.show_objectives = {
	"Show_on_hud",
	"Tabstats",
	"Both"
}

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_EIVH", function(loc)
	local localized_strings = {}
	if EIVHUD.Options:GetValue("MENU/SkipBlackscreen") then
		localized_strings["hud_skip_blackscreen"] = ""
	end
	localized_strings["hud_instruct_mask_on"] = ""
	loc:add_localized_strings(localized_strings)
end)