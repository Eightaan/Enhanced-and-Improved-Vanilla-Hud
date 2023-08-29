if RequiredScript == "lib/states/ingamewaitingforplayers" then
	Hooks:PostHook(IngameWaitingForPlayersState, "update", "EIVHUD_IngameWaitingForPlayersState_update", function(self, ...)
		if self._skip_promt_shown and EIVHUD.Options:GetValue("MENU/SkipBlackscreen") then
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
		if not self._button_not_clickable and EIVHUD.Options:GetValue("MENU/SkipXP") >= 0 and EIVHUD.Options:GetValue("MENU/SkipXP") > 0 then
			self._auto_continue_t = self._auto_continue_t or (t + EIVHUD.Options:GetValue("MENU/SkipXP"))
			local gsm = game_state_machine:current_state()
			if gsm and gsm._continue_cb and not (gsm._continue_blocked and gsm:_continue_blocked()) and t >= self._auto_continue_t then
				managers.menu_component:post_event("menu_enter")
				gsm._continue_cb()
			end
		end
	end)
elseif RequiredScript == "lib/managers/menu/lootdropscreengui" then
	Hooks:PostHook(LootDropScreenGui, "update", "EIVHUD_LootDropScreenGui_update", function(self, t, ...)
		if not self._card_chosen and EIVHUD.Options:GetValue("MENU/PickCard") then
			self:_set_selected_and_sync(math.random(3))
			self:confirm_pressed()
		end

		if not self._button_not_clickable and EIVHUD.Options:GetValue("MENU/SkipCard") >= 0 and EIVHUD.Options:GetValue("MENU/SkipCard") > 0 then
			self._auto_continue_t = self._auto_continue_t or (t + EIVHUD.Options:GetValue("MENU/SkipCard"))
			local gsm = game_state_machine:current_state()
			if gsm and not (gsm._continue_blocked and gsm:_continue_blocked()) and t >= self._auto_continue_t then
				self:continue_to_lobby()
			end
		end
	end)
elseif RequiredScript == "lib/managers/missionassetsmanager" then	
	if EIVHUD.Options:GetValue("MENU/SkipDialogs") then
		local function expect_yes(self, params) params.yes_func() end
		MenuManager.show_confirm_mission_asset_buy_all = expect_yes
		MenuManager.show_confirm_buy_premium_contract = expect_yes
		MenuManager.show_confirm_blackmarket_buy_mask_slot = expect_yes
		MenuManager.show_confirm_blackmarket_buy_weapon_slot = expect_yes
		MenuManager.show_confirm_mission_asset_buy = expect_yes
		MenuManager.show_confirm_pay_casino_fee = expect_yes
		MenuManager.show_confirm_mission_asset_buy_all = expect_yes
		MenuManager.show_confirm_blackmarket_sell = expect_yes
		MenuManager.show_confirm_blackmarket_mod = expect_yes
	end	
end