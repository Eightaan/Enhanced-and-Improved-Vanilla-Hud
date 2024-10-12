if not EIVHUD.Options:GetValue("HUD/Chat") or VHUDPlus and VHUDPlus:getSetting({"HUDChat", "ENABLED"}, true) then
	return
end

Hooks:PostHook(HUDChat, "init", "EIVHUD_HUDChat_init", function(self, ws, hud, ...)
	self._ws = ws
	self._hud_panel = hud.panel

	self:set_channel_id(ChatManager.GAME)

	self._output_width = 300
	self._panel_width = 500
	self._lines = {}
	self._esc_callback = callback(self, self, "esc_key_callback")
	self._enter_callback = callback(self, self, "enter_key_callback")
	self._typing_callback = 0
	self._skip_first = false
	self._panel = self._hud_panel:panel({
		name = "chat_panel",
		h = 500,
		halign = "left",
		x = 0,
		valign = "bottom",
		w = self._panel_width
	})

	self._panel:set_bottom(self._panel:parent():h() - 112)

	local output_panel = self._panel:panel({
		name = "output_panel",
		h = 10,
		x = 0,
		layer = 1,
		w = self._output_width
	})

	output_panel:gradient({
		blend_mode = "sub",
		name = "output_bg",
		valign = "grow",
		layer = -1,
		gradient_points = {
			0,
			Color.white:with_alpha(0),
			0,
			Color.white:with_alpha(0),
			1,
			Color.white:with_alpha(0)
		}
	})

	local scroll_panel = output_panel:panel({
		name = "scroll_panel",
		x = 0,
		h = 10,
		w = self._output_width
	})
	self._scroll_indicator_box_class = BoxGuiObject:new(output_panel, {
		sides = {
			0,
			0,
			0,
			0
		}
	})
	local scroll_up_indicator_shade = output_panel:bitmap({
		texture = "guis/textures/headershadow",
		name = "scroll_up_indicator_shade",
		visible = false,
		rotation = 180,
		layer = 2,
		color = Color.white,
		w = output_panel:w()
	})
	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
	local scroll_up_indicator_arrow = self._panel:bitmap({
		name = "scroll_up_indicator_arrow",
		layer = 2,
		texture = texture,
		texture_rect = rect,
		color = Color.white
	})
	local scroll_down_indicator_shade = output_panel:bitmap({
		texture = "guis/textures/headershadow",
		name = "scroll_down_indicator_shade",
		visible = false,
		layer = 2,
		color = Color.white,
		w = output_panel:w()
	})
	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
	local scroll_down_indicator_arrow = self._panel:bitmap({
		name = "scroll_down_indicator_arrow",
		layer = 2,
		rotation = 180,
		texture = texture,
		texture_rect = rect,
		color = Color.white
	})
	local bar_h = scroll_down_indicator_arrow:top() - scroll_up_indicator_arrow:bottom()
	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar")
	local scroll_bar = self._panel:panel({
		w = 15,
		name = "scroll_bar",
		layer = 2,
		h = bar_h
	})
	local scroll_bar_box_panel = scroll_bar:panel({
		name = "scroll_bar_box_panel",
		halign = "scale",
		w = 4,
		x = 5,
		valign = "scale"
	})
	self._scroll_bar_box_class = BoxGuiObject:new(scroll_bar_box_panel, {
		sides = {
			2,
			2,
			0,
			0
		}
	})

	output_panel:set_x(scroll_down_indicator_arrow:w() + 4)
	self:_create_input_panel()
	self:_layout_input_panel()
	self:_layout_output_panel(true)
end)

Hooks:PostHook(HUDChat, "update_caret", "EIVHUD_HUDChat_update_caret", function(self, ...)
	self._input_panel:child("input_bg"):set_gradient_points({
		0, Color.white:with_alpha(0), 0, Color.white:with_alpha(0), 1, Color.white:with_alpha(0)
	})
end)