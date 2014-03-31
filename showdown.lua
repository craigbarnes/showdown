#!/usr/bin/env lua

local lgi = require "lgi"
local discount = require "discount"
local markdown = discount.compile
local GLib = lgi.GLib
local Gio = lgi.Gio
local Gtk = lgi.Gtk
local Gdk = lgi.Gdk
local WebKit2 = lgi.WebKit2
local filename, infile, window

local style_path = GLib.get_user_config_dir() .. "/showdown/stylesheet.css"
local style_file = Gio.File.new_for_path(style_path)
local stylesheet = style_file:load_contents()

if not stylesheet then
    -- @Default stylesheet
    style_file = Gio.File.new_for_path("gh.css")
    stylesheet = assert(style_file:load_contents())
    -- @end
end

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
    <nav id="toc">
        %s
    </nav>
    <main>
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
    local webview = WebKit2.WebView{vexpand = true, hexpand = true}

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
            header.subtitle = "Hit Alt+Backspace to return"
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

    local find_options = WebKit2.FindOptions{"WRAP_AROUND", "CASE_INSENSITIVE"}
    local find_controller = webview:get_find_controller()
    local search_entry = Gtk.SearchEntry{width = 320}
    local search_bar = Gtk.SearchBar{show_close_button = true, search_entry}
    search_bar:connect_entry(search_entry)

    function search_entry:on_search_changed()
        find_controller:search(self.text, find_options, 5000)
    end

    function search_entry:on_key_press_event(event)
        local key = Gdk.keyval_name(event.keyval)
        if key == "Return" then
            if event.state.SHIFT_MASK then
                find_controller:search_previous()
            else
                find_controller:search_next()
            end
        end
    end

    window = Gtk.ApplicationWindow {
        type = Gtk.WindowType.TOPLEVEL,
        application = app,
        icon_name = "showdown",
        default_width = 750,
        default_height = 520,
        on_show = reload,
        Gtk.Grid {
            orientation = "VERTICAL",
            search_bar,
            webview
        }
    }

    window:set_titlebar(header)
    window:set_wmclass("showdown", "Showdown")

    local keys = {
        ["Ctrl+Q"] = function() app:quit() end,
        ["Ctrl+W"] = function() window:close() end,
        ["Ctrl+F"] = function()
            search_bar.search_mode_enabled = not search_bar.search_mode_enabled
            return true
        end,
        ["Alt+BackSpace"] = function()
            reload()
            urichanged = false
            return true
        end
    }

    function window:on_key_press_event(event)
        local label = Gtk.accelerator_get_label(event.keyval, event.state)
        local val = keys[label]
        if val then
            local ok, ret
            if type(val) == "function" then
                ok, ret = pcall(val)
            elseif type(val) == "table" then
                ok, ret = pcall((table.unpack or unpack)(val))
            end
            if ok then return true end
        end
        return false
    end

    local about = Gtk.AboutDialog {
        program_name = "Showdown",
        logo_icon_name = "showdown",
        comments = "Simple Markdown viewer",
        version = "0.2",
        copyright = "Copyright 2013 Craig Barnes",
        license_type = Gtk.License.GPL_3_0,
        website = "https://github.com/craigbarnes/showdown",
        on_response = function(self, response)
            self:hide()
        end,
    }

    local about_action = Gio.SimpleAction {
        name = "about",
        on_activate = function()
            about:run()
        end
    }

    local quit_action = Gio.SimpleAction {
        name = "quit",
        on_activate = function()
            app:quit()
        end
    }

    local appmenu = Gio.Menu()
    appmenu:append("About", "app.about")
    appmenu:append("Quit", "app.quit")
    app:set_app_menu(appmenu)
    app:add_action(about_action)
    app:add_action(quit_action)

    local monitor = infile:monitor(lgi.Gio.FileMonitorFlags.NONE)
    function monitor:on_changed(file, ud, event)
        if event == "CHANGED" or event == "CREATED" then
            reload()
        end
    end

    window:show_all()
end

return app:run{...}
