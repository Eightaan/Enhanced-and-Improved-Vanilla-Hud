if RequiredScript == "lib/managers/hud/hudassaultcorner" then
	local function safe_child(parent, name)
		return parent and parent:child(name)
	end

	local function hide_element(element)
		if alive(element) then
			element:set_visible(false)
			element:set_alpha(0)
		end
	end

	local function hide_elements(elements)
		for _, element in ipairs(elements) do
			hide_element(element)
		end
	end

	Hooks:PostHook(HUDAssaultCorner, "init", "EIVHUD_HUDAssaultCorner_init", function(self, hud, ...)
		if EIVHUD.Options:GetValue("HUD/ShowHostages") ~= 1 then 
			self:hostages_display()
		end
		self:wave_display()
	end)


	function HUDAssaultCorner:hostages_display()
		local hostages_panel = safe_child(self._hud_panel, "hostages_panel")
		hide_elements({
			self._hostages_bg_box,
			safe_child(hostages_panel, "hostages_icon")
		})
	end
	
	function HUDAssaultCorner:wave_display()
		if self.setup_wave_display and EIVHUD.Options:GetValue("HUD/ShowHostages") ~= 1 then
			self:setup_wave_display(0, self._hud_panel:w() + 9)
		end
	end

	if EIVHUD.Options:GetValue("HUD/ShowWaves") ~= 1 then
		Hooks:PostHook(HUDAssaultCorner, "setup_wave_display", "EIVHUD_HUDAssaultCorner_setup_wave_display", function(self, ...)
			if not self.should_display_waves or not self:should_display_waves() then return end
			local wave_panel = safe_child(self._hud_panel, "wave_panel")
			hide_elements({
				wave_panel,
				self._wave_bg_box and safe_child(self._wave_bg_box, "bg"),
				self._wave_bg_box and safe_child(self._wave_bg_box, "left_top"),
				self._wave_bg_box and safe_child(self._wave_bg_box, "left_bottom"),
				self._wave_bg_box and safe_child(self._wave_bg_box, "right_top"),
				self._wave_bg_box and safe_child(self._wave_bg_box, "right_bottom"),
				safe_child(wave_panel, "waves_icon"),
				self._wave_bg_box and safe_child(self._wave_bg_box, "num_waves")
			})
		end)
	end

elseif RequiredScript == "lib/managers/hud/hudobjectives" then
	if EIVHUD.Options:GetValue("HUD/ShowObjectives") ~= 1 then
		Hooks:OverrideFunction(HUDObjectives, "activate_objective", function(self, data)
			if not self._hud_panel then return end

			local objectives_panel = self._hud_panel:child("objectives_panel")
			if alive(objectives_panel) then
				objectives_panel:set_alpha(0)
				objectives_panel:set_visible(false)
			end
		end)
	end

elseif RequiredScript == "lib/managers/hud/hudheisttimer" then
	if EIVHUD.Options:GetValue("HUD/ShowTimer") ~= 1 then
		Hooks:PostHook(HUDHeistTimer, "init", "EIVHUD_HUDHeistTimer_init", function(self)
			if alive(self._timer_text) then
				self._timer_text:set_alpha(0)
			end
		end)
	end
end