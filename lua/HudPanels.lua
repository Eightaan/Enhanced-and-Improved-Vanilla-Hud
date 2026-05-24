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
				self:set_timer_text()
			end
		end)
		function HUDHeistTimer:set_timer_text()
			self._timer_text:set_alpha(0)
		end
	end
elseif RequiredScript == "lib/managers/hud/hudpresenter" then
	Hooks:PostHook(HUDPresenter, "_present_information", "EIVHUD_HUDPresenter_present_information", function(self, params, ...)
		if EIVHUD.Options:GetValue("HUD/Presenter") ~= 1 then
			local present_panel = self._hud_panel:child("present_panel")
			local title = self._bg_box:child("title")
			local text = self._bg_box:child("text")

			title:set_text(utf8.to_upper(params.title or ""))
			text:set_text(utf8.to_upper(params.text))
			title:set_visible(false)
			text:set_visible(false)

			local _, _, w, _ = title:text_rect()

			title:set_w(w)

			local _, _, w2, _ = text:text_rect()

			text:set_w(w2)

			local tw = math.max(w, w2)

			self._bg_box:set_w(tw + 16)
			self._bg_box:set_left(self._bg_box:parent():w() - self._bg_box:w())
			self._bg_box:set_y(150)

			if params.icon then end

			if params.event then
				managers.hud._sound_source:post_event(params.event)
			end

			local callback_params = {
				has_title = params.title ~= nil,
				seconds = params.time or 4,
				use_icon = params.icon,
				done_cb = callback(self, self, "_present_done")
			}

			present_panel:animate(callback(self, self, "_animate_present_information"), callback_params)

			self._presenting = true
		end
	end)
elseif RequiredScript == "lib/managers/hud/hudhint" then
	Hooks:PostHook(HUDHint, "show", "EIVHUD_show", function(self, ...)
		if EIVHUD.Options:GetValue("HUD/Hints") ~= 1 then
			self._hint_panel:set_top(50)
		end
	end)
end