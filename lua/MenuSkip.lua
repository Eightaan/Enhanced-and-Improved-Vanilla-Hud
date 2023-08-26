if RequiredScript == "lib/states/ingamewaitingforplayers" then
	Hooks:PostHook(IngameWaitingForPlayersState, "update", "IEVHUD_IngameWaitingForPlayersState_update", function(self, ...)
		if self._skip_promt_shown and IEVHUD.Options:GetValue("MENU/SkipBlackscreen") then
			self:_skip()
		end
	end)
elseif RequiredScript == "lib/managers/menu/stageendscreengui" then
	Hooks:PostHook(StageEndScreenGui, "init", "IEVHUD_StageEndScreenGui_init", function(self, ...)
		if self._enabled and managers.hud then
			managers.hud:set_speed_up_endscreen_hud(5)
		end
	end)

	Hooks:PostHook(StageEndScreenGui, "update", "IEVHUD_StageEndScreenGui_update", function(self, t, ...)
		if not self._button_not_clickable and IEVHUD.Options:GetValue("MENU/SkipXP") >= 0 and IEVHUD.Options:GetValue("MENU/SkipXP") > 0 then
			self._auto_continue_t = self._auto_continue_t or (t + IEVHUD.Options:GetValue("MENU/SkipXP"))
			local gsm = game_state_machine:current_state()
			if gsm and gsm._continue_cb and not (gsm._continue_blocked and gsm:_continue_blocked()) and t >= self._auto_continue_t then
				managers.menu_component:post_event("menu_enter")
				gsm._continue_cb()
			end
		end
	end)
elseif RequiredScript == "lib/managers/menu/lootdropscreengui" then
	Hooks:PostHook(LootDropScreenGui, "update", "IEVHUD_LootDropScreenGui_update", function(self, t, ...)
		if not self._card_chosen and IEVHUD.Options:GetValue("MENU/PickCard") then
			self:_set_selected_and_sync(math.random(3))
			self:confirm_pressed()
		end

		if not self._button_not_clickable and IEVHUD.Options:GetValue("MENU/SkipCard") >= 0 and IEVHUD.Options:GetValue("MENU/SkipCard") > 0 then
			self._auto_continue_t = self._auto_continue_t or (t + IEVHUD.Options:GetValue("MENU/SkipCard"))
			local gsm = game_state_machine:current_state()
			if gsm and not (gsm._continue_blocked and gsm:_continue_blocked()) and t >= self._auto_continue_t then
				self:continue_to_lobby()
			end
		end
	end)
end