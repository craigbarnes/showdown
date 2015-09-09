class Showdown.Application: Gtk.Application {
    internal string? user_stylesheet = null;
    private static string? wflag = null;
    public static const OptionEntry[] options = {
        {
            "open-in-current-window",
            'w',
            0,
            OptionArg.FILENAME,
            ref wflag,
            "Open file in currently focused window",
            null
        },
        {null}
    };

    public Application() {
        Object (
            application_id: "org.showdown",
            flags: ApplicationFlags.HANDLES_COMMAND_LINE
        );
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
                w.filename = file.get_path();
                w.reload();
            } else {
                var window = new Window(this);
                window.filename = file.get_path();
                window.reload();
                add_window(window);
            }
        } else {
            var window = new Window(this);
            if (args.length >= 2) {
                var file = File.new_for_commandline_arg_and_cwd(args[1], cwd);
                window.filename = file.get_path();
                window.reload();
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
            "version", "0.4",
            "comments", "Simple Markdown viewer",
            "copyright", "Copyright 2015 Craig Barnes",
            "logo-icon-name", "showdown",
            "license-type", Gtk.License.GPL_3_0,
            "website", "https://github.com/craigbarnes/showdown"
        );
    }

    const ActionEntry[] actions = {
        {"new_window", new_window},
        {"about", about},
        {"quit", quit},
    };

    protected override void startup() {
        base.startup();
        add_action_entries(actions, this);
        set_accels_for_action("app.new_window", {"<Primary>N"});
        set_accels_for_action("app.quit", {"<Primary>Q"});
        set_accels_for_action("win.open", {"<Primary>O"});
        set_accels_for_action("win.reload", {"<Primary>R", "F5"});
        set_accels_for_action("win.print", {"<Primary>P"});
        set_accels_for_action("win.close", {"<Primary>W"});
        app_menu = get_menu_from_resource("app-menu");
        try {
            FileUtils.get_contents (
                Environment.get_user_config_dir() + "/showdown/stylesheet.css",
                out user_stylesheet
            );
        } catch (FileError e) {
            user_stylesheet = null;
        }
    }

    public static int main(string[] args) {
        var app = new Application();
        return app.run(args);
    }
}
