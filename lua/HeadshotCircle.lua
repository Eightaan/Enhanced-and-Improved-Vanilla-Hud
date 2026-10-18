if RequiredScript == "lib/managers/hud/hudhitconfirm" then
	Hooks:PostHook(HUDHitConfirm, "init", "EIVHUD_PlayerManager_init", function (self)
		if self._hud_panel:child("headshot_confirm") then
			self._hud_panel:remove(self._hud_panel:child("headshot_confirm"))
		end
		self._headshot_confirm = self._hud_panel:bitmap({
			valign = "center",
			halign = "center",
			visible = false,
			name = "headshot_confirm",
			texture = "EIVHUD/HeadshotCircle",
			color = Color("ff3633"),
			layer = 1,
			blend_mode = "normal"
		})
		self._headshot_confirm:set_center(self._hud_panel:w() / 2, self._hud_panel:h() / 2)
	end)

	function HUDHitConfirm:on_headshot_confirmed()
		self._headshot_confirm:stop()
		self._headshot_confirm:animate(callback(self, self, "_animate_show"), callback(self, self, "show_done"), 0.25, 0.20)
	end

elseif RequiredScript == "lib/managers/playermanager" then
	Hooks:PostHook(PlayerManager, "on_headshot_dealt", "EIVHUD_PlayerManager_on_headshot_dealt", function (self)
		if EIVHUD.Options:GetValue("HUD/HeadshotCircle") then
			managers.hud:on_headshot_confirmed()
		end
	end)
end