local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
local helpers = require("helpers")
local theme_assets = require("beautiful.theme_assets")
local xdg_menu = require("archmenu")

-- ############################################################################################
local HOSTNAME = helpers.hostname

local APPS = {
    ["terminal"] = "lxterminal",
    ["lock_manager"] = "i3lock -c 222f42",
    ["file_manager"] = "pcmanfm",
    ["browser"] = "firefox",
    ["calculator"] = "galculator",
}

local TITLEBAR_SIZE = 22

-- ############################################################################################
-- Theme
function initTheme()
    beautiful.init(gears.filesystem.get_themes_dir() .. "zenburn/theme.lua")
    beautiful.useless_gap = 1

    local color_f = "#285577"
    local color_n = "#5f676a"
    local color_u = "#FF5500"
    --local color_u = "#FE8600"

    -- urgent
    beautiful.bg_urgent = beautiful.bg_normal
    beautiful.fg_urgent = color_u

    -- borders
    --beautiful.border_focus = color_f
    --beautiful.border_normal = color_n

    -- titlebar
    beautiful.titlebar_minimize_button_normal = beautiful.titlebar_sticky_button_normal_inactive
    beautiful.titlebar_minimize_button_focus = beautiful.titlebar_sticky_button_focus_active


    -- notifications
    --	beautiful.notification_bg = color_f
    --	beautiful.notification_fg = "#ffffff"
    --	beautiful.notification_border_color = "#aaaaaa"

    -- tooltips
    --beautiful.tooltip_bg = beautiful.bg_normal
    beautiful.tooltip_border_color = beautiful.fg_focus
    beautiful.tooltip_border_width = 0.8

    -- disable default wallpaper
    beautiful.wallpaper = nil
    gears.wallpaper.set("#1F1F1F")

    -- env
    beautiful.xresources.set_dpi(128)
    beautiful.font = "Ubuntu Bold 10"
    beautiful.border_width = 3
    beautiful.wibar_height = 20
    --beautiful.notification_width = 350
    beautiful.notification_max_width = 350
    beautiful.notification_max_height = 100
    beautiful.systray_icon_spacing = 2

    if HOSTNAME == "ux533f" then
        beautiful.xresources.set_dpi(130)
    end
end

-- ############################################################################################
-- Menu

function getMenu()
    awesome_menu = {
        { "Restart", awesome.restart },
        { "Exit", function() helpers.promptRun("exit ?", awesome.quit) end }
    }

    exit_menu = {
        { "Suspend", "systemctl suspend -i" },
        { "Shutdown", function() helpers.promptRun("shutdown ?", "systemctl poweroff -i") end },
        { "Reboot", function() helpers.promptRun("reboot ?", "systemctl reboot -i") end },
    }

    main_menu = awful.menu({
        items = {
            { "Awesome", awesome_menu, beautiful.awesome_icon },
            { "Applications", xdgmenu },
            { "File Manager", APPS.file_manager },
            { "Audio Mixer", "pavucontrol" },
            { "Calculator", APPS.calculator },
            { "System", exit_menu },
            { "Lock", APPS.lock_manager }
        }
    })

    return main_menu
end

-- ############################################################################################
-- Hotkeys

function getHotkeys()
    hotkeys = gears.table.join(awful.key({ modkey, }, "r", function() awful.spawn('rofi -show run') end),
        awful.key({ modkey, "Shift" }, "d", function() awful.spawn('rofi -show windowcd') end),
        awful.key({ modkey, "Shift" }, "p", function() awful.spawn(APPS.file_manager) end),
        awful.key({ modkey, "Shift" }, "F12", function() awful.spawn(APPS.lock_manager) end),
        awful.key({ modkey, "Shift" }, "XF86Favorites", function() awful.spawn(APPS.lock_manager) end),

        awful.key({}, "XF86AudioRaiseVolume", function() helpers.volume("inc") end),
        awful.key({}, "XF86AudioLowerVolume", function() helpers.volume("dec") end),
        awful.key({}, "XF86AudioMute", function() helpers.volume("toggle") end),
        awful.key({}, "XF86AudioMicMute", function() awful.spawn.with_shell("mic_toggle") end),
        awful.key({}, "XF86MonBrightnessUp", function() helpers.backlight("inc") end),
        awful.key({}, "XF86MonBrightnessDown", function() helpers.backlight("dec") end),

        awful.key({}, "XF86AudioPlay", function() awful.spawn('playerctl play-pause') end),
        awful.key({}, "XF86AudioPrev", function() awful.spawn('playerctl previous') end),
        awful.key({}, "XF86AudioNext", function() awful.spawn('playerctl next') end),

        awful.key({ modkey, }, "Up", function() awful.client.focus.bydirection("up") end),
        awful.key({ modkey, }, "Down", function() awful.client.focus.bydirection("down") end),
        awful.key({ modkey, }, "Left", function() awful.client.focus.bydirection("left") end),
        awful.key({ modkey, }, "Right", function() awful.client.focus.bydirection("right") end),

        awful.key({ modkey, }, "s", function() awful.screen.focused().tags[9]:view_only() end),
        awful.key({ modkey, }, "g", function() awful.screen.focused().tags[8]:view_only() end),
        awful.key({ modkey, }, "d", function() awful.screen.focused().tags[7]:view_only() end),

        awful.key({ modkey, "Shift" }, "/", hotkeys_popup.show_help),
        --			awful.key({ 'Ctrl',			}, "space",	naughty.destroy_all_notifications),
        awful.key({ modkey }, "XF86Tools", function() awful.spawn.with_shell('up_vpn.sh') end),

        awful.key({ modkey, "Shift" }, "XF86Tools", function() awful.spawn.with_shell('nmcli connection down tinkoff') end),

        -- clipboard
        --awful.key({ 'Ctrl', }, "grave", function() awful.spawn.with_shell('gpaste-menu') end),
        awful.key({ 'Ctrl',      }, "grave",  function () awful.spawn.with_shell('clipmenu') end),
	awful.key({ 'Ctrl', }, "Print", function() awful.spawn.with_shell('flameshot gui -p ~/screen') end))

    return hotkeys
end

-- ############################################################################################
-- Tags layouts
function getLayouts()
    layouts = {}
    for i = 1, 9 do layouts[i] = awful.layout.suit.tile end

    layouts[2] = awful.layout.suit.max
    layouts[3] = awful.layout.suit.max

    return layouts
end

-- ############################################################################################
-- Client rules
function getClientRules(client_rules, geo)
    -- float apps list
    float_app = {
        "Nm-connection-editor",
        "Vpnui",
        "Google Play Music Desktop Player",
        "Pavucontrol",
        "Nitrogen",
        "Transmission-gtk",
        "Blueman-manager",
        "Spotify",
        "qBittorrent",
        "mpv",
        "Skype"
    }
    float_app_top = {
        "Galculator",
        "flameshot"
    }

    float_no_title = {
        "Gcolor3"
    }
    local screen_number = screen.count()
    local zoom_number = "1"
    awful.spawn.with_shell("notify-send 'TEST ".. tostring(geo.width) .. " " .. tostring(screen_number) .. "'")
    if screen_number == 1 then zoom_number = "7" end

    -- host additional settings
    --float_app = gears.table.join(float_app, {"TelegramDesktop"})
    client_rules = gears.table.join(client_rules, {
        { rule = { class = "TelegramDesktop" }, properties = { screen = 1, tag = "5" } },
        { rule = { class = "Slack" }, properties = { screen = 1, tag = "9" } },
        { rule = { class = "Evolution" }, properties = { screen = 1, tag = "8" } },
        { rule = { class = "Chromium" }, properties = { screen = 1, tag = "3" } },
        { rule = { class = "zoom" }, properties = { screen = screen_number, tag = zoom_number } },
        { rule = { class = "eu.tiliado.NuvolaAppYandexMusic" }, properties = { screen = 1, tag = "6" } }
    })

    -- set window rules
    client_rules = gears.table.join(client_rules, {
        -- disable titlebars
        { rule_any = { type = { "normal" } }, properties = { titlebars_enabled = false } },

        -- set floating
        {
            rule_any = { class = gears.table.join(float_app, float_app_top) },
            properties = { floating = true, titlebars_enabled = true }
        },

        -- set floating without titlebar
        {
            rule_any = { class = float_no_title },
            properties = { floating = true, titlebars_enabled = false }
        },

        -- set on-top
        { rule_any = { class = float_app_top }, properties = { ontop = true } },

        -- fix for chromium
        --{rule = {class = "Chromium"}, properties = {floating = true}},
        { rule = { class = "Chromium", role = "pop-up" }, properties = { titlebars_enabled = true } },

        -- thunderbird
        { rule = { class = "Thunderbird" }, properties = { screen = 1, tag = "8" } },

        -- firefox
        {
            rule = { class = "Firefox", role = "Organizer" },
            properties = {
                floating = true,
                titlebars_enabled = true
            }
        }
    })

    return client_rules
end

-- ############################################################################################
-- Autostart
function initAutostart()
    apps_list = {
        'xsettingsd',
        'redshift-gtk',
        'xss-lock -- ' .. APPS.lock_manager,
        'libinput-gestures-setup start',
        '/usr/lib/xfce4/notifyd/xfce4-notifyd',
        'blueman-applet',
	'dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY',
        --'/usr/lib/gpaste/gpaste-daemon',
        'clipmenud',
	'flameshot',
        'slack',
        'chromium',
        'zoom',
    }

    awful.spawn.with_shell('setxkbmap -layout "us,ru" -option grp:caps_toggle')
    apps_list = gears.table.join(apps_list, {
        --'picom',
        'thunderbird',
        'nm-applet',
        'light -N 1'
    })
    awful.spawn.with_shell('sleep 5 && telegram-desktop')

    -- run
    for i, app_name in ipairs(apps_list) do helpers.runOnce(app_name) end

    -- setup tags
    awful.tag.incmwfact(0.10, awful.tag.find_by_name(awful.screen.focused(), "9"))
end

-- ############################################################################################

return {
    apps = APPS,
    titlebar_size = TITLEBAR_SIZE,
    initTheme = initTheme,
    initAutostart = initAutostart,
    getMenu = getMenu,
    getHotkeys = getHotkeys,
    getLayouts = getLayouts,
    getClientRules = getClientRules
}
