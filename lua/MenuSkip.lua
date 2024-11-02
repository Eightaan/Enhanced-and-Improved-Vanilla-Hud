if RequiredScript == "lib/states/ingamewaitingforplayers" then
	Hooks:PostHook(IngameWaitingForPlayersState, "update", "EIVHUD_IngameWaitingForPlayersState_update", function(self, ...)
		local skipPromtShown = self._skip_promt_shown
		local skipBlackScreen = EIVHUD.Options:GetValue("MENU/SkipBlackscreen")
		if skipPromtShown and skipBlackScreen then
			self:_skip()
		end
	end)

elseif RequiredScript == "lib/managers/menu/stageendscreengui" then
	Hooks:PostHook(StageEndScreenGui, "init", "EIVHUD_StageEndScreenGui_init", function(self, ...)
		if self._enabled and managers.hud then
			managers.hud:set_speed_up_endscreen_hud(5)
		end
	end)

	Hooks:PostHook(StageEndScreenGui, "update", "EIVHUD_StageEndScreenGui_update", function(self, t, ...)
		if not self._button_not_clickable then
			local skipXPValue = EIVHUD.Options:GetValue("MENU/SkipXP")
			if skipXPValue > 0 then
				self._auto_continue_t = self._auto_continue_t or (t + skipXPValue)
				local gsm = game_state_machine:current_state()
				if gsm and gsm._continue_cb and not (gsm._continue_blocked and gsm:_continue_blocked()) and t >= self._auto_continue_t then
					managers.menu_component:post_event("menu_enter")
					gsm._continue_cb()
				end
			end
		end
	end)

elseif RequiredScript == "lib/managers/menu/lootdropscreengui" then
	Hooks:PostHook(LootDropScreenGui, "update", "EIVHUD_LootDropScreenGui_update", function(self, t, ...)
		if not self._card_chosen and EIVHUD.Options:GetValue("MENU/PickCard") then
			self:_set_selected_and_sync(math.random(3))
			self:confirm_pressed()
		end

		if not self._button_not_clickable then
			local skipCardValue = EIVHUD.Options:GetValue("MENU/SkipCard")
			if skipCardValue > 0 then
				self._auto_continue_t = self._auto_continue_t or (t + skipCardValue)
				local gsm = game_state_machine:current_state()
				if gsm and not (gsm._continue_blocked and gsm:_continue_blocked()) and t >= self._auto_continue_t then
					self:continue_to_lobby()
				end
			end
		end
	end)

elseif RequiredScript == "lib/managers/missionassetsmanager" then    
	if EIVHUD.Options:GetValue("MENU/SkipDialogs") then
		local function expect_yes(self, params)
			params.yes_func()
		end
		local confirmations = {
			"show_confirm_mission_asset_buy_all",
			"show_confirm_buy_premium_contract",
			"show_confirm_blackmarket_buy_mask_slot",
			"show_confirm_blackmarket_buy_weapon_slot",
			"show_confirm_mission_asset_buy",
			"show_confirm_pay_casino_fee",
			"show_confirm_blackmarket_sell",
			"show_confirm_blackmarket_mod"
		}
		
		for _, method in ipairs(confirmations) do
			MenuManager[method] = expect_yes
		end
	end    
end