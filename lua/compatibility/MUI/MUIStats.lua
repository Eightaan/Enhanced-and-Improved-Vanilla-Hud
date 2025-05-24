local MUIStats = MUIStats
if EIVHUD and EIVHUD.Options:GetValue("HUD/Tab") then
	local _MUI_loot_value_updated = MUIStats.loot_value_updated
	function MUIStats:loot_value_updated()
		_MUI_loot_value_updated(self)
		local loot = self._loot_panel;
		local bag = self._bag_panel;
		local acquired = bag:child("amount");
		local gage = loot:child("gage_amount");
		local gage_icon = loot:child("gage_icon");
		local gage_text = loot:child("gage_text");
		
		local global = managers.loot._global;
		local secured = global.secured;
		local carry = tweak_data.carry;
		local carry_id = global.mandatory_bags.carry_id;
		local mandatory =  global.mandatory_bags.amount or 0;
		local required, bonus = 0, 0;
		local packages, remaining = self:count_gage_units();

		for _, data in ipairs(secured) do
			local value = carry.small_loot[data.carry_id];
			if not value then
				if (carry_id == "none" or carry_id == data.carry_id) and mandatory > required then 
					required = required + 1;
				else
					bonus = bonus + 1;
				end
			end
		end

		local loot_amount = "";
		if managers.interaction:get_current_total_loot_count() > 0 then
			local border_crossing_fix = Global.game_settings.level_id == "mex" and  managers.interaction:get_current_total_loot_count() > 41 and "/4";
			loot_amount = border_crossing_fix or "/" .. managers.interaction:get_current_total_loot_count();
		end

		acquired:set_text(tostring(required + bonus) .. loot_amount);

		gage:set_visible(remaining < packages);
		gage_icon:set_visible(remaining < packages);
		gage_text:set_visible(remaining < packages);

		self:resize_loot();
	end
end