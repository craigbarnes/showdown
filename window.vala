namespace Showdown {

class Window: Gtk.ApplicationWindow {
    public string? filename = null;
    Gtk.HeaderBar header;
    Gtk.SearchBar search_bar;
    Gtk.ToggleButton search_button;
    WebKit.WebView webview;
    WebKit.FindController find_controller;

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
        accels.connect('w', CTRL, LOCKED, () => {close(); return true;});
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

        webview.decide_policy.connect((self, decision, type) => {
            if (type == WebKit.PolicyDecisionType.RESPONSE) {
                var d = decision as WebKit.ResponsePolicyDecision;
                var mt = d.response.mime_type;
                if (mt == "text/markdown" || mt == "text/x-markdown") {
                    // TODO: Rework the reload() function
                    // to make this kind of hack unnecessary
                    try {
                        filename = Filename.from_uri(d.response.uri, null);
                        reload();
                    } catch (ConvertError e) {
                        stderr.printf("%s\n", e.message);
                    }
                } else {
                    var ctx = new AppLaunchContext();
                    try {
                        AppInfo.launch_default_for_uri(d.response.uri, ctx);
                    } catch (Error e) {
                        stderr.printf("%s\n", e.message);
                    }
                }
                decision.ignore();
                return false;
            }
            return true;
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

    internal void reload() {
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
        var text = read_file(file, true);
        if (text == null) {
            return;
        }
        var md = Markdown.parse(text);
        var body = md.render_html();
        var toc = md.render_html_toc();

        if (toc == null) {
            toc = "";
            // TODO: Also hide the #toc element
        }

        var basename = file.get_basename();
        var doc = document_template.printf(basename, stylesheet, toc, body);
        header.title = basename;
        header.subtitle = file.get_parent().get_path();
        webview.load_html(doc, file.get_uri());
    }

    void print() {
        stderr.puts("TODO\n");
    }
}

}
