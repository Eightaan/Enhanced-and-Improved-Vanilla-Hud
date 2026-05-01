if restoration and restoration:all_enabled("HUD/MainHUD", "HUD/AssaultPanel") then
	function HUDInspire:update_position()
		self._inspire_panel:set_top(200)
	end

	function HUDECMCounter:update()
		local is_stealth = managers.groupai and managers.groupai:state():whisper_mode()

		local current_time = TimerManager:game():time()
		local t = self._ecm_timer - current_time

		self._ecm_panel:set_visible(is_stealth and t > 0)

		if not is_stealth then
			return
		end
		
		self._ecm_panel:set_top(200)

		if t > 0.1 then
			self._text:set_text(string.format(t < 10 and "%.1fs" or "%.fs", t))
		end
	end
end