namespace Showdown {

class Window: Gtk.ApplicationWindow {
    public string? filename = null;
    public Gtk.HeaderBar header;
    public Gtk.SearchBar search_bar;
    public Gtk.ToggleButton search_button;
    public WebKit.WebView webview;
    public WebKit.FindController find_controller;

    const ActionEntry[] actions = {
        {"open", open},
        {"reload", reload},
        {"print", print},
    };

    public Window(Application app) {
        Object(application: app, title: "Showdown", icon_name: "showdown");
        add_action_entries(actions, this);

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

        var menu_model = new Menu();
        menu_model.append("Open", "win.open");
        menu_model.append("Reload", "win.reload");
        // TODO: menu_model.append("Print", "win.print");

        var menu_button = new Gtk.MenuButton();
        menu_button.menu_model = menu_model;
        menu_button.add(get_menu_icon("open-menu-symbolic"));

        var accels = new Gtk.AccelGroup();
        const Gdk.ModifierType CTRL = Gdk.ModifierType.CONTROL_MASK;
        const Gtk.AccelFlags LOCKED = Gtk.AccelFlags.LOCKED;
        search_button.add_accelerator("clicked", accels, 'f', CTRL, LOCKED);
        accels.connect('r', CTRL, LOCKED, () => {reload(); return true;});
        accels.connect('o', CTRL, LOCKED, () => {open(); return true;});
        accels.connect('p', CTRL, LOCKED, () => {print(); return true;});
        add_accel_group(accels);

        header = new Gtk.HeaderBar();
        header.title = "Markdown Viewer";
        header.show_close_button = true;
        header.pack_start(search_button);
        header.pack_end(menu_button);
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

    void open() {
        var dialog = new OpenDialog(this, filename);
        if (dialog.run() == Gtk.ResponseType.ACCEPT) {
            filename = dialog.get_filename();
            reload();
        }
        dialog.destroy();
    }

    void print() {
        stderr.puts("TODO\n");
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
        uint8[] text;
        try {
            file.load_contents(null, out text, null);
        } catch (Error e) {
            stderr.printf("Error: %s\n", e.message);
            return;
        }
        var document = Markdown.parse((string)text);
        header.title = file.get_basename();
        header.subtitle = file.get_parent().get_path();
        var html = document_template.printf (
            "TODO: Page Title",
            stylesheet,
            document.render_html_toc(),
            document.render_html()
        );
        webview.load_html(html, file.get_uri());
    }
}

private Gtk.Image get_menu_icon(string name) {
    return new Gtk.Image.from_icon_name(name, Gtk.IconSize.MENU);
}

}
