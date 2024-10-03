local function hide_element(element)
    if element then
        element:set_visible(false)
        element:set_alpha(0)
    end
end

local function hide_elements(elements)
    for _, element in ipairs(elements) do
        hide_element(element)
    end
end

if EIVHUD.Options:GetValue("HUD/ShowHostages") > 1 then 
    Hooks:PostHook(HUDAssaultCorner, "init", "EIVHUD_HUDAssaultCorner_init", function(self, hud, ...)
        local hostages_panel = self._hud_panel:child("hostages_panel")
        hide_elements({
            self._hostages_bg_box,
            hostages_panel:child("hostages_icon")
        })
        self._hud_panel = hud.panel
        self:setup_wave_display(0, hud.panel:w() + 9)
    end)

    Hooks:PostHook(HUDAssaultCorner, "show_casing", "EIVHUD_HUDAssaultCorner_show_casing", function(self, ...)
        managers.hud._hud_ecm_counter._ecm_panel:set_top(50)
    end)

    Hooks:PostHook(HUDAssaultCorner, "hide_casing", "EIVHUD_HUDAssaultCorner_hide_casing", function(self, ...)
        managers.hud._hud_ecm_counter._ecm_panel:set_top(0)
    end)
end

if EIVHUD.Options:GetValue("HUD/ShowWaves") == 2 then
    Hooks:PostHook(HUDAssaultCorner, "setup_wave_display", "EIVHUD_HUDAssaultCorner_setup_wave_display", function(self, ...)
        if self:should_display_waves() then
            local wave_panel = self._hud_panel:child("wave_panel")
            hide_elements({
                wave_panel,
                self._wave_bg_box:child("bg"),
                self._wave_bg_box:child("left_top"),
                self._wave_bg_box:child("left_bottom"),
                self._wave_bg_box:child("right_top"),
                self._wave_bg_box:child("right_bottom"),
                wave_panel:child("waves_icon"),
                self._wave_bg_box:child("num_waves")
            })
        end
    end)
end