class Showdown.Application: Gtk.Application {
    internal string document_template;
    internal string error_template;
    internal string default_stylesheet;
    internal string toc_stylesheet;

    const ActionEntry[] actions = {
        {"new_window", new_window},
        {"about", about},
        {"quit", quit},
    };

    static string? wflag = null;
    const OptionEntry[] options = {
        {
            "open-in-current-window", 'w', 0,
            OptionArg.FILENAME, ref wflag,
            "Open file in existing window", "FILE"
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
        toc_stylesheet = get_string_from_resource("toc.css");
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
            if (args.length >= 2) {
                var file = File.new_for_commandline_arg_and_cwd(args[1], cwd);
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
        set_accels_for_action("app.new_window", {"<Primary>N"});
        set_accels_for_action("app.quit", {"<Primary>Q"});
        set_accels_for_action("win.reload", {"<Primary>R", "F5"});
        set_accels_for_action("win.print", {"<Primary>P"});
        set_accels_for_action("win.close", {"<Primary>W"});
        set_accels_for_action("win.zoom_in", {"<Primary>plus", "<Primary>equal"});
        set_accels_for_action("win.zoom_out", {"<Primary>minus", "<Primary>dstroke"});
        set_accels_for_action("win.zoom_reset", {"<Primary>0"});
        MarkdownView.load_user_assets();
    }

    public static int main(string[] args) {
        var app = new Application();
        return app.run(args);
    }
}
