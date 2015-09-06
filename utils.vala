namespace Showdown {

private string? read_file(File file, bool print_errors = false) {
    uint8[] text;
    bool ok = false;
    try {
        ok = file.load_contents(null, out text, null);
    } catch (Error e) {
        if (print_errors == true) {
            stderr.printf("Error: %s\n", e.message);
        }
    }
    return ok ? (string)text : null;
}

private Gtk.Image get_menu_icon(string name) {
    return new Gtk.Image.from_icon_name(name, Gtk.IconSize.MENU);
}

}
