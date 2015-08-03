#!/usr/bin/env lua

local lgi = require "lgi"
local discount = require "discount"
local markdown = discount.compile
local GLib, Gio, Gtk, Gdk = lgi.GLib, lgi.Gio, lgi.Gtk, lgi.Gdk
local GClosure = lgi.GObject.Closure
local WebKit2 = lgi.WebKit2
local CANCEL, ACCEPT = Gtk.ResponseType.CANCEL, Gtk.ResponseType.ACCEPT
local assert, tostring, stderr = assert, tostring, io.stderr
local progname = arg[0]
local filename, infile, window
local _ENV = nil

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
    <style>%s</style>
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
    filename = args[2]
    if filename then
        infile = assert(cmdline:create_file_for_arg(filename))
        assert(infile:query_exists(), "File doesn't exist")
        local type = infile:query_file_type(Gio.FileQueryInfoFlags.NONE)
        assert(type ~= "DIRECTORY", "Expecting file; got directory")
    end
    self:activate()
    return 0
end

function app:on_activate()
    local header = Gtk.HeaderBar{show_close_button = true}

    local webview = WebKit2.WebView {
        vexpand = true,
        hexpand = true,
        on_load_changed = function(self, event)
            if event == "FINISHED" and self.uri ~= "about:blank" then
                header.title = self:get_title()
                header.subtitle = "Hit Ctrl+r to return"
            end
        end
    }

    local settings = webview:get_settings()
    settings.enable_javascript = false
    settings.enable_plugins = false
    settings.enable_page_cache = false

    local context = WebKit2.WebContext.get_default()
    context:set_cache_model(WebKit2.CacheModel.DOCUMENT_VIEWER)

    local find_options = WebKit2.FindOptions{"WRAP_AROUND", "CASE_INSENSITIVE"}
    local find_controller = webview:get_find_controller()

    local search_bar = Gtk.SearchBar {
        Gtk.SearchEntry {
            width = 320,
            on_search_changed = function(self)
                find_controller:search(self.text, find_options, 5000)
            end,
            on_activate = function(self)
                find_controller:search_next()
            end
        }
    }

    local search_button = Gtk.ToggleButton {
        id = "search_button",
        child = Gtk.Image.new_from_icon_name("edit-find-symbolic", 1),
    }

    search_button:bind_property("active", search_bar, "search-mode-enabled",
                                "BIDIRECTIONAL")

    local function reload()
        if not infile or infile:query_exists() == false then
            if filename then
                -- TODO: Use Evince-style message banner instead of this
                stderr:write("Warning: file not found: '", filename, "'\n")
                header.title = filename
                header.subtitle = "[File not found]"
            else
                header.title = ""
                header.subtitle = ""
            end
            webview:load_uri("about:blank")
            return
        end
        local text = assert(infile:load_contents())
        local doc = markdown(tostring(text), "toc")
        local title = doc.title or filename
        local html = template:format(title, stylesheet, doc.index, doc.body)
        header.title = title
        header.subtitle = (title ~= filename) and filename or nil
        webview:load_html(html)
        local monitor = infile:monitor(lgi.Gio.FileMonitorFlags.NONE)
            function monitor:on_changed(file, ud, event)
            if event == "CHANGED" or event == "CREATED" then
                reload()
            end
        end
    end

    local screen = assert(Gdk.Screen:get_default())
    local screen_height = assert(screen:get_height())
    local screen_width = assert(screen:get_width())

    window = Gtk.ApplicationWindow {
        type = Gtk.WindowType.TOPLEVEL,
        application = app,
        icon_name = "showdown",
        default_width = screen_width * 0.8,
        default_height = screen_height * 0.92,
        Gtk.Grid {
            orientation = "VERTICAL",
            search_bar,
            webview
        }
    }

    local open_button = Gtk.Button {
        id = "open_button",
        child = Gtk.Image.new_from_icon_name("document-open-symbolic", 1),
        on_clicked = function(self)
            local file_chooser = Gtk.FileChooserDialog {
                title = "Open",
                action = Gtk.FileChooserAction.OPEN,
                parent = window.child._widget,
                buttons = {
                    {"_Cancel", CANCEL},
                    {"_Open", ACCEPT},
                }
            }
            file_chooser:set_default_response(ACCEPT)
            file_chooser:set_transient_for(window)

            if filename then
                file_chooser:set_filename(filename)
            else
                file_chooser:set_current_folder(GLib.get_current_dir())
            end

            local md = Gtk.FileFilter()
            md:add_mime_type("text/x-markdown")
            md:set_name("Markdown files")
            file_chooser:add_filter(md)

            local all = Gtk.FileFilter()
            all:add_mime_type("*")
            all:set_name("All files")
            file_chooser:add_filter(all)

            if file_chooser:run() == ACCEPT then
                filename = file_chooser:get_filename()
                infile = Gio.File.new_for_path(filename)
                reload()
            end
            file_chooser:destroy()
        end
    }

    local CTRL, LOCKED = Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.LOCKED
    local accels = Gtk.AccelGroup.new()
    open_button:add_accelerator("clicked", accels, ("o"):byte(), CTRL, LOCKED)
    search_button:add_accelerator("clicked", accels, ("f"):byte(), CTRL, LOCKED)
    accels:connect(("r"):byte(), CTRL, LOCKED, GClosure(reload))

    header:pack_start(open_button)
    header:pack_end(search_button)

    window:add_accel_group(accels)
    window:set_titlebar(header)
    window:set_wmclass("showdown", "Showdown")

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
    appmenu:freeze()
    app:set_app_menu(appmenu)
    app:add_action(about_action)
    app:add_action(quit_action)
    app:set_accels_for_action("app.quit", {"<Ctrl>Q", "<Ctrl>W"})

    if infile then
        reload()
    end

    window:show_all()
end

return app:run{progname, ...}
