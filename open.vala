namespace Showdown {

public class OpenDialog: Gtk.FileChooserDialog {
    const Gtk.ResponseType ACCEPT = Gtk.ResponseType.ACCEPT;
    const Gtk.ResponseType CANCEL = Gtk.ResponseType.CANCEL;

    public OpenDialog(Gtk.ApplicationWindow parent_window, string? filename) {
        title = "Open";
        action = Gtk.FileChooserAction.OPEN;
        transient_for = parent_window;

        add_button("_Cancel", CANCEL);
        add_button("_Open", ACCEPT);
        set_default_response(ACCEPT);

        if (filename != null) {
            set_filename(filename);
        } else {
            set_current_folder(Environment.get_current_dir());
        }

        var md = new Gtk.FileFilter();
        md.add_mime_type("text/x-markdown");
        md.set_name("Markdown files");
        add_filter(md);

        var all = new Gtk.FileFilter();
        all.add_mime_type("text/*");
        all.set_name("All files");
        add_filter(all);
    }
}

}
