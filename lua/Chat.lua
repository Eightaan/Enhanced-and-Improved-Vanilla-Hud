if not EIVHUD.Options:GetValue("HUD/Chat") then
	return
end

local function update_chat_position(self)
	if alive(self._panel) then
		self._panel:set_bottom(self._panel:parent():h() - (EIVHUD.Options:GetValue("HUD/ChatPosition") * 10))
	end
	local output = self._panel:child("output_panel")
	local input = self._input_panel
	if alive(output) then
		local bg = output:child("output_bg")
		if alive(bg) then
			bg:set_visible(false)
		end
	end
	if alive(input) then
		local bg = input:child("input_bg")
		if alive(bg) then
			bg:set_visible(false)
		end
	end
end

Hooks:PostHook(HUDChat, "update_caret", "EIVHUD_HUDChat_update_caret", update_chat_position)
Hooks:PostHook(HUDChat, "receive_message", "EIVHUD_HUDChat_receive_message", update_chat_position)