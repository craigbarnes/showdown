class Showdown.Application: Gtk.Application {
    internal string document_template;
    internal string error_template;
    internal string default_stylesheet;
    internal bool default_headerbar_visibility = true;

    const ActionEntry[] actions = {
        {"new_window", new_window},
        {"about", about},
        {"quit", quit},
    };

    const AccelEntry[] accels = {
        {"app.new_window", "<Primary>N"},
        {"app.quit", "<Primary>Q"},
        {"win.open", "<Primary>O"},
        {"win.close", "<Primary>W"},
        {"win.reload", "<Primary>R", "F5"},
        {"win.print", "<Primary>P"},
        {"win.toggle_searchbar", "<Primary>F"},
        {"win.toggle_headerbar", "F12"},
        {"win.zoom_in", "<Primary>plus", "<Primary>equal"},
        {"win.zoom_out", "<Primary>minus", "<Primary>dstroke"},
        {"win.zoom_reset", "<Primary>0"},
        {"win.show-help-overlay", "F1"},
    };

    static string? wflag = null;
    static bool hide_headerbar = false;
    const OptionEntry[] options = {
        {
            "open-in-current-window", 'w', OptionFlags.NONE,
            OptionArg.FILENAME, ref wflag,
            "Open file in existing window", "FILE"
        },
        {
            "hide-headerbar", 'B', OptionFlags.NONE,
            OptionArg.NONE, ref hide_headerbar,
            "Hide headerbar in all windows by default", null
        },
        {
            "version", 'V', OptionFlags.NO_ARG,
            OptionArg.CALLBACK, (void *)print_version_and_exit,
            "Print version number and exit", null
        },
        {null}
    };

    public Application() {
        Object (
            application_id: "io.gitlab.craigbarnes.Showdown",
            flags: ApplicationFlags.HANDLES_COMMAND_LINE
        );
        document_template = get_string_from_resource("template.html");
        error_template = get_string_from_resource("error.html");
        default_stylesheet = get_string_from_resource("main.css");
        unowned string config_dir = Environment.get_user_config_dir();
        var user_stylesheet_path = @"$config_dir/showdown/stylesheet.css";
        try {
            string user_stylesheet;
            FileUtils.get_contents(user_stylesheet_path, out user_stylesheet);
            default_stylesheet += user_stylesheet;
        } catch (Error e) {}
    }

    public override int command_line(ApplicationCommandLine cmdline) {
        hold();
        var cwd = cmdline.get_cwd();
        var args = cmdline.get_arguments();
        unowned string[] argv = args;
        var ctx = new OptionContext("[FILE…]");
        ctx.add_main_entries(options, null);
        ctx.add_group(Gtk.get_option_group(true));
        try {
            ctx.parse(ref argv);
        } catch (OptionError e) {
            stderr.printf("Failed to parse options: %s\n", e.message);
            Process.exit(1);
        }
        if (hide_headerbar) {
            default_headerbar_visibility = false;
        }
        if (wflag != null) {
            var file = File.new_for_commandline_arg_and_cwd(wflag, cwd);
            unowned List<Gtk.Window> windows = get_windows();
            if (windows.length() > 0) {
                unowned Showdown.Window w = windows.data as Showdown.Window;
                w.load_file(file.get_path());
            } else {
                var window = new Window(this);
                window.load_file(file.get_path());
                add_window(window);
            }
        } else {
            var window = new Window(this);
            if (argv.length >= 2) {
                var file = File.new_for_commandline_arg_and_cwd(argv[1], cwd);
                window.load_file(file.get_path());
            }
            add_window(window);
        }
        release();
        return 0;
    }

    void new_window() {
        add_window(new Window(this));
    }

    void about() {
        unowned List<Gtk.Window> windows = get_windows();
        Gtk.show_about_dialog (
            windows != null ? windows.data : null,
            "program-name", "Showdown",
            "version", Config.VERSION,
            "comments", "Simple Markdown viewer",
            "copyright", "Copyright 2015-2018 Craig Barnes",
            "logo-icon-name", "showdown",
            "license-type", Gtk.License.GPL_3_0,
            "website", "https://gitlab.com/craigbarnes/showdown"
        );
    }

    static void print_version_and_exit() {
        stdout.printf("showdown %s\n", Config.VERSION);
        Process.exit(0);
    }

    static string get_string_from_resource(string filename) {
        const string resprefix = "/io/gitlab/craigbarnes/Showdown/";
        const ResourceLookupFlags flags = ResourceLookupFlags.NONE;
        Bytes bytes;
        try {
            bytes = resources_lookup_data(resprefix + filename, flags);
        } catch (Error e) {
            error("%s\n", e.message);
        }
        return (string)bytes.get_data();
    }

    protected override void startup() {
        base.startup();
        Environment.set_application_name("Showdown");
        Gtk.Window.set_default_icon_name("showdown");
        add_action_entries(actions, this);
        foreach (var a in accels) {
            string? accel_strings[3] = {a.accel1, a.accel2, null};
            set_accels_for_action(a.action, accel_strings);
        }
        MarkdownView.load_user_script();
    }

    public static int main(string[] args) {
        var app = new Application();
        return app.run(args);
    }
}

struct Showdown.AccelEntry {
    string action;
    string accel1;
    string? accel2;
}
