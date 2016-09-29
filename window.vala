[GtkTemplate(ui = "/org/showdown/window.ui")]
class Showdown.Window: Gtk.ApplicationWindow {
    string? filename {get; set; default = null;}
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
        menu_button.menu_model = app.get_menu_by_id("header-menu");
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
        var dialog = new Gtk.FileChooserDialog (
            "Open", this, Gtk.FileChooserAction.OPEN,
            "_Cancel", Gtk.ResponseType.CANCEL,
            "_Open", Gtk.ResponseType.ACCEPT
        );

        if (filename != null) {
            dialog.set_filename(filename);
        } else {
            dialog.set_current_folder(Environment.get_current_dir());
        }

        var md = new Gtk.FileFilter();
        md.add_mime_type("text/markdown");
        md.add_mime_type("text/x-markdown");
        md.set_name("Markdown files");
        dialog.add_filter(md);

        var all = new Gtk.FileFilter();
        all.add_mime_type("text/*");
        all.set_name("All files");
        dialog.add_filter(all);

        if (dialog.run() == Gtk.ResponseType.ACCEPT) {
            load_file(dialog.get_filename());
        }

        dialog.destroy();
    }

    internal void reload() {
        if (filename == null) {
            return;
        }
        string text;
        try {
            FileUtils.get_contents(filename, out text);
        } catch (Error e) {
            show_error_page(e.message);
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

        var file = File.new_for_path(filename);
        var basename = file.get_basename();
        var doc = document_template.printf(basename, stylesheet, toc, body);
        header.title = basename;
        header.subtitle = file.get_parent().get_path();
        webview.load_html(doc, file.get_uri());
    }

    void show_error_page(string message) {
        header.title = "Markdown Viewer";
        header.subtitle = "";
        var html = error_template.printf(Markup.escape_text(message));
        webview.load_alternate_html(html, "about:blank", null);
    }

    internal void load_file(string filename) {
        this.filename = filename;
        reload();
    }

    void print() {
        var p = new WebKit.PrintOperation(webview);
        p.run_dialog(this);
    }
}
