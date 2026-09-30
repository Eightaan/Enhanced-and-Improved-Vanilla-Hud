local MUIStats = MUIStats
if EIVHUD and EIVHUD.Options:GetValue("HUD/Tab") then
	local _MUI_loot_value_updated = MUIStats.loot_value_updated
	function MUIStats:loot_value_updated()
		_MUI_loot_value_updated(self)
		local loot = self._loot_panel
		local bag = self._bag_panel
		local acquired = bag:child("amount")
		
		local global = managers.loot._global
		local secured = global.secured
		local carry = tweak_data.carry
		local carry_id = global.mandatory_bags.carry_id
		local mandatory =  global.mandatory_bags.amount or 0
		local required, bonus = 0, 0
		local packages, remaining = self:count_gage_units()

		for _, data in ipairs(secured) do
			local value = carry.small_loot[data.carry_id]
			if not value then
				if (carry_id == "none" or carry_id == data.carry_id) and mandatory > required then 
					required = required + 1
				else
					bonus = bonus + 1
				end
			end
		end

local total_loot = managers.interaction:get_current_total_loot_count() + required + bonus
local border_crossing_fix = Global.game_settings.level_id == "mex" and managers.interaction:get_current_total_loot_count() > 41 and "/4"
local loot_amount = total_loot == 0 and "" or (border_crossing_fix or "/" .. total_loot)
local total_crates = managers.interaction:get_current_crate_count()
local rats_fix = Global.game_settings.level_id == "alex_3" and total_crates > 14 and total_crates - 16
local crate_amount = total_crates == 0 and "" or (rats_fix or total_crates)


acquired:set_text(tostring(required + bonus) .. loot_amount .. (crate_amount ~= "" and " + (" .. crate_amount .. ")" or ""))
		-- local border_crossing_fix = Global.game_settings.level_id == "mex" and  managers.interaction:get_current_total_loot_count() > 41 and "/4";
		-- local loot_amount = border_crossing_fix or "/" .. managers.interaction:get_current_total_loot_count() + required + bonus;

		
		-- local rats_fix = Global.game_settings.level_id == "alex_3" and managers.interaction:get_current_crate_count() > 14 and managers.interaction:get_current_crate_count() - 16
		-- local crate_info = rats_fix or managers.interaction:get_current_crate_count()

		-- acquired:set_text(tostring(required + bonus) .. loot_amount .. " + (" .. crate_info..")");

		self:resize_loot();
	end
end