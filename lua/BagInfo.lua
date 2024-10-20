Hooks:PostHook(BaseInteractionExt, "_add_string_macros", "EIVHUD_BaseInteractionExt_add_string_macros", function (self, macros, ...)
	local interact_text = self:_btn_interact() or managers.localization:get_default_macro("BTN_INTERACT") -- Ascii ID for RB
	local hold_message = string.format("Hold %s to grab the bag", interact_text)

	if self._unit:carry_data() and EIVHUD.Options:GetValue("INTERACTION/BagInfo") then
		local carry_id = self._unit:carry_data():carry_id()
		hold_message = string.format("Hold %s to grab the %s", interact_text, managers.localization:text(tweak_data.carry[carry_id].name_id))
	end

	LocalizationManager:add_localized_strings({["hud_int_hold_grab_the_bag"] = hold_message})
	macros.BAG = hold_message
end)