if RequiredScript == "lib/managers/hudmanagerpd2" then
	HUDECMCounter = HUDECMCounter or class()
    function HUDECMCounter:init(hud)
		self._ecm_timer = 0
	    self._hud_panel = hud.panel
	    self._ecm_panel = self._hud_panel:panel({
		    name = "ecm_counter_panel",
			alpha = 1,
		    visible = false,
		    w = 200,
		    h = 200
	    })
	    self._ecm_panel:set_top(50)
        self._ecm_panel:set_right(self._hud_panel:w() + 11)

	    local ecm_box = HUDBGBox_create(self._ecm_panel, { w = 38, h = 38, },  {})
		if EIVHUD.Options:GetValue("HUD/HideBox") then
		   ecm_box:child("bg"):hide()
		   ecm_box:child("left_top"):hide()
		   ecm_box:child("left_bottom"):hide()
		   ecm_box:child("right_top"):hide()
		   ecm_box:child("right_bottom"):hide()
	    end

	    self._text = ecm_box:text({
		    name = "text",
		    text = "0",
		    valign = "center",
		    align = "center",
		    vertical = "center",
		    w = ecm_box:w(),
		    h = ecm_box:h(),
		    layer = 1,
		    color = Color.white,
		    font = tweak_data.hud_corner.assault_font,
		    font_size = tweak_data.hud_corner.numhostages_size * 0.9
	    })

	    local ecm_icon = self._ecm_panel:bitmap({
		    name = "ecm_icon",
		    texture = "guis/textures/pd2/skilltree/icons_atlas",
		    texture_rect = { 1 * 64, 4 * 64, 64, 64 },
		    valign = "top",
			color = Color.white,
		    layer = 1,
		    w = ecm_box:w(),
		    h = ecm_box:h()	
	    })
	    ecm_icon:set_right(ecm_box:parent():w())
	    ecm_icon:set_center_y(ecm_box:h() / 2)
		ecm_box:set_right(ecm_icon:left())
    end
	
    function HUDECMCounter:update()
		local current_time = TimerManager:game():time()
		local t = self._ecm_timer - current_time
		if managers.groupai and managers.groupai:state():whisper_mode() then
			self._ecm_panel:set_visible(t > 0)
			if t > 0.1 then
			    local t_format = t < 10 and "%.1fs" or "%.fs"
				self._text:set_text(string.format(t_format, t))
			end
		else
			self._ecm_panel:set_visible(false)
		end
    end

	--Init
	Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "EIVHUD_ECM_setup_player_info_hud_pd2", function(self, ...)
		self._hud_ecm_counter = HUDECMCounter:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
		self:add_updator("EIVHUD_ECM_UPDATOR", callback(self._hud_ecm_counter, self._hud_ecm_counter, "update"))
	end)

elseif RequiredScript == "lib/units/equipment/ecm_jammer/ecmjammerbase" then
	--PeerID
	local original_spawn = ECMJammerBase.spawn
	function ECMJammerBase.spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id, ...)
		local unit = original_spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id, ...)
		unit:base():SetPeersID(peer_id)
		return unit
	end

	Hooks:PostHook(ECMJammerBase, "set_server_information", "EIVHUD_ECMJammerBase_set_server_information", function(self, peer_id, ...)
		self:SetPeersID(peer_id)
	end)

	Hooks:PostHook(ECMJammerBase, "sync_setup", "EIVHUD_ECMJammerBase_sync_setup", function(self, upgrade_lvl, peer_id, ...)
		self:SetPeersID(peer_id)
	end)

	Hooks:PostHook(ECMJammerBase, "set_owner", "EIVHUD_ECMJammerBase_set_owner", function(self, ...)
		self:SetPeersID(self._owner_id or 0)
	end)

	function ECMJammerBase:SetPeersID(peer_id)
		local id = peer_id or 0
		self._EIVHUD_peer_id = id
		self._EIVHUD_local_peer = id == managers.network:session():local_peer():id()
	end

	--ECM Timer Host and Client
	Hooks:PostHook(ECMJammerBase, "set_active", "EIVHUD_ECMJammerBase_set_active", function(self, active, ...)
		if active and EIVHUD.Options:GetValue("HUD/Infoboxes") then
		    local battery_life = self:battery_life()
            if battery_life == 0 then
                return
            end
			local ecm_timer = TimerManager:game():time() + battery_life
			local jam_pagers = false
			if self._EIVHUD_local_peer then
				jam_pagers = managers.player:has_category_upgrade("ecm_jammer", "affects_pagers")
			elseif self._EIVHUD_peer_id ~= 0 then
				local peer = managers.network:session():peer(self._EIVHUD_peer_id)
				if peer and peer._unit and peer._unit.base then
					jam_pagers = peer._unit:base():upgrade_value("ecm_jammer", "affects_pagers")
				end
			end
			if jam_pagers or not EIVHUD.Options:GetValue("HUD/PagerJam") then
				managers.hud._hud_ecm_counter._ecm_timer = ecm_timer
			else
				return
			end
		end
	end)

elseif RequiredScript == "lib/units/beings/player/playerinventory" then
	-- Pocket ECM
	Hooks:PostHook(PlayerInventory, "_start_jammer_effect", "EIVHUD_PlayerInventory_start_jammer_effect", function(self, end_time, ...)
		local ecm_timer = end_time or TimerManager:game():time() + self:get_jammer_time()
		if ecm_timer > managers.hud._hud_ecm_counter._ecm_timer then
			managers.hud._hud_ecm_counter._ecm_timer = ecm_timer
		end
	end)
end