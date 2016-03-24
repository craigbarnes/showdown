[GtkTemplate(ui = "/org/showdown/window.ui")]
class Showdown.Window: Gtk.ApplicationWindow {
    public string? filename = null;
    [GtkChild] Gtk.HeaderBar header;
    [GtkChild] Gtk.MenuButton menu_button;
    [GtkChild] Gtk.Grid grid;
    WebKit.WebView webview;

    const ActionEntry[] actions = {
        {"open", open},
        {"reload", reload},
        {"print", print},
        {"close", close},
        {"zoom_in", zoom_in},
        {"zoom_out", zoom_out},
        {"zoom_reset", zoom_reset},
    };

    public Window(Application app) {
        Object(application: app);
        add_action_entries(actions, this);
        menu_button.menu_model = get_menu_from_resource("header-menu");
        webview = new Showdown.WebView(this);
        grid.add(webview);
        show_all();
    }

    [GtkCallback]
    void search_entry_changed(Gtk.SearchEntry entry) {
        const WebKit.FindOptions WRAP = WebKit.FindOptions.WRAP_AROUND;
        const WebKit.FindOptions ICASE = WebKit.FindOptions.CASE_INSENSITIVE;
        webview.get_find_controller().search(entry.text, WRAP + ICASE, 5000);
    }

    [GtkCallback]
    void search_entry_activate() {
        webview.get_find_controller().search_next();
    }

    void zoom_in() {
        webview.zoom_level += 0.1;
    }

    void zoom_out() {
        if (webview.zoom_level > 1.1) {
            webview.zoom_level -= 0.1;
        } else {
            webview.zoom_level = 1;
        }
    }

    void zoom_reset() {
        webview.zoom_level = 1;
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
        var stylesheet = default_stylesheet;

        if (toc == null) {
            toc = "";
        } else {
            stylesheet += toc_stylesheet;
        }

        var basename = file.get_basename();
        var doc = document_template.printf(basename, stylesheet, toc, body);
        header.title = basename;
        header.subtitle = file.get_parent().get_path();
        webview.load_html(doc, file.get_uri());
    }

    void print() {
        var p = new WebKit.PrintOperation(webview);
        p.run_dialog(this);
    }
}
