#!/usr/bin/env lua

local lgi = require "lgi"
local markdown = require "discount"
local Gio = lgi.Gio
local Gtk = lgi.Gtk
local Gdk = lgi.Gdk
local WebKit2 = lgi.WebKit2
local filename, infile, window

local app = Gtk.Application {
    application_id = "org.showdown",
    flags = Gio.ApplicationFlags.HANDLES_COMMAND_LINE
}

local template = [[
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Markdown Preview</title>
    <style>
        body {
            margin: 2em;
            font: 0.9em/1.6 Helvetica, arial, freesans, clean, sans-serif;
            color: #333;
        }
        a {
            color: #4183C4;
            text-decoration: none;
        }
        a:hover {
            color: #ff6600;
            text-decoration: none;
        }
        h1, h2, h3, h4, h5, h6 {
            margin: 20px 0 5px;
            padding: 0;
            font-weight: bold;
        }
        h2 {
            font-size: larger;
            line-height: 1.5;
            text-decoration: underline;
        }
        pre, code, tt {
            font: normal 0.9em/1.4 Consolas, monospace;
        }
        pre {
            background-color: #F8F8F8;
            border: 1px solid #CCC;
            overflow: auto;
            margin: 0.5em 0;
            padding: 0.7em 1em;
            border-radius: 3px;
        }
        #toc {
            display: block;
            float: right;
            clear: right;
            max-width: 15em;
            margin: 0 0 1em 2em;
            padding: 1em;
            border: 1px solid #ccc;
        }
        #toc ul {
            margin: 0 0 0 1.2em;
            padding: 0.1em;
            font-size: small;
        }
    </style>
</head>
<body>
    <div id="main">
        <div id="toc">
            %s
        </div>
        %s
    </div>
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
    local webview = WebKit2.WebView()

    local settings = webview:get_settings()
    settings.enable_javascript = false
    settings.enable_plugins = false
    settings.enable_page_cache = false

    local context = WebKit2.WebContext.get_default()
    context:set_cache_model(WebKit2.CacheModel.DOCUMENT_VIEWER)

    function webview:on_load_changed(event)
        if event == "STARTED" and self.uri ~= "about:blank" then
            window.title = "Hit Backspace to return to " .. filename
        end
    end

    local function reload()
        local text = assert(infile:load_contents())
        local doc, toc = markdown(tostring(text), "toc")
        local html = template:format(toc, doc)
        webview:load_html(html)
    end

    window = Gtk.ApplicationWindow {
        type = Gtk.WindowType.TOPLEVEL,
        application = self,
        title = filename,
        icon_name = "showdown",
        default_width = 750,
        default_height = 520,
        child = webview,
        on_show = reload
    }

    window:set_wmclass("showdown", "showdown")

    function window:on_key_press_event(event)
        if Gdk.keyval_name(event.keyval) == "BackSpace" then
            reload()
            self.title = filename
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
