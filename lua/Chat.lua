if not EIVHUD.Options:GetValue("HUD/Chat") then
	return
end

local Color = Color

Hooks:PostHook(HUDChat, "init", "EIVHUD_HUDChat_init", function(self)
	local o = self._panel:child("output_panel")
	if alive(o) and alive(o:child("output_bg")) then
		local alpha = {blend_mode = "normal", gradient_points = {0, Color.black:with_alpha(0), 1, Color.black:with_alpha(0)}}
		o:child("output_bg"):configure(alpha)
		self._input_panel:child("input_bg"):configure(alpha)
	end
end)

Hooks:PostHook(HUDChat, "update_caret", "EIVHUD_HUDChat_update_caret", function(self, ...)
	self._input_panel:child("input_bg"):set_gradient_points({
		0, Color.white:with_alpha(0), 0, Color.white:with_alpha(0), 1, Color.white:with_alpha(0)
	})
end)