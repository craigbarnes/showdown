[GtkTemplate(ui = "/io/gitlab/craigbarnes/Showdown/window.ui")]
class Showdown.Window: Gtk.ApplicationWindow {
    string? filename = null;
    [GtkChild] Gtk.HeaderBar header;
    [GtkChild] Gtk.MenuButton menu_button;
    [GtkChild] Gtk.Grid grid;
    MarkdownView mdview;

    const ActionEntry[] actions = {
        {"open", open},
        {"reload", reload},
        {"print", print},
        {"close", close},
        {"zoom_in", zoom_in},
        {"zoom_out", zoom_out},
        {"zoom_reset", zoom_reset},
    };

    Showdown.Application app {
        get {
            return application as Showdown.Application;
        }
    }

    public Window(Gtk.Application application) {
        Object(application: application);
        add_action_entries(actions, this);
        menu_button.menu_model = application.get_menu_by_id("header-menu");
        mdview = new Showdown.MarkdownView(this);
        grid.add(mdview);
        show();
    }

    [GtkCallback]
    void search_entry_changed(Gtk.SearchEntry entry) {
        const WebKit.FindOptions WRAP = WebKit.FindOptions.WRAP_AROUND;
        const WebKit.FindOptions ICASE = WebKit.FindOptions.CASE_INSENSITIVE;
        mdview.get_find_controller().search(entry.text, WRAP + ICASE, 5000);
    }

    [GtkCallback]
    void search_entry_activate() {
        mdview.get_find_controller().search_next();
    }

    void zoom_in() {
        mdview.zoom_level += 0.1;
    }

    void zoom_out() {
        if (mdview.zoom_level > 1.1) {
            mdview.zoom_level -= 0.1;
        } else {
            mdview.zoom_level = 1;
        }
    }

    void zoom_reset() {
        mdview.zoom_level = 1;
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

        dialog.response.connect((response_id) => {
            if (response_id == Gtk.ResponseType.ACCEPT) {
                load_file(dialog.get_filename());
            }
            dialog.destroy();
        });

        dialog.show();
    }

    void reload() {
        if (filename == null) {
            return;
        }
        var file = File.new_for_path(filename);
        uint8[] text;
        try {
            file.load_contents(null, out text, null);
        } catch (Error e) {
            show_error_page(e.message);
            return;
        }

        var md = Markdown.parse(text);
        var body = md.render_html();
        var toc = md.render_html_toc();
        var stylesheet = app.default_stylesheet;
        var body_class = "";

        if (toc == null) {
            toc = "";
        } else {
            body_class = "toc";
        }

        var template = app.document_template;
        var basename = file.get_basename();
        var doc = template.printf(basename, stylesheet, body_class, toc, body);
        header.title = basename;
        header.subtitle = file.get_parent().get_path();
        mdview.load_html(doc, file.get_uri());
    }

    void show_error_page(string message) {
        header.title = "Markdown Viewer";
        header.subtitle = "";
        var html = app.error_template.printf(Markup.escape_text(message));
        mdview.load_alternate_html(html, "about:blank", null);
    }

    internal void load_file(string filename) {
        this.filename = filename;
        reload();
    }

    void print() {
        var p = new WebKit.PrintOperation(mdview);
        p.run_dialog(this);
    }
}
