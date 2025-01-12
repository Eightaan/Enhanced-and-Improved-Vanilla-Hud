local Color = Color

Hooks:PostHook(HUDManager, "set_teammate_custom_radial", "EIVHUD_HUDManager_set_teammate_custom_radial", function (self, i, data, ...)
	local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
	if not hud.panel:child("swan_song_left") then
		local swan_song_left = hud.panel:bitmap({
			name = "swan_song_left",
			visible = false,
			texture = "EIVHUD/screeneffect",
			layer = 0,
			color = Color(0, 0.7, 1),
			blend_mode = "add",
			w = hud.panel:w(),
			h = hud.panel:h(),
			x = 0,
			y = 0 
		})
	end

	local swan_song_left = hud.panel:child("swan_song_left")
	if i == 4 and data.current < data.total and data.current > 0 and swan_song_left then
		swan_song_left:set_visible(EIVHUD.Options:GetValue("HUD/ScreenEffect"))
		local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		swan_song_left:animate(hudinfo.flash_icon, 4000000000)
	elseif hud.panel:child("swan_song_left") then
		swan_song_left:stop()
		swan_song_left:set_visible(false)
	end
	if swan_song_left and data.current == 0 then
		swan_song_left:set_visible(false)
	end
end)

Hooks:PostHook(HUDManager, "set_teammate_ability_radial", "EIVHUD_HUDManager_set_teammate_ability_radial", function (self, i, data, ...)
	local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
	if not hud.panel:child("chico_injector_left") then
		local chico_injector_left = hud.panel:bitmap({
			name = "chico_injector_left",
			visible = false,
			texture = "EIVHUD/screeneffect",
			layer = 0,
			color = Color(1, 0.6, 0),
			blend_mode = "add",
			w = hud.panel:w(),
			h = hud.panel:h(),
			x = 0,
			y = 0 
		})
	end

	local chico_injector_left = hud.panel:child("chico_injector_left")
	if i == 4 and data.current < data.total and data.current > 0 and chico_injector_left then
		chico_injector_left:set_visible(EIVHUD.Options:GetValue("HUD/ScreenEffect"))
		local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		chico_injector_left:animate(hudinfo.flash_icon, 4000000000)
	elseif hud.panel:child("chico_injector_left") then
		chico_injector_left:stop()
		chico_injector_left:set_visible(false)
	end
	if chico_injector_left and data.current == 0 then
		chico_injector_left:set_visible(false)
	end
end)