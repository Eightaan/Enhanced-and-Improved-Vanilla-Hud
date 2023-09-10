Hooks:PostHook(MenuSceneManager, "_set_up_environments", "HMH_MenuSceneManager_set_up_environments", function(self)
	if EIVHUD.Options:GetValue("MENU/MenuFilter") and self._environments and self._environments.standard and self._environments.standard.color_grading then
		self._environments.standard.color_grading = "color_off"
	end
end)