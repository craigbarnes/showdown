#!/usr/bin/env lua

local lgi = require "lgi"
local markdown = require "discount"
local GLib = lgi.GLib
local Gio = lgi.Gio
local Gtk = lgi.Gtk
local Gdk = lgi.Gdk
local WebKit2 = lgi.WebKit2
local filename, infile, window

-- TODO: Better fallback stylesheet
local user_config_dir = assert(lgi.GLib.get_user_config_dir()) .. "/showdown"
local user_stylesheet = io.open(user_config_dir .. "/stylesheet.css")
local stylesheet = user_stylesheet and assert(user_stylesheet:read("*a")) or ""

local app = Gtk.Application {
    application_id = "org.showdown",
    flags = Gio.ApplicationFlags.HANDLES_COMMAND_LINE
}

local template = [[
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>%s</title>
</head>
<body>
    <main>
        <nav id="toc">
            %s
        </nav>
        %s
    </main>
</body>
</html>
]]

function app:on_command_line(cmdline)
    local args = cmdline:get_arguments()
    filename = assert(args[1], "No file was specified")
    infile = cmdline:create_file_for_arg(filename)
    assert(infile:query_exists(), "File doesn't exist")
    self:activate()
    return 0
end

function app:on_activate()
    local header = Gtk.HeaderBar{show_close_button = true}
    local webview = WebKit2.WebView()

    local settings = webview:get_settings()
    settings.enable_javascript = false
    settings.enable_plugins = false
    settings.enable_page_cache = false

    local context = WebKit2.WebContext.get_default()
    context:set_cache_model(WebKit2.CacheModel.DOCUMENT_VIEWER)

    local viewgroup = webview:get_group()
    local frameopts = WebKit2.InjectedContentFrames.TOP_ONLY
    viewgroup:add_user_style_sheet(stylesheet, nil, nil, nil, frameopts)

    function webview:on_load_changed(event)
        if event == "FINISHED" and self.uri ~= "about:blank" then
            header.title = webview:get_title()
            header.subtitle = "Hit Backspace to return"
        end
    end

    local function reload()
        local text = assert(infile:load_contents())
        local doc = markdown(tostring(text), "toc")
        local title = doc.title or filename
        local html = template:format(title, doc.index, doc.body)
        header.title = title
        header.subtitle = (title ~= filename) and filename or nil
        webview:load_html(html)
    end

    window = Gtk.ApplicationWindow {
        type = Gtk.WindowType.TOPLEVEL,
        application = self,
        icon_name = "showdown",
        default_width = 750,
        default_height = 520,
        child = webview,
        on_show = reload
    }

    window:set_titlebar(header)
    window:set_wmclass("showdown", "Showdown")

    function window:on_key_press_event(event)
        if Gdk.keyval_name(event.keyval) == "BackSpace" then
            reload()
            urichanged = false
            return true
        end
    end

    local about = Gtk.AboutDialog {
        program_name = "Showdown",
        logo_icon_name = "showdown",
        comments = "Simple Markdown viewer",
        version = "0.2",
        copyright = "Copyright 2013 Craig Barnes",
        license_type = Gtk.License.GPL_3_0,
        website = "https://github.com/craigbarnes/showdown"
    }

    local about_action = Gio.SimpleAction {
        name = "about",
        on_activate = function()
            about:run()
            about:hide()
        end
    }

    local quit_action = Gio.SimpleAction {
        name = "quit",
        on_activate = function()
            self:quit()
        end
    }

    local appmenu = Gio.Menu()
    appmenu:append("About", "app.about")
    appmenu:append("Quit", "app.quit")
    self:set_app_menu(appmenu)
    self:add_action(about_action)
    self:add_action(quit_action)

    local monitor = infile:monitor(lgi.Gio.FileMonitorFlags.NONE)
    function monitor:on_changed(file, ud, event)
        if event == "CHANGED" or event == "CREATED" then
            reload()
        end
    end

    window:show_all()
end

return app:run{...}
