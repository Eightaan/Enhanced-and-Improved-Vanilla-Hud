if _G.IS_VR then
	return
end

local Color = Color

local math_round = math.round
local math_lerp = math.lerp
local math_sin = math.sin
local math_max = math.max

local hud_ammo = EIVHUD.Options:GetValue("HUD/PLAYER/Trueammo")

Hooks:PostHook(HUDTeammate, "init", "EIVHUD_hud_teammate_init", function(self, ...)
	if EIVHUD.Options:GetValue("HUD/PLAYER/Team_bg") then
		local function hide_bg(panel, ...)
			for _, name in ipairs({...}) do
				local child = panel and panel:child(name)
				if child then child:set_visible(false) end
			end
		end

		hide_bg(self._panel, "name_bg")
		hide_bg(self._cable_ties_panel, "bg")
		hide_bg(self._deployable_equipment_panel, "bg")
		hide_bg(self._grenades_panel, "bg")

		if self._player_panel then
			local weapons_panel = self._player_panel:child("weapons_panel")
			hide_bg(weapons_panel and weapons_panel:child("primary_weapon_panel"), "bg")
			hide_bg(weapons_panel and weapons_panel:child("secondary_weapon_panel"), "bg")
		end
	end

	if self._main_player and EIVHUD.Options:GetValue("HUD/PLAYER/Bulletstorm") then
		self:infinite_ammo_glow()
	end
end)

function HUDTeammate:infinite_ammo_glow()
	self._prim_ammo = self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):bitmap({
		align = "center",
		w = 55,
		h = 40,
		name = "primary_ammo",
		visible = false,
		texture = "guis/textures/pd2/crimenet_marker_glow",
		texture_rect = { 1, 1, 62, 62 }, 
		color = Color("00AAFF"),
		layer = 2,
		blend_mode = "add"
	})
	self._sec_ammo = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):bitmap({
		align = "center",
		w = 55,
		h = 40,
		name = "secondary_ammo",
		visible = false,
		texture = "guis/textures/pd2/crimenet_marker_glow",
		texture_rect = { 1, 1, 62, 62 }, 
		color = Color("00AAFF"),
		layer = 2,
		blend_mode = "add"
	})
	self._prim_ammo:set_center_y(self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):y() + self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):h() / 2 - 2)
	self._sec_ammo:set_center_y(self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):y() + self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):h() / 2 - 2)
	self._prim_ammo:set_center_x(self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):x() + self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):w() / 2)
	self._sec_ammo:set_center_x(self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):x() + self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):w() / 2)
end

function HUDTeammate:_set_infinite_ammo(state)
	self._infinite_ammo = state
	if self._prim_ammo then
		if self._infinite_ammo then
			local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
			local pammo_clip = self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip")
			local sammo_clip = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip")

			self._prim_ammo:set_visible(true)
			self._sec_ammo:set_visible(true)
			self._prim_ammo:animate(hudinfo.flash_icon, 4000000000)
			self._sec_ammo:animate(hudinfo.flash_icon, 4000000000)

			pammo_clip:set_color(Color.white)
			pammo_clip:set_text("8")
			pammo_clip:set_rotation(90)
			if hud_ammo then
				pammo_clip:set_font_size(30)
				sammo_clip:set_font_size(30)
			end

			sammo_clip:set_color(Color.white)
			sammo_clip:set_text("8")
			sammo_clip:set_rotation(90)
		else
			self._prim_ammo:set_visible(false)
			self._sec_ammo:set_visible(false)
		end
	end
end

if hud_ammo then
	local function selected(o)
		over(0.5, function(p)
			o:set_alpha(math_lerp(0.5, 1, p))
		end)
	end
	local function unselected(o)
		over(0.5, function(p)
			o:set_alpha(math_lerp(1, 0.5, p))
		end)
	end
	Hooks:PreHook(HUDTeammate, "set_weapon_selected", "HMH_HUDTeammate_set_weapon_selected", function(self, id, hud_icon, ...)
		if not self._player_panel:child("weapons_panel"):child("secondary_weapon_panel") then return end
		local is_secondary = id == 1
		local secondary_weapon_panel = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel")
		local primary_weapon_panel = self._player_panel:child("weapons_panel"):child("primary_weapon_panel")

		secondary_weapon_panel:stop()
		primary_weapon_panel:stop()

		if is_secondary then
			primary_weapon_panel:animate(unselected)
			secondary_weapon_panel:animate(selected)
		else
			secondary_weapon_panel:animate(unselected)
			primary_weapon_panel:animate(selected)
		end
	end)
end

Hooks:PostHook(HUDTeammate, "set_ammo_amount_by_type", "EIVHUD_HUDTeammate_set_ammo_amount_by_type", function(self, type, max_clip, current_clip, current_left, max, weapon_panel)
	local weapon_panel = self._player_panel:child("weapons_panel"):child(type .. "_weapon_panel")
	local ammo_clip = weapon_panel:child("ammo_clip")

	if self._alt_ammo and ammo_clip:visible() then
		current_left = math_max(0, current_left - max_clip - (current_clip - max_clip))
	end

	local low_ammo_color = Color(1, 0.9, 0.9, 0.3)
	local total_ammo_color = Color.white
	local clip_ammo_color = Color.white
	local low_ammo = current_left <= math_round(max_clip / 2)
	local low_clip = current_clip <= math_round(max_clip / 4)
	local out_of_clip = current_clip <= 0
	local out_of_ammo = current_left <= 0
	local color_total = out_of_ammo and Color(1 , 0.9 , 0.3 , 0.3)
	
	color_total = color_total or low_ammo and (low_ammo_color)
	color_total = color_total or (total_ammo_color)
	
	local color_clip = out_of_clip and Color(1 , 0.9 , 0.3 , 0.3)
	
	color_clip = color_clip or low_clip and (low_ammo_color)
	color_clip = color_clip or (clip_ammo_color)
	
	local ammo_total = weapon_panel:child("ammo_total")
	local zero = current_left < 10 and "00" or current_left < 100 and "0" or ""
	
	ammo_total:set_text(zero ..tostring(current_left))
	ammo_total:set_color(color_total)
	ammo_total:set_range_color(0, string.len(zero), color_total:with_alpha(0.5))
	
	local zero_clip = current_clip < 10 and "00" or current_clip < 100 and "0" or ""
	ammo_clip:set_color(color_clip)
	ammo_clip:set_range_color(0, string.len(zero_clip), color_clip:with_alpha(0.5))
		
	if hud_ammo then
		local ammo_font = string.len(current_left) < 4 and 24 or 20
		ammo_total:stop()
		ammo_clip:stop()
			
		if not self._last_ammo then
			self._last_ammo = {}
			self._last_ammo[type] = current_left
		end

		if not self._last_clip then
			self._last_clip = {}
			self._last_clip[type] = current_clip
		end

		if self._last_ammo and self._last_ammo[type] and self._last_ammo[type] < current_left then
			ammo_total:animate(function(o)
				local s = self._last_ammo[type]
				local e = current_left
				over(0.5, function(p)
					local value = math_lerp(s, e, p)
					local text = string.format("%.0f", value)
					local zero = math_round(value) < 10 and "00" or math_round(value) < 100 and "0" or ""
					local low_ammo = value <= math_round(max_clip / 2)
					local out_of_ammo = value <= 0
					local color_total = out_of_ammo and Color(1, 0.9, 0.3, 0.3)
					color_total = color_total or low_ammo and low_ammo_color
					color_total = color_total or (total_ammo_color)

					ammo_total:set_text(zero .. text)
					ammo_total:set_color(color_total)
					ammo_total:set_range_color(0, string.len(zero), color_total:with_alpha(0.5))
				end)
				over(1 , function(p)
					local n = 1 - math_sin((p / 2 ) * 180)
					ammo_total:set_font_size(math_lerp(ammo_font, ammo_font + 4, n))
				end)
			end)
		end

		if self._last_clip and self._last_clip[type] and self._last_clip[type] < current_clip and not self._infinite_ammo then
			ammo_clip:animate(function(o)
				local s = self._last_clip[type]
				local e = current_clip
				over(0.25, function(p)
					local value = math_lerp(s, e, p)
					local text = string.format( "%.0f", value)
					local zero = math_round(value) < 10 and "00" or math_round(value) < 100 and "0" or ""
					local low_clip = value <= math_round(max_clip / 4)
					local out_of_clip = value <= 0
					local color_clip = out_of_clip and Color(1, 0.9, 0.3, 0.3)

					color_clip = color_clip or low_clip and low_ammo_color
					color_clip = color_clip or (clip_ammo_color)

					ammo_clip:set_text(zero .. text)
					ammo_clip:set_color(color_clip)
					ammo_clip:set_range_color(0, string.len(zero), color_clip:with_alpha(0.5))
				end)
			end)
		end
		self._last_ammo[type] = current_left
		self._last_clip[type] = current_clip
	end
	
	if self._main_player and self._infinite_ammo then
		ammo_clip:set_color(Color.white)
		ammo_clip:set_text("8")
		ammo_clip:set_rotation(90)
		if hud_ammo then
			ammo_clip:set_font_size(30)
		end
	else
		ammo_clip:set_rotation(0)
	end
end)

Hooks:PostHook(HUDTeammate, "set_revives_amount", "EIVHUD_HUDTeammate_set_revives_amount", function(self, revive_amount, ...)
	if EIVHUD.Options:GetValue("HUD/PLAYER/Downs") and revive_amount then
		local teammate_panel = self._panel:child("player")
		local revive_panel = teammate_panel:child("revive_panel")
		local revive_amount_text = revive_panel:child("revive_amount")
		local revive_arrow = revive_panel:child("revive_arrow")
		local revive_bg = revive_panel:child("revive_bg")
		local team_color = self._peer_id and tweak_data.chat_colors[self._peer_id] or (not self._ai and tweak_data.chat_colors[managers.network:session():local_peer():id()]) or Color.white
		local bg_alpha = EIVHUD.Options:GetValue("HUD/PLAYER/Team_bg") and 0 or 0.6
		
		if revive_amount_text then
			revive_amount_text:set_text(tostring(math_max(revive_amount - 1, 0)))
			revive_amount_text:set_color(revive_amount > 1 and team_color or Color.red)
			revive_amount_text:set_font_size(17)
			revive_amount_text:animate(function(o)
				over(1, function(p)
					local n = 1 - math_sin((p / 2 ) * 180)
					revive_amount_text:set_font_size(math_lerp(17, 17 * 0.85, n))
				end)
			end)
			
			if revive_arrow then
				revive_arrow:set_color(revive_amount > 1 and team_color or Color.red)
			end
			
			if revive_bg then
				revive_bg:set_color(Color.black / 3)
				revive_bg:set_alpha(bg_alpha)
			end
		end
	end
end)