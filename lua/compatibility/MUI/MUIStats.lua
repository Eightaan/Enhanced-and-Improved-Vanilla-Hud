local MUIStats = MUIStats
if EIVHUD and EIVHUD.Options:GetValue("HUD/Tab") then
	local _MUI_loot_value_updated = MUIStats.loot_value_updated
	function MUIStats:loot_value_updated()
		_MUI_loot_value_updated(self)
		local loot = self._bag_panel:child("amount")
		local secured = managers.loot:get_secured_mandatory_bags_amount() + managers.loot:get_secured_bonus_bags_amount()
		local carrying, loot_amount = managers.interaction:get_current_carry_count(), managers.interaction:get_current_total_loot_count()
		local total = loot_amount + carrying + secured
		local loot_text = total > 0 and "/" .. total or ""
		local total_crates = managers.interaction:get_current_crate_count()
		local crate_text = total_crates > 0 and " + (" .. total_crates .. ")" or ""

		loot:set_text(tostring(secured) .. loot_text .. crate_text)
		self:resize_loot()
	end
end