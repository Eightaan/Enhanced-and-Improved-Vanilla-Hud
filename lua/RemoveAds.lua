if not EIVHUD.Options:GetValue("MENU/HideAds") then 
	return 
end

if RequiredScript == "lib/managers/menu/newheistsgui" then
	Hooks:OverrideFunction(NewHeistsGui, "set_enabled", function(self)
		self._content_panel:set_visible(false)
	end)

elseif RequiredScript == "lib/managers/menu/menucomponentmanager" then
	Hooks:OverrideFunction(MenuComponentManager, "create_newsfeed_gui", function(self)
		self:close_newsfeed_gui()
	end)

elseif RequiredScript == "lib/managers/menumanager" then
	Hooks:OverrideFunction(MenuCallbackHandler, "get_latest_dlc_locked", function(self) return false end)
end