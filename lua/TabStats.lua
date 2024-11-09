if not EIVHUD.Options:GetValue("HUD/Tab") then 
	return
end

local Color = Color

local math_round = math.round

local math_floor = math.floor
local math_huge = math.huge
local math_max = math.max
local math_abs = math.abs

if RequiredScript == "lib/managers/hud/newhudstatsscreen" then
	local large_font = tweak_data.menu.pd2_large_font
	local medium_font = tweak_data.menu.pd2_medium_font
	local medium_font_size = tweak_data.menu.pd2_medium_font_size
	local small_font_size = tweak_data.menu.pd2_small_font_size
	local tiny_font_size = tweak_data.menu.pd2_tiny_font_size
	local Color = Color
	local color_white = Color.white

	function HUDStatsScreen:_trade_delay_time()
		local trade_delay = managers.money:get_trade_delay()
		trade_delay = math_max(math_floor(trade_delay), 0)
		local minutes = math_floor(trade_delay / 60)
		trade_delay = trade_delay - minutes * 60
		local seconds = math_round(trade_delay)
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
			color = color_white
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
				local waves = managers.hud._hud_assault_corner:should_display_waves() and EIVHUD.Options:GetValue("HUD/ShowWaves") > 1 and "\n" .. managers.hud._hud_assault_corner:get_completed_waves_string() or ""
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
						difficulty_text:set_range_color(#difficulty_string + 1, math_huge, tweak_data.screen_colors.one_down)
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
					}).. waves
				}))

				if managers.job:is_level_ghostable(managers.job:current_level_id()) then
					local ghost_color = is_whisper_mode and color_white or tweak_data.screen_colors.important_1
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

		if EIVHUD.Options:GetValue("HUD/ShowObjectives") > 1 then
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
				local current = data.current_amount and data.current_amount .. "/" or ""
				local amount = data.amount or ""
				local objective_loot = current .. amount
				placer:add_bottom(self._left:fine_text({
					word_wrap = true,
					wrap = true,
					align = "left",
					text = utf8.to_upper(data.text .. "  " .. objective_loot),
					font = tweak_data.hud.medium_font,
					font_size = small_font_size,
					w = row_w
				}))
				placer:add_bottom(self._left:fine_text({
					word_wrap = true,
					wrap = true,
					align = "left",
					text = data.description,
					font = tweak_data.hud_stats.objective_desc_font,
					font_size = tiny_font_size,
					w = row_w
				}), 0)
			end
		end
		placer:new_row(8)

		if EIVHUD.Options:GetValue("HUD/ShowHostages") == 2 then
			placer:add_bottom(self._left:fine_text({
				keep_w = true,
				font = tweak_data.hud_stats.objectives_font,
				font_size = small_font_size,
				color = color_white,
				text = "HOSTAGES: " .. managers.groupai:state():hostage_count()
			}), 30)
		end
		local total_civ_kills = managers.money:TotalCivKills() or 0
		local civ_kills = total_civ_kills ~= 0 and managers.localization:to_upper_text("victory_civilians_killed_penalty") .. " " .. total_civ_kills .. managers.localization:get_default_macro("BTN_SKULL") or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = small_font_size,
			color = color_white,
			text = civ_kills
		}), 30)

		local total_time = managers.money:get_trade_delay() > 30
		local delay = total_time and managers.localization:to_upper_text("hud_trade_delay", {TIME = self:_trade_delay_time()}) or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = small_font_size,
			color = color_white,
			text = is_whisper_mode and "" or delay
		}), 0)

		local total_kills = managers.statistics:TotalKills() or 0
		local kill_count = total_kills and managers.localization:to_upper_text("menu_aru_job_3_obj") ..": ".. total_kills .. managers.localization:get_default_macro("BTN_SKULL") or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = small_font_size,
			color = color_white,
			text = kill_count
		}), 16)

		local total_accuracy = managers.statistics:session_hit_accuracy()
		local accuracy = total_accuracy and managers.localization:to_upper_text("menu_stats_hit_accuracy") .." ".. total_accuracy.."%" or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = small_font_size,
			color = color_white,
			text = accuracy 
		}), 0)

		local max_units = managers.gage_assignment:count_all_units()
		local remaining = managers.gage_assignment:count_active_units()

		local current_level_id = managers.job:current_level_id()
		local excluded_levels = { "chill_combat", "chill", "haunted", "hvh" }

		local function is_excluded_level(level_id, excluded)
			for _, excluded_level in ipairs(excluded) do
				if level_id == excluded_level then
					return true
				end
			end
			return false
		end

		if remaining < max_units and not is_excluded_level(current_level_id, excluded_levels) then
			placer:add_bottom(self._left:fine_text({
				keep_w = true,
				font = tweak_data.hud_stats.objectives_font,
				font_size = small_font_size,
				color = color_white,
				text = managers.localization:to_upper_text("menu_asset_gage_assignment") .. ": " .. tostring(max_units - remaining) .. "/" .. tostring(max_units)
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
				color = color_white,
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
				color = color_white,
				font = medium_font,
				font_size = medium_font_size
			}))
			placer:add_right(nil, 0)

			local minion_texture, minion_rect = tweak_data.hud_icons:get_icon_data("minions_converted")
			local minion_icon = placer:add_left(loot_panel:fit_bitmap({
				w = 17,
				h = 17,
				color = color_white,
				texture = minion_texture,
				texture_rect = minion_rect
			}))

			minion_icon:set_center_y(minion_text:center_y())
			placer:add_left(loot_panel:fine_text({
				text = tostring(managers.player:num_local_minions()),
				color = color_white,
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
				color = color_white,
				font = medium_font,
				font_size = medium_font_size
			}))
			placer:add_right(nil, 0)

			local pagers_texture, pagers_rect = tweak_data.hud_icons:get_icon_data("pagers_used")
			local pagers_icon = placer:add_left(loot_panel:fit_bitmap({
				w = 17,
				h = 17,
				color = color_white,
				texture = pagers_texture,
				texture_rect = pagers_rect
			}))

			pagers_icon:set_center_y(pagers_text:center_y())
			placer:add_left(loot_panel:fine_text({
				text = tostring(pagers_used) .. "/" .. tostring(max_num_pagers),
				color = color_white,
				font = medium_font,
				font_size = medium_font_size
			}), 7)
			placer:new_row()

			local body_text = placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:to_upper_text("hud_body_bags"),
				color = color_white,
				font = medium_font,
				font_size = medium_font_size
			}))

			placer:add_right(nil, 0)

			local body_texture, body_rect = tweak_data.hud_icons:get_icon_data("equipment_body_bag")
			local body_icon = placer:add_left(loot_panel:fit_bitmap({
				w = 17,
				h = 17,
				color = color_white,
				texture = body_texture,
				texture_rect = body_rect
			}))
			body_icon:set_center_y(body_text:center_y())

			placer:add_left(loot_panel:fine_text({
				text = tostring(managers.player:get_body_bags_amount()),
				font = medium_font,
				color = color_white,
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
			color = color_white,
			font_size = medium_font_size
		}))

		placer:add_right(nil, 0)

		local bag_texture, bag_rect = tweak_data.hud_icons:get_icon_data("bag_icon")
		local bag_icon = placer:add_left(loot_panel:fit_bitmap({
			w = 16,
			h = 16,
			color = color_white,
			texture = bag_texture,
			texture_rect = bag_rect
		}))
		bag_icon:set_center_y(bag_text:center_y())

		placer:add_left(loot_panel:fine_text({
			text = tostring(secured_amount + bonus_amount),
			font = medium_font,
			color = color_white,
			font_size = medium_font_size
		}))
		placer:new_row()
		
		local loot_text = placer:add_bottom(loot_panel:fine_text({
			keep_w = true,
			text = managers.localization:text("hud_stats_bags_unsecured"),
			font = medium_font,
			color = color_white,
			font_size = medium_font_size
		}), 20)

		placer:add_right(nil, 0)

		local border_crossing_fix = Global.game_settings.level_id == "mex" and managers.interaction:get_current_total_loot_count() > 41 and 4
		local loot_amount = border_crossing_fix or managers.interaction:get_current_total_loot_count()
		local bag_texture, bag_rect = tweak_data.hud_icons:get_icon_data("bag_icon")
		local loot_icon = placer:add_left(loot_panel:fit_bitmap({
			w = 16,
			h = 16,
			color = color_white,
			texture = bag_texture,
			texture_rect = bag_rect
		}))
		loot_icon:set_center_y(loot_text:center_y())

		placer:add_left(loot_panel:fine_text({
			text = tostring(loot_amount),
			font = medium_font,
			color = color_white,
			font_size = medium_font_size
		}))
		
		placer:new_row()
		
			local crate_text = placer:add_bottom(loot_panel:fine_text({
			keep_w = true,
			text = managers.localization:text("hud_stats_unopened_crates"),
			font = medium_font,
			color = color_white,
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
			color = color_white,
			texture = bag_texture,
			texture_rect = bag_rect
		}))
		crate_icon:set_center_y(crate_text:center_y())

		placer:add_left(loot_panel:fine_text({
			text = tostring(crate_info),
			font = medium_font,
			color = color_white,
			font_size = medium_font_size
		}))
		placer:new_row()

		if managers.money and managers.statistics and managers.experience then 
			local money_current_stage = managers.money:get_potential_payout_from_current_stage() or 0
			local offshore_rate = managers.money:get_tweak_value("money_manager", "offshore_rate") or 0
			local offshore_total = money_current_stage - math_round(money_current_stage * offshore_rate)
			local offshore_text = managers.experience:cash_string(offshore_total)
			local civilian_kills = managers.statistics:session_total_civilian_kills() or 0
			local cleaner_costs	= (managers.money:get_civilian_deduction() or 0) * civilian_kills
			local spending_cash = money_current_stage * offshore_rate - cleaner_costs
			local spending_cash_text = managers.experience:cash_string(spending_cash)

			placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:to_upper_text("menu_cash_spending"),
				font = medium_font,
				color = color_white,
				font_size = medium_font_size
			}), 12)

			placer:add_right(nil, 0)

			placer:add_left(loot_panel:fine_text({
				text = spending_cash_text,
				font = medium_font,
				color = color_white,
				font_size = medium_font_size
			}))
			placer:new_row()

			placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:to_upper_text("hud_offshore_account"),
				font = medium_font,
				color = color_white,
				font_size = medium_font_size
			}))
			placer:add_right(nil, 0)
			placer:add_left(loot_panel:fine_text({
				text = offshore_text,
				color = color_white,
				font = medium_font,
				font_size = medium_font_size
			}))
			loot_panel:set_size(placer:most_rightbottom())
			loot_panel:set_leftbottom(0, self._left:h() - 16)
		end
	end)
	
	if EIVHUD.Options:GetValue("HUD/ShowTimer") > 1 then
		Hooks:PostHook(HUDStatsScreen, 'recreate_right', "EIVHUD_recreate_right", function(self)
			local time_panel = self:_create_time(self._right)
			time_panel:set_right(self._right:w() - self._rightpos[2])
			time_panel:set_y(self._rightpos[2])
		end)
		
		function HUDStatsScreen:feed_heist_time(time)
			if (self._last_heist_time or 0) < math_floor(time) or time < 0 then
				self._last_heist_time = math_abs(time)
			end
		end
		
		function HUDStatsScreen:modify_heist_time(time)
			if time and time ~= 0 then
				self._last_heist_time = (self._last_heist_time or 0) + time
			end
		end

		function HUDStatsScreen:_create_time(panel)
			local time_panel = ExtendedPanel:new(panel, { w = panel:w() * 0.5, h = tweak_data.hud_stats.objectives_font })
			local placer = UiPlacer:new(0, 0)

			placer:add_row(time_panel:fine_text({
				name = "time_text",
				color = color_white,
				font_size = tweak_data.hud_stats.loot_size,
				font = tweak_data.hud_stats.objectives_font,
				text = "00:00:00",
				align = "right",
				w = time_panel:w() - tweak_data.hud_stats.loot_size - 5,
				keep_w = true
			}))
			placer:add_right(time_panel:fit_bitmap({
				name = "time_icon",
				texture = "guis/textures/pd2/skilltree/drillgui_icon_faster",
				color = color_white,
				w = tweak_data.hud_stats.loot_size,
				h = tweak_data.hud_stats.loot_size,
			}), 5)

			self._time_panel = time_panel
			self._last_time_update_t = 0
			return time_panel
		end

		Hooks:PostHook(HUDStatsScreen, 'update', "EIVHUD_update", function(self, t, ...)
			if self._time_panel and (self._next_time_update_t or 0) < t then
				local text = ""
				local time = math_floor(self._last_heist_time or 0)
				local hours = math_floor(time / 3600)
				time = time - hours * 3600
				local minutes = math_floor(time / 60)
				time = time - minutes * 60
				local seconds = math_round(time)
				text = hours > 0 and string.format("%02d:%02d:%02d", hours, minutes, seconds) or string.format("%02d:%02d", minutes, seconds)
				self._time_panel:child("time_text"):set_text(text)
				self._time_panel:set_visible(true)
				self._next_time_update_t = t + 1
			end
		end)
	end

elseif RequiredScript == "lib/managers/hud/hudstatsscreenskirmish" then
	local large_font = tweak_data.menu.pd2_large_font
	local medium_font = tweak_data.menu.pd2_medium_font
	local small_font_size = tweak_data.menu.pd2_small_font_size
	local medium_font_size = tweak_data.menu.pd2_medium_font_size
	local tiny_font_size = tweak_data.menu.pd2_tiny_font_size

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
			color = color_white
		})

		lb:child("bg"):set_color(Color(0, 0, 0):with_alpha(0.75))
		lb:child("bg"):set_alpha(1)

		local placer = UiPlacer:new(10, 10, 0, 8)
		
		local waves = EIVHUD.Options:GetValue("HUD/ShowWaves") > 1 and "\n" .. managers.hud._hud_assault_corner:get_completed_waves_string() or ""
		local level_data = managers.job:current_level_data()

		if level_data then
			placer:add_bottom(self._left:fine_text({
				text = managers.localization:to_upper_text(level_data.name_id) .. waves,
				font = large_font,
				font_size = tweak_data.hud_stats.objectives_title_size
			}))
			placer:new_row()
		end
		
		if EIVHUD.Options:GetValue("HUD/ShowObjectives") > 1 then
			local objectives_title = self._left:fine_text({
				vertical = "top",
				align = "left",
				font_size = medium_font_size,
				font = tweak_data.hud_stats.objectives_font,
				text = managers.localization:to_upper_text("hud_objective")
			})

			placer:add_bottom(objectives_title, 16)
			placer:new_row(8)

			local row_w = self._left:w() - placer:current_left() * 2

			for i, data in pairs(managers.objectives:get_active_objectives()) do
				placer:add_bottom(self._left:fine_text({
					word_wrap = true,
					wrap = true,
					align = "left",
					text = utf8.to_upper(data.text),
					font = medium_font,
					font_size = small_font_size,
					w = row_w
				}))
				placer:add_bottom(self._left:fine_text({
					word_wrap = true,
					wrap = true,
					align = "left",
					text = data.description,
					font = tweak_data.hud_stats.objective_desc_font,
					font_size = tiny_font_size,
					w = row_w
				}), 0)
			end
		end
		
		placer:new_row(8)
		if EIVHUD.Options:GetValue("HUD/ShowHostages") == 2 then
			placer:add_bottom(self._left:fine_text({
				keep_w = true,
				font = tweak_data.hud_stats.objectives_font,
				font_size = small_font_size,
				color = color_white,
				text = "HOSTAGES: " .. managers.groupai:state():hostage_count()
			}), 30)
		end

		local total_kills = managers.statistics:TotalKills() or 0
		local kill_count = total_kills and managers.localization:to_upper_text("menu_aru_job_3_obj") ..": ".. total_kills ..managers.localization:get_default_macro("BTN_SKULL") or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = small_font_size,
			color = color_white,
			text = kill_count
		}), 16)

		local total_accuracy = managers.statistics:session_hit_accuracy()
		local accuracy = total_accuracy and managers.localization:to_upper_text("menu_stats_hit_accuracy") .." ".. total_accuracy.."%" or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = small_font_size,
			color = color_white,
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
				color = color_white,
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

elseif RequiredScript == "lib/managers/statisticsmanager" then
	local civies = {civilian = true, civilian_female = true, civilian_mariachi = true}

	Hooks:PostHook(StatisticsManager, "killed", "EIVHUD_StatisticsManager_killed", function(self, data, ...)
		if civies[data.name] then
			return
		end
		local bullets = data.variant == "bullet"
		local melee = data.variant == "melee" or data.weapon_id and tweak_data.blackmarket.melee_weapons[data.weapon_id]
		local booms = data.variant == "explosion"
		local other = not (bullets or melee or booms)
		local is_valid_kill = bullets or melee or booms or other

		if is_valid_kill then
			self:update_kills()
		end
	end)

	function StatisticsManager:update_kills()
		self._total_kills = (self._total_kills or 0) + 1
	end

	function StatisticsManager:TotalKills()
		return self._total_kills or 0
	end

elseif RequiredScript == "lib/managers/moneymanager" then
	Hooks:PostHook(MoneyManager, 'civilian_killed', "EIVHUD_civilian_killed", function(self)
		self:update_civ_kills()
	end)
	
	function MoneyManager:update_civ_kills()
		self._total_civ_kills = (self._total_civ_kills or 0) + 1
		self:update_trade_delay()
	end
	
	function MoneyManager:update_trade_delay()
		self._trade_delay = (self._trade_delay or 5) + 30
	end
	
	function MoneyManager:get_trade_delay()
		return self._trade_delay or 5
	end
	
	function MoneyManager:TotalCivKills()
		return self._total_civ_kills or 0
	end

	function MoneyManager:ResetCivilianKills()
		self._trade_delay = 5
	end

elseif RequiredScript == "lib/managers/trademanager" then
	Hooks:PostHook(TradeManager, 'on_player_criminal_death', "EIVHUD_on_player_criminal_death", function(...)
		managers.money:ResetCivilianKills()
	end)

elseif RequiredScript == "lib/managers/hud/hudobjectives" then
	if EIVHUD.Options:GetValue("HUD/ShowObjectives") == 2 then
		Hooks:OverrideFunction(HUDObjectives, "activate_objective", function(self, data)
			if not self._hud_panel:child("objectives_panel") then return end
			local objectives_panel = self._hud_panel:child("objectives_panel")
			objectives_panel:set_alpha(0)
			objectives_panel:set_visible(false)
		end)
	end

elseif RequiredScript == "lib/managers/hud/hudheisttimer" then
	if EIVHUD.Options:GetValue("HUD/ShowTimer") == 2 then
		Hooks:PostHook(HUDHeistTimer, "init", "EIVHUD_HUDHeistTimer_init", function(self)
			self._timer_text:set_alpha(0)
		end)
	end

elseif RequiredScript == "lib/managers/objectinteractionmanager" then
	Hooks:PostHook(ObjectInteractionManager, "init", "EIVHUD_ObjectInteractionManager_init", function(self)
	self._total_loot = {}
		self._count_loot_bags = {}
		self.loot_crates = {}
		self.loot_count = { loot_amount = 0, crate_amount = 0 }
		self._loot_fixes = {
			family 							= { money = 1 },
			watchdogs_2						= { coke = 10 },
			watchdogs_2_day					= { coke = 10 },
			framing_frame_3 				= { gold = 16 },
			mia_1 							= { money = 1 },
			welcome_to_the_jungle_1 		= { money = 1, gold = 1 },
			welcome_to_the_jungle_1_night	= { money = 1, gold = 1 },
			mus 							= { painting = 2, mus_artifact = 1 },
			arm_und 						= { money = 8 },
			ukrainian_job 					= { money = 3 },
			jewelry_store 					= { money = 2 },
			chill 							= { painting = 1 },
			chill_combat 					= { painting = 1 },
			fish 							= { mus_artifact = 1 },
			rvd2 							= { money = 1 },
			pbr2 							= { money = 8 },
			mex_cooking 					= { roman_armor = 4 },
			sah 							= { mus_artifact = 2 },
			ranc 							= { turret_part = 2 },
			trai 							= { turret_part = 2 },
			pent 							= { mus_artifact = 2 },
			des 							= { mus_artifact = 4, painting = 2 }
		}
		self.ignore_ids = {
			[300457] = true,
			[300458] = true
		}
	end)

	local function is_valid_unit(unit)
		return unit and alive(unit) and unit:interaction() and unit:interaction():active() and (not unit:carry_data() or unit:carry_data():carry_id() ~= "vehicle_falcogini")
	end

	local function is_ignored_id(unit_id)
		return managers.interaction.ignore_ids and managers.interaction.ignore_ids[unit_id]
	end

	local function get_unit_type(unit)
		local interact_type = unit:interaction().tweak_data
		return (interact_type and table.contains({
			Global.game_settings.level_id == "election_day_2" and "" or "money_briefcase",
			"gen_pku_warhead_box",
			"weapon_case",
			"weapon_case_axis_z",
			"crate_loot",
			"crate_loot_crowbar"
		}, interact_type)) and "loot_crates" or nil
	end

	local function is_equipment_bag(carry_id)
		return carry_id and tweak_data.carry[carry_id].skip_exit_secure == true
	end

	local function process_loot_count(manager, carry_id)
		local level_id = managers.job:current_level_id()
		if is_ignored_id(carry_id) or is_equipment_bag(carry_id) then return end

		local current_amount = manager._loot_fixes[level_id] and manager._loot_fixes[level_id][carry_id]
		if current_amount and current_amount > 0 then
			manager._loot_fixes[level_id][carry_id] = current_amount - 1
		else
			manager:update_loot(1)
		end
	end

	Hooks:PostHook(ObjectInteractionManager, "update", "EIVHUD_Update", function(self, t, dt)
		for i = #self._count_loot_bags, 1, -1 do
			local data = self._count_loot_bags[i]
			local unit = data.unit
			
			if is_valid_unit(unit) then
				local carry_id = unit:carry_data() and unit:carry_data():carry_id()
				local unit_id = unit:editor_id()
				if carry_id and not is_equipment_bag(carry_id) and not is_ignored_id(unit_id) then
					self._total_loot[unit:id()] = true
					process_loot_count(self, carry_id)
				end
			end
			table.remove(self._count_loot_bags, i)
		end
	end)

	Hooks:PostHook(ObjectInteractionManager, "add_unit", "EIVHUD_ObjectInteractionManager_add_unit", function(self, unit)
		if alive(unit) then
			local carry_id = unit:carry_data() and unit:carry_data():carry_id()
			if get_unit_type(unit) == "loot_crates" then
				table.insert(self.loot_crates, unit:id())
				self:update_loot_crates()
			end
		end
		table.insert(self._count_loot_bags, { unit = unit })
	end)

	Hooks:PostHook(ObjectInteractionManager, "remove_unit", "EIVHUD_ObjectInteractionManager_remove_unit", function(self, unit)
		if alive(unit) then
			local unit_id = unit:id()
			local unit_editor_id = unit:editor_id()
			if not is_ignored_id(unit_id) then
				local carry_id = unit:carry_data() and unit:carry_data():carry_id()
				if self._total_loot[unit_id] then
					self._total_loot[unit_id] = nil
					self:update_loot(-1)
				end
			end
			
			local crate_index = table.index_of(self.loot_crates, unit_id)
			if crate_index then
				table.remove(self.loot_crates, crate_index)
				self:update_loot_crates()
			end
			
			for i = #self._count_loot_bags, 1, -1 do
				if self._count_loot_bags[i].unit:id() == unit_id then
					table.remove(self._count_loot_bags, i)
					break
				end
			end
		end
	end)

	function ObjectInteractionManager:update_loot_crates()
		self.loot_count.crate_amount = #self.loot_crates
	end

	function ObjectInteractionManager:update_loot(update)
		self.loot_count.loot_amount = (self.loot_count.loot_amount or 0) + update
	end

	function ObjectInteractionManager:get_current_crate_count()
		return math_max(self.loot_count.crate_amount or 0, 0)
	end

	function ObjectInteractionManager:get_current_total_loot_count()
		return math_max(self.loot_count.loot_amount or 0, 0)
	end
	
elseif RequiredScript == "lib/managers/hudmanagerpd2" then
	Hooks:PostHook(HUDManager, "feed_heist_time", "EIVHUD_HUDManager_feed_heist_time", function (self, time, ...)
		if self._hud_statsscreen and self._hud_statsscreen.feed_heist_time then
			self._hud_statsscreen:feed_heist_time(time)
		end
	end)

	Hooks:PostHook(HUDManager, "modify_heist_time", "EIVHUD_HUDManager_modify_heist_time", function (self, time, ...)
		if self._hud_statsscreen and self._hud_statsscreen.modify_heist_time then
			self._hud_statsscreen:modify_heist_time(time)
		end
	end)
end