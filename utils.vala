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

private string get_string_from_resource(string filename) {
    Bytes bytes;
    try {
        bytes = resources_lookup_data("/org/showdown/" + filename, 0);
    } catch (Error e) {
        error(e.message);
    }
    return (string)bytes.get_data();
}

}
