namespace Showdown {

class Window: Gtk.ApplicationWindow {
    public string? filename = null;
    public Gtk.HeaderBar header;
    public Gtk.SearchBar search_bar;
    public Gtk.ToggleButton search_button;
    public WebKit.WebView webview;
    public WebKit.FindController find_controller;

    public Window(Application app) {
        Object(application: app, title: "Showdown", icon_name: "showdown");

        var search_entry = new Gtk.SearchEntry();
        search_entry.width_chars = 42;

        search_entry.search_changed.connect(() => {
            var find_options =
                WebKit.FindOptions.WRAP_AROUND +
                WebKit.FindOptions.CASE_INSENSITIVE;
            find_controller.search(search_entry.text, find_options, 5000);
        });

        search_entry.activate.connect(() => {
            find_controller.search_next();
        });

        search_bar = new Gtk.SearchBar();
        search_bar.add(search_entry);

        search_button = new Gtk.ToggleButton();
        search_button.add(get_menu_icon("edit-find-symbolic"));
        search_button.bind_property (
            "active",
            search_bar, "search-mode-enabled",
            BindingFlags.BIDIRECTIONAL
        );

        var open_button = new Gtk.Button();
        open_button.add(get_menu_icon("document-open-symbolic"));
        open_button.clicked.connect(() => {
            var dialog = new OpenDialog(this, filename);
            if (dialog.run() == Gtk.ResponseType.ACCEPT) {
                filename = dialog.get_filename();
                reload();
            }
            dialog.destroy();
        });

        var accels = new Gtk.AccelGroup();
        const Gdk.ModifierType CTRL = Gdk.ModifierType.CONTROL_MASK;
        const Gtk.AccelFlags LOCKED = Gtk.AccelFlags.LOCKED;
        open_button.add_accelerator("clicked", accels, 'o', CTRL, LOCKED);
        search_button.add_accelerator("clicked", accels, 'f', CTRL, LOCKED);
        accels.connect('r', CTRL, LOCKED, reload_cb);
        add_accel_group(accels);

        header = new Gtk.HeaderBar();
        header.title = "Markdown Viewer";
        header.show_close_button = true;
        header.pack_start(open_button);
        header.pack_end(search_button);
        set_titlebar(header);

        webview = new WebKit.WebView();
        webview.vexpand = true;
        webview.hexpand = true;
        find_controller = webview.get_find_controller();

        webview.load_changed.connect((self, event) => {
            if (
                event == WebKit.LoadEvent.FINISHED &&
                self.uri != "about:blank" &&
                self.uri != File.new_for_path(filename).get_uri()
            ) {
                header.title = webview.uri;
                header.subtitle = "Hit Ctrl+r to return";
            }
        });

        var settings = webview.get_settings();
        settings.enable_javascript = false;
        settings.enable_plugins = false;
        settings.enable_page_cache = false;

        var context = WebKit.WebContext.get_default();
        context.set_cache_model(WebKit.CacheModel.DOCUMENT_VIEWER);

        var screen = Gdk.Screen.get_default();
        var height = screen.get_height() * 0.92;
        var width = screen.get_width() * 0.8;
        set_default_size((int)width, (int)height);

        var grid = new Gtk.Grid();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.add(search_bar);
        grid.add(webview);
        add(grid);

        show_all();
    }

    bool reload_cb(Gtk.AccelGroup g, Object o, uint key, Gdk.ModifierType m) {
        reload();
        return true;
    }

    public void reload() {
        if (filename == null) {
            return;
        }
        string? failed = null;
        var file = File.new_for_path(filename);
        if (file.query_exists() == false) {
            failed = "File doesn't exist";
        } else if (file.query_file_type(0) == FileType.DIRECTORY) {
            failed = "Can't open a directory";
        }
        if (failed != null) {
            header.title = "Markdown Viewer";
            header.subtitle = "";
            var html = error_template.printf(file.get_uri(), failed);
            webview.load_alternate_html(html, "about:blank", null);
            return;
        }
        try {
            string output, errors;
            string[] argv = {
                "pandoc", // TODO: Make this configurable
                "-f", "markdown",
                "-t", "html5",
                filename,
                null
            };
            bool ok = Process.spawn_sync (
                null, // Working directory; null to inherit
                argv,
                null, // Enviroment; null to inherit
                SpawnFlags.SEARCH_PATH,
                null,
                out output,
                out errors,
                null
            );
            if (ok) {
                header.title = file.get_basename();
                header.subtitle = file.get_parent().get_path();
                var html = document_template.printf(
                    "TODO: Page Title",
                    default_stylesheet,
                    "TODO: Table of Contents",
                    output
                );
                webview.load_html(html, file.get_uri());
            } else {
                // TODO: proper error handling
                stderr.printf("%s\n", errors);
            }
        } catch (Error e) {
            stderr.printf("Error: %s\n", e.message);
        }
    }
}

class Application: Gtk.Application {
    public Application() {
        Object (
            application_id: "org.showdown",
            flags: ApplicationFlags.HANDLES_COMMAND_LINE
        );
    }

    public override int command_line(ApplicationCommandLine cmdline) {
        hold();
        var window = new Window(this);
        var args = cmdline.get_arguments();
        if (args.length >= 2) {
            window.filename = args[1];
            window.reload();
        }
        add_window(window);
        release();
        return 0;
    }

    void about() {
        unowned List<Gtk.Window> windows = get_windows();
        Gtk.show_about_dialog(windows != null ? windows.data : null,
            "program-name", "Showdown",
            "version", "0.4",
            "comments", "Simple Markdown viewer",
            "copyright", "Copyright 2015 Craig Barnes",
            "logo-icon-name", "showdown",
            "license-type", Gtk.License.GPL_3_0,
            "website", "https://github.com/craigbarnes/showdown"
        );
    }

    const ActionEntry[] actions = {
        {"about", about},
        {"quit", quit},
    };

    protected override void startup() {
        base.startup();
        add_action_entries(actions, this);

        var menu = new Menu();
        menu.append("About", "app.about");
        menu.append("Quit", "app.quit");
        menu.freeze();
        set_app_menu(menu);

        #if HAVE_PRE_3_12_GTK
            add_accelerator("<Primary>Q", "app.quit", null);
        #else
            const string[] quit_accels = {"<Primary>Q", null};
            set_accels_for_action("app.quit", quit_accels);
        #endif
    }

    public static int main(string[] args) {
        var app = new Application();
        return app.run(args);
    }
}

private Gtk.Image get_menu_icon(string name) {
    return new Gtk.Image.from_icon_name(name, Gtk.IconSize.MENU);
}

}
