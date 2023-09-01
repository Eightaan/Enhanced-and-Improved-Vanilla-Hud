Hooks:PostHook(BaseInteractionExt, "_add_string_macros", "EIVHUD_BaseInteractionExt_add_string_macros", function (self, macros, ...)
	macros.INTERACT = self:_btn_interact() or managers.localization:get_default_macro("BTN_INTERACT") --Ascii ID for RB
	if self._unit:carry_data() and EIVHUD.Options:GetValue("INTERACTION/BagInfo") then
		local carry_id = self._unit:carry_data():carry_id()
		LocalizationManager:add_localized_strings({["hud_int_hold_grab_the_bag"] = "Hold $INTERACT to grab the $BAG"})
		macros.BAG = managers.localization:text(tweak_data.carry[carry_id].name_id)
	else
		LocalizationManager:add_localized_strings({["hud_int_hold_grab_the_bag"] = "Hold $INTERACT to grab the bag"})
	end
end)
