if not _G.EIVH then
    _G.EIVH = {}
	EIVH.TotalKills = 0
	EIVH.CivKill = 0
end

if not EIVHUD.Options:GetValue("HUD/Tab") then 
    return
end

local civies =
{
    civilian = true,
    civilian_female = true,
    civilian_mariachi = true
}

if RequiredScript == "lib/managers/hud/newhudstatsscreen" then
	local large_font = tweak_data.menu.pd2_large_font
	local medium_font = tweak_data.menu.pd2_medium_font
	local medium_font_size = tweak_data.menu.pd2_medium_font_size
	local small_font_size = tweak_data.menu.pd2_small_font_size
	local tiny_font_size = tweak_data.menu.pd2_tiny_font_size

	function HUDStatsScreen:_trade_delay_time(time)
		time = math.max(math.floor(time), 0)
		local minutes = math.floor(time / 60)
		time = time - minutes * 60
		local seconds = math.round(time)
		local text = ""

		return text .. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
	end	
	
	Hooks:OverrideFunction(HUDStatsScreen, "recreate_left", function(self)
		self._left:clear()
		self._left:bitmap({
			texture = "guis/textures/test_blur_df",
			layer = -1,
			render_template = "VertexColorTexturedBlur3D",
			valign = "grow",
			w = self._left:w(),
			h = self._left:h()
		})

		local lb = HUDBGBox_create(self._left, {}, {
			blend_mode = "normal",
			color = Color.white
		})

		lb:child("bg"):set_color(Color(0, 0, 0):with_alpha(0.75))
		lb:child("bg"):set_alpha(1)

		local placer = UiPlacer:new(10, 10, 0, 8)
		local job_data = managers.job:current_job_data()
		local stage_data = managers.job:current_stage_data()

		if job_data and managers.job:current_job_id() == "safehouse" and Global.mission_manager.saved_job_values.playedSafeHouseBefore then
			self._left:set_visible(false)
			return
		end

		local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()

		if stage_data then
			if managers.crime_spree:is_active() then
				local level_data = managers.job:current_level_data()
				local mission = managers.crime_spree:get_mission(managers.crime_spree:current_played_mission())

				if mission then
					local level_str = managers.localization:to_upper_text(tweak_data.levels[mission.level.level_id].name_id) or ""
					local spree_space = string.rep(" ", 2)

					placer:add_row(self._left:fine_text({
						font = large_font,
						font_size = tweak_data.hud_stats.objectives_title_size,
						text = level_str..spree_space
					}))
				end

				local str = managers.localization:text("menu_cs_level", {
					level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")
				})

				placer:add_right(self._left:fine_text({
					font = medium_font,
					font_size = tweak_data.hud_stats.loot_size,
					text = str,
					color = tweak_data.screen_colors.crime_spree_risk
				}))
			else
				local job_chain = managers.job:current_job_chain_data()
				local day = managers.job:current_stage()
				local days = job_chain and #job_chain or 0
				local level_data = managers.job:current_level_data()
				local space
				local heist_title
				
				if job_data then
					local job_stars = managers.job:current_job_stars()
					local difficulty_stars = managers.job:current_difficulty_stars()
					local difficulty = tweak_data.difficulties[difficulty_stars + 2] or 1
					local difficulty_string = managers.localization:to_upper_text(tweak_data.difficulty_name_ids[difficulty])
					local difficulty_text = self._left:fine_text({
						font = tweak_data.hud_stats.objectives_font,
						font_size = medium_font_size,
						text = difficulty_string,
						color = difficulty_stars > 0 and tweak_data.screen_colors.risk or tweak_data.screen_colors.text
					})

					if Global.game_settings.one_down then
						local one_down_string = managers.localization:to_upper_text("menu_one_down")
						difficulty_text:set_text(difficulty_string .. " " .. one_down_string)
						difficulty_text:set_range_color(#difficulty_string + 1, math.huge, tweak_data.screen_colors.one_down)
					end

					local _, _, tw, th = difficulty_text:text_rect()

					difficulty_text:set_size(tw, th)
					placer:add_right(difficulty_text)
				end
				
	            if level_data then
	                heist_title = managers.localization:to_upper_text(level_data.name_id) .. ":"
					space = string.rep(" ", 2)
	            else
 	               heist_title = ""
 	               space = ""
 	           end				

				local day_title = placer:add_bottom(self._left:fine_text({
					font = tweak_data.hud_stats.objectives_font,
					font_size = medium_font_size,
					text = heist_title .. space .. managers.localization:to_upper_text("hud_days_title", {
						DAY = day,
						DAYS = days
					})
				}))

				if managers.job:is_level_ghostable(managers.job:current_level_id()) then
					local ghost_color = is_whisper_mode and Color.white or tweak_data.screen_colors.important_1
					local ghost = placer:add_right(self._left:bitmap({
						texture = "guis/textures/pd2/cn_minighost",
						name = "ghost_icon",
						h = 16,
						blend_mode = "add",
						w = 16,
						color = ghost_color
					}))
					ghost:set_center_y(day_title:center_y())
				end
			end
			placer:new_row()
		end

		placer:add_bottom(self._left:fine_text({
			vertical = "top",
			align = "left",
			font_size = medium_font_size,
			font = tweak_data.hud_stats.objectives_font,
			text = managers.localization:to_upper_text("hud_objective")
		}), 16)
		placer:new_row(8)

		local row_w = self._left:w() - placer:current_left() * 2

		for i, data in pairs(managers.objectives:get_active_objectives()) do
			placer:add_bottom(self._left:fine_text({
				word_wrap = true,
				wrap = true,
				align = "left",
				text = utf8.to_upper(data.text),
				font = tweak_data.hud.medium_font,
				font_size = small_font_size,
				w = row_w
			}))
			placer:add_bottom(self._left:fine_text({
				word_wrap = true,
				wrap = true,
				font_size = 24,
				align = "left",
				text = data.description,
				font = tweak_data.hud_stats.objective_desc_font,
				font_size = tiny_font_size,
				w = row_w
			}), 0)
		end
		placer:new_row(8)
		if EIVHUD.Options:GetValue("HUD/ShowHostages") == 2 then
			placer:add_bottom(self._left:fine_text({
				keep_w = true,
				font = tweak_data.hud_stats.objectives_font,
				font_size = small_font_size,
				color = Color.white,
				text = "HOSTAGES: " .. managers.groupai:state():hostage_count()
			}), 30)
		end
		local civ_kills = managers.statistics:session_total_civilian_kills() ~= 0 and managers.localization:to_upper_text("victory_civilians_killed_penalty") .. " " .. managers.statistics:session_total_civilian_kills() .. managers.localization:get_default_macro("BTN_SKULL") or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = small_font_size,
			color = Color.white,
			text = civ_kills
		}), 1)
				
		local trade_delay = (5 + (EIVH.CivKill * 30))
        local total_time = trade_delay and trade_delay > 30					
		local delay = total_time and managers.localization:to_upper_text("hud_trade_delay", {TIME = tostring(self:_trade_delay_time(trade_delay))}) or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = small_font_size,
			color = Color.white,
			text = is_whisper_mode and "" or delay
		}), 0)

		local total_kills = EIVH.TotalKills
		local kill_count = total_kills and managers.localization:to_upper_text("menu_aru_job_3_obj") ..": ".. total_kills .. managers.localization:get_default_macro("BTN_SKULL") or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = small_font_size,
			color = Color.white,
			text = kill_count
		}), 16)

		local total_accuracy = managers.statistics:session_hit_accuracy()
		local accuracy = total_accuracy and managers.localization:to_upper_text("menu_stats_hit_accuracy") .." ".. total_accuracy.."%" or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = small_font_size,
			color = Color.white,
			text = accuracy 
		}), 0)

		local max_units = managers.gage_assignment:count_all_units()
        local remaining = managers.gage_assignment:count_active_units()
		local package_text = managers.job:current_level_id() ~= "chill_combat" and managers.job:current_level_id() ~= "chill" and managers.job:current_level_id() ~= "haunted" and managers.job:current_level_id() ~= "hvh" and managers.localization:to_upper_text("menu_asset_gage_assignment") .. ":" .. " " .. tostring(max_units - remaining) .."/".. tostring(max_units) or ""
		if remaining < max_units then
			placer:add_bottom(self._left:fine_text({
				keep_w = true,
				font = tweak_data.hud_stats.objectives_font,
				font_size = small_font_size,
				color = Color.white,
				text = package_text
			}), 16)
		end
		
		local dominated = 0
		local enemy_count = 0
		for _, unit in pairs(managers.enemy:all_enemies()) do
			enemy_count = enemy_count + 1
			if (unit and unit.unit and alive(unit.unit)) and (unit.unit:anim_data() and unit.unit:anim_data().hands_up or unit.unit:anim_data() and unit.unit:anim_data().surrender or unit.unit:base() and unit.unit:base().mic_is_being_moved)then
		        dominated = dominated + 1
	        end
        end

		local enemies = enemy_count - dominated
		if enemies > 0 then
			placer:add_bottom(self._left:fine_text({
				keep_w = true,
			    font = tweak_data.hud_stats.objectives_font,
			    font_size = small_font_size,
			    color = Color.white,
			    text = managers.localization:to_upper_text("menu_mutators_category_enemies") .. ": " .. enemies
		    }), 16)
        end
	
		local loot_panel = ExtendedPanel:new(self._left, {
			w = self._left:w() - 16 - 8
		})
		placer = UiPlacer:new(16, 0, 8, 4)

		if not is_whisper_mode and managers.player:has_category_upgrade("player", "convert_enemies") then
			local minion_text = placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:text("hud_stats_enemies_converted"),
				color = Color.white,
				font = medium_font,
				font_size = medium_font_size
			}))
			placer:add_right(nil, 0)

			local minion_texture, minion_rect = tweak_data.hud_icons:get_icon_data("minions_converted")
			local minion_icon = placer:add_left(loot_panel:fit_bitmap({
				w = 17,
				h = 17,
				color = Color.white,
				texture = minion_texture,
				texture_rect = minion_rect
			}))

			minion_icon:set_center_y(minion_text:center_y())
			placer:add_left(loot_panel:fine_text({
				text = tostring(managers.player:num_local_minions()),
				color = Color.white,
				font = medium_font,
				font_size = medium_font_size
			}), 7)
			placer:new_row()
		end

		if is_whisper_mode then
			local pagers_used = managers.groupai:state():get_nr_successful_alarm_pager_bluffs()
			local max_pagers_data = managers.player:has_category_upgrade("player", "corpse_alarm_pager_bluff") and tweak_data.player.alarm_pager.bluff_success_chance_w_skill or tweak_data.player.alarm_pager.bluff_success_chance
			local max_num_pagers = #max_pagers_data

			for i, chance in ipairs(max_pagers_data) do
				if chance == 0 then
					max_num_pagers = i - 1
					break
				end
			end

			local pagers_text = placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:text("hud_stats_pagers_used"),
				color = Color.white,
				font = medium_font,
				font_size = medium_font_size
			}))
			placer:add_right(nil, 0)

			local pagers_texture, pagers_rect = tweak_data.hud_icons:get_icon_data("pagers_used")
			local pagers_icon = placer:add_left(loot_panel:fit_bitmap({
				w = 17,
				h = 17,
				color = Color.white,
				texture = pagers_texture,
				texture_rect = pagers_rect
			}))

			pagers_icon:set_center_y(pagers_text:center_y())
			placer:add_left(loot_panel:fine_text({
				text = tostring(pagers_used) .. "/" .. tostring(max_num_pagers),
				color = Color.white,
				font = medium_font,
				font_size = medium_font_size
			}), 7)
			placer:new_row()

			local body_text = placer:add_bottom(loot_panel:fine_text({
		 	    keep_w = true,
		 	    text = managers.localization:to_upper_text("hud_body_bags"),
			    color = Color.white,
		 	    font = medium_font,
			    font_size = medium_font_size
	   		}))

	   	 	placer:add_right(nil, 0)

			local body_texture, body_rect = tweak_data.hud_icons:get_icon_data("equipment_body_bag")
			local body_icon = placer:add_left(loot_panel:fit_bitmap({
				w = 17,
				h = 17,
				color = Color.white,
				texture = body_texture,
				texture_rect = body_rect
			}))
			body_icon:set_center_y(body_text:center_y())

			placer:add_left(loot_panel:fine_text({
				text = tostring(managers.player:get_body_bags_amount()),
				font = medium_font,
				color = Color.white,
				font_size = medium_font_size
			}), 7)
			placer:new_row()
		end

		local secured_amount = managers.loot:get_secured_mandatory_bags_amount()
		local bonus_amount = managers.loot:get_secured_bonus_bags_amount()
		local bag_text = placer:add_bottom(loot_panel:fine_text({
			keep_w = true,
			text = managers.localization:text("hud_stats_bags_secured"),
			font = medium_font,
			color = Color.white,
			font_size = medium_font_size
		}))

		placer:add_right(nil, 0)

		local bag_texture, bag_rect = tweak_data.hud_icons:get_icon_data("bag_icon")
		local bag_icon = placer:add_left(loot_panel:fit_bitmap({
			w = 16,
			h = 16,
			color = Color.white,
			texture = bag_texture,
			texture_rect = bag_rect
		}))
		bag_icon:set_center_y(bag_text:center_y())

		placer:add_left(loot_panel:fine_text({
			text = tostring(secured_amount + bonus_amount),
			font = medium_font,
			color = Color.white,
			font_size = medium_font_size
		}))
		placer:new_row()
		
		local loot_text = placer:add_bottom(loot_panel:fine_text({
			keep_w = true,
			text = managers.localization:text("hud_stats_bags_unsecured"),
			font = medium_font,
			color = Color.white,
			font_size = medium_font_size
		}), 20)

		placer:add_right(nil, 0)

		local border_crossing_fix = Global.game_settings.level_id == "mex" and managers.interaction:get_current_total_loot_count() > 38 and 4
		local loot_amount = border_crossing_fix or managers.interaction:get_current_total_loot_count()
		local bag_texture, bag_rect = tweak_data.hud_icons:get_icon_data("bag_icon")
		local loot_icon = placer:add_left(loot_panel:fit_bitmap({
			w = 16,
			h = 16,
			color = Color.white,
			texture = bag_texture,
			texture_rect = bag_rect
		}))
		loot_icon:set_center_y(loot_text:center_y())

		placer:add_left(loot_panel:fine_text({
			text = tostring(loot_amount),
			font = medium_font,
			color = Color.white,
			font_size = medium_font_size
		}))
		
		placer:new_row()
		
			local crate_text = placer:add_bottom(loot_panel:fine_text({
			keep_w = true,
			text = managers.localization:text("hud_stats_unopened_crates"),
			font = medium_font,
			color = Color.white,
			font_size = medium_font_size
		}))

		placer:add_right(nil, 0)

		local firestarter_fix = Global.game_settings.level_id == "firestarter_1" and managers.interaction:get_current_crate_count() > 50 and 0
		local rats_fix = Global.game_settings.level_id == "alex_3" and managers.interaction:get_current_crate_count() > 14 and managers.interaction:get_current_crate_count() - 16
		local crate_info = firestarter_fix or rats_fix or managers.interaction:get_current_crate_count()
		local bag_texture, bag_rect = tweak_data.hud_icons:get_icon_data("bag_icon")
		local crate_icon = placer:add_left(loot_panel:fit_bitmap({
			w = 16,
			h = 16,
			color = Color.white,
			texture = bag_texture,
			texture_rect = bag_rect
		}))
		crate_icon:set_center_y(crate_text:center_y())

		placer:add_left(loot_panel:fine_text({
			text = tostring(crate_info),
			font = medium_font,
			color = Color.white,
			font_size = medium_font_size
		}))
		placer:new_row()

	    if managers.money and managers.statistics and managers.experience then 
       	    local money_current_stage = managers.money:get_potential_payout_from_current_stage() or 0
			local offshore_rate = managers.money:get_tweak_value("money_manager", "offshore_rate") or 0
			local offshore_total = money_current_stage - math.round(money_current_stage * offshore_rate)
			local offshore_text = managers.experience:cash_string(offshore_total)
			local civilian_kills = managers.statistics:session_total_civilian_kills() or 0
			local cleaner_costs	= (managers.money:get_civilian_deduction() or 0) * civilian_kills
			local spending_cash = money_current_stage * offshore_rate - cleaner_costs
			local spending_cash_text = managers.experience:cash_string(spending_cash)

			placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:to_upper_text("menu_cash_spending"),
				font = medium_font,
				color = Color.white,
				font_size = medium_font_size
			}), 12)

			placer:add_right(nil, 0)

			placer:add_left(loot_panel:fine_text({
				text = spending_cash_text,
				font = medium_font,
				color = Color.white,
				font_size = medium_font_size
			}))
			placer:new_row()

			placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:to_upper_text("hud_offshore_account"),
				font = medium_font,
				color = Color.white,
				font_size = medium_font_size
			}))
			placer:add_right(nil, 0)
			placer:add_left(loot_panel:fine_text({
				text = offshore_text,
				color = Color.white,
				font = medium_font,
				font_size = medium_font_size
			}))
			loot_panel:set_size(placer:most_rightbottom())
			loot_panel:set_leftbottom(0, self._left:h() - 16)
		end
	end)
elseif RequiredScript == "lib/managers/hud/hudstatsscreenskirmish" then
	local large_font = tweak_data.menu.pd2_large_font
	local medium_font = tweak_data.menu.pd2_medium_font
	local small_font_size = tweak_data.menu.pd2_small_font_size
	local medium_font_size = tweak_data.menu.pd2_medium_font_size

	Hooks:OverrideFunction(HUDStatsScreenSkirmish, "recreate_left", function(self)
		self._left:clear()
		self._left:bitmap({
			texture = "guis/textures/test_blur_df",
			layer = -1,
			render_template = "VertexColorTexturedBlur3D",
			valign = "grow",
			w = self._left:w(),
			h = self._left:h()
		})

		local lb = HUDBGBox_create(self._left, {}, {
			blend_mode = "normal",
			color = Color.white
		})

		lb:child("bg"):set_color(Color(0, 0, 0):with_alpha(0.75))
		lb:child("bg"):set_alpha(1)

		local placer = UiPlacer:new(10, 10, 0, 8)

		local level_data = managers.job:current_level_data()

		if level_data then
			placer:add_bottom(self._left:fine_text({
				text = managers.localization:to_upper_text(level_data.name_id),
				font = large_font,
				font_size = tweak_data.hud_stats.objectives_title_size
			}))
			placer:new_row()
		end

		placer:new_row(8)
		if EIVHUD.Options:GetValue("HUD/ShowHostages") == 2 then
			placer:add_bottom(self._left:fine_text({
				keep_w = true,
				font = tweak_data.hud_stats.objectives_font,
				font_size = small_font_size,
				color = Color.white,
				text = "HOSTAGES: " .. managers.groupai:state():hostage_count()
			}), 0)
		end

		local total_kills = EIVH.TotalKills
		local kill_count = total_kills and managers.localization:to_upper_text("menu_aru_job_3_obj") ..": ".. total_kills ..managers.localization:get_default_macro("BTN_SKULL") or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = small_font_size,
			color = Color.white,
			text = kill_count
		}), 16)

		local total_accuracy = managers.statistics:session_hit_accuracy()
		local accuracy = total_accuracy and managers.localization:to_upper_text("menu_stats_hit_accuracy") .." ".. total_accuracy.."%" or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = small_font_size,
			color = Color.white,
			text = accuracy 
		}), 0)
		
		local dominated = 0
		local enemy_count = 0
		for _, unit in pairs(managers.enemy:all_enemies()) do
			enemy_count = enemy_count + 1
			if (unit and unit.unit and alive(unit.unit)) and (unit.unit:anim_data() and unit.unit:anim_data().hands_up or unit.unit:anim_data() and unit.unit:anim_data().surrender or unit.unit:base() and unit.unit:base().mic_is_being_moved)then
		        dominated = dominated + 1
	        end
        end

		local enemies = enemy_count - dominated
		if enemies > 0 then
			placer:add_bottom(self._left:fine_text({
				keep_w = true,
			    font = tweak_data.hud_stats.objectives_font,
			    font_size = small_font_size,
			    color = Color.white,
			    text = managers.localization:to_upper_text("menu_mutators_category_enemies") .. ": " .. enemies
		    }), 16)
        end

		local loot_panel = ExtendedPanel:new(self._left, {
			w = self._left:w() - 16 - 8
		})
		placer = UiPlacer:new(16, 0, 8, 4)

		if managers.player:has_category_upgrade("player", "convert_enemies") then
			local minion_text = placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:text("hud_stats_enemies_converted"),
				font = medium_font,
				font_size = medium_font_size
			}))
			placer:add_right(nil, 0)

			local minion_texture, minion_rect = tweak_data.hud_icons:get_icon_data("minions_converted")
			local minion_icon = placer:add_left(loot_panel:fit_bitmap({
				w = 17,
				h = 17,
				texture = minion_texture,
				texture_rect = minion_rect
			}))

			minion_icon:set_center_y(minion_text:center_y())
			placer:add_left(loot_panel:fine_text({
				text = tostring(managers.player:num_local_minions()),
				font = medium_font,
				font_size = medium_font_size
			}), 7)
			placer:new_row()
		end

		placer:add_bottom(loot_panel:fine_text({
			keep_w = true,
			text = managers.localization:to_upper_text("hud_skirmish_ransom"),
			font = medium_font,
			font_size = medium_font_size
		}))

		local ransom_amount = managers.skirmish:current_ransom_amount()

		placer:add_right(nil, 0)
		placer:add_left(loot_panel:fine_text({
			text = managers.experience:cash_string(ransom_amount),
			font = medium_font,
			font_size = medium_font_size
		}))
		loot_panel:set_size(placer:most_rightbottom())
		loot_panel:set_leftbottom(0, self._left:h() - 16)
	end)
elseif RequiredScript == "lib/managers/moneymanager" then
    Hooks:PostHook(MoneyManager, 'civilian_killed', "EIVHUD_civilian_killed", function(self)
        EIVH.CivKill = EIVH.CivKill + 1
    end)

    function MoneyManager:ResetCivilianKills()
        EIVH.CivKill = 0
    end
elseif RequiredScript == "lib/managers/trademanager" then
    Hooks:PostHook(TradeManager, 'on_player_criminal_death', "EIVHUD_on_player_criminal_death", function(...)
        managers.money:ResetCivilianKills()
    end)
elseif RequiredScript == "lib/managers/statisticsmanager" then
    Hooks:PostHook( StatisticsManager, "killed", "EIVHUD_StatisticsManager_killed", function(self, data, ...)
        if civies[data.name] then
            return
        end
    	local bullets = data.variant == "bullet"
    	local melee = data.variant == "melee" or data.weapon_id and tweak_data.blackmarket.melee_weapons[data.weapon_id]
    	local booms = data.variant == "explosion"
    	local other = not bullets and not melee and not booms
        if bullets or melee or booms or other then
            EIVH.TotalKills = EIVH.TotalKills + 1
        end
    end)
elseif RequiredScript == "lib/managers/objectinteractionmanager" then
	Hooks:PostHook(ObjectInteractionManager, "init", "EIVHUD_ObjectInteractionManager_init", function(self)
		self.loot_count = {}
		self.loot_count.loot_amount = 0
		self.loot_count.crate_amount = 0
		self._total_loot = {}
		self._count_loot_bags = {}
		self.loot_crates = {}
		self._loot_fixes = {
			family = 						{ money = 1, },
			watchdogs_2 = 					{ coke = 10, },
			watchdogs_2_day =				{ coke = 10, },
			framing_frame_3 = 				{ gold = 16, coke = 8 },
			mia_1 = 						{ money = 1, },
			welcome_to_the_jungle_1 =		{ money = 1, gold = 1 },
			welcome_to_the_jungle_1_night =	{ money = 1, gold = 1 },
			mus = 							{ painting = 2, mus_artifact = 1 },
			arm_und = 						{ money = 8, },
			ukrainian_job = 				{ money = 3, },
			jewelry_store = 				{ money = 2, },
			chill = 						{ painting = 1, },
			chill_combat = 					{ painting = 1, },
			fish = 							{ mus_artifact = 1, },
			rvd2 = 							{ money = 1, },
			arena = 						{ vehicle_falcogini = 1, },
			shoutout_raid =					{ vehicle_falcogini = 9, },
			friend = 						{ painting = 8, },
			pbr2 =							{ money = 8, vehicle_falcogini = 1 },
			mex_cooking = 					{ roman_armor = 4, },
			sah =							{ mus_artifact = 2, },
			corp =							{ painting = 5, },
			ranc =							{ turret_part = 2, vehicle_falcogini = 2  },
			trai =							{ turret_part = 2, },
			pent =							{ mus_artifact = 2, },
			des = 							{ mus_artifact = 4, painting = 2 }
		}
	end)
		
	local function _get_unit_type(unit)
		local interact_type = unit:interaction().tweak_data
		local alaskan_deal_fix = Global.game_settings.level_id == "wwh" and "grenade_briefcase" or ""
		local counted_possible_by_int = {alaskan_deal_fix, "money_briefcase", "gen_pku_warhead_box", "weapon_case", "weapon_case_axis_z", "crate_loot", "crate_loot_crowbar"}
		local counted_by_int = {"hold_take_helmet", "take_weapons_axis_z"}
		if interact_type then
			if table.contains(counted_possible_by_int, interact_type) then
				return "loot_crates"
			end
		end
	end
		
	Hooks:PostHook(ObjectInteractionManager, "update", "EIVHUD_Update", function(self, t, dt)
		for i = #self._count_loot_bags, 1, -1 do
			local data = self._count_loot_bags[i]
			local unit = data.unit
			if alive(unit) and unit:interaction() and unit:interaction():active() then
				local carry_id = unit:carry_data() and unit:carry_data():carry_id()
				local interact_type = unit:interaction().tweak_data
				if carry_id and not tweak_data.carry[carry_id].skip_exit_secure or interact_type and tweak_data.carry[interact_type] and not tweak_data.carry[carry_id].skip_exit_secure == true then
					self._total_loot[unit:id()] = true
					local level_id = managers.job:current_level_id()
					if carry_id and level_id and self._loot_fixes[level_id] and self._loot_fixes[level_id][carry_id] and self._loot_fixes[level_id][carry_id] > 0 then
						self._loot_fixes[level_id][carry_id] = self._loot_fixes[level_id][carry_id] - 1
					else
						self:update_loot(1)
					end
				end
			end
			table.remove(self._count_loot_bags, i)
		end
	end)

	Hooks:PostHook(ObjectInteractionManager, "add_unit", "EIVHUD_ObjectInteractionManager_add_unit", function(self, unit)
		if alive(unit) then
			local unit_type = _get_unit_type(unit)
			if unit_type == "loot_crates" then
				table.insert(self.loot_crates, unit:id())
				self:update_loot_crates()
			end
		end
		table.insert(self._count_loot_bags, { unit = unit })
	end)

	Hooks:PostHook(ObjectInteractionManager, "remove_unit", "EIVHUD_ObjectInteractionManager_remove_unit", function(self, unit)
		if self._total_loot[unit:id()] then
			self._total_loot[unit:id()] = nil
			self:update_loot(-1)
		end

		if table.contains(self.loot_crates, unit:id()) then
			table.remove(self.loot_crates, table.index_of(self.loot_crates, unit:id()))
			self:update_loot_crates()
		end
	end)

	function ObjectInteractionManager:update_loot_crates()
		local count = #self.loot_crates
		self.loot_count.crate_amount = count or 0
	end

	function ObjectInteractionManager:update_loot(update)
		self.loot_count.loot_amount = (self.loot_count.loot_amount or 0) + update
	end
		
	function ObjectInteractionManager:get_current_crate_count()
		return (self.loot_count.crate_amount and self.loot_count.crate_amount >= 0) and self.loot_count.crate_amount or 0
	end
		
	function ObjectInteractionManager:get_current_total_loot_count()
		return (self.loot_count.loot_amount and self.loot_count.loot_amount >= 0) and self.loot_count.loot_amount or 0
	end
end