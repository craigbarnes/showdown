namespace Showdown {

private string? user_stylesheet;

class Application: Gtk.Application {
    public Application() {
        Object (
            application_id: "org.showdown",
            flags: ApplicationFlags.HANDLES_COMMAND_LINE
        );
    }

    public override int command_line(ApplicationCommandLine cmdline) {
        hold();
        var window = new Window(this);
        var args = cmdline.get_arguments();
        if (args.length >= 2) {
            window.filename = args[1];
            window.reload();
        }
        add_window(window);
        release();
        return 0;
    }

    void new_window() {
        add_window(new Window(this));
    }

    void about() {
        unowned List<Gtk.Window> windows = get_windows();
        Gtk.show_about_dialog(windows != null ? windows.data : null,
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

        var section1 = new Menu();
        section1.append("New Window", "app.new_window");
        var section2 = new Menu();
        section2.append("About", "app.about");
        section2.append("Quit", "app.quit");
        var app_menu = new Menu();
        app_menu.append_section(null, section1);
        app_menu.append_section(null, section2);
        app_menu.freeze();
        set_app_menu(app_menu);

        #if HAVE_PRE_3_12_GTK
            add_accelerator("<Primary>N", "app.new_window", null);
            add_accelerator("<Primary>Q", "app.quit", null);
        #else
            const string[] new_window_accels = {"<Primary>N", null};
            const string[] quit_accels = {"<Primary>Q", null};
            set_accels_for_action("app.new_window", new_window_accels);
            set_accels_for_action("app.quit", quit_accels);
        #endif
        var config_dir = GLib.Environment.get_user_config_dir();
        var style_path = config_dir + "/showdown/stylesheet.css";
        var style_file = File.new_for_path(style_path);
        user_stylesheet = read_file(style_file);
    }

    public static int main(string[] args) {
        var app = new Application();
        return app.run(args);
    }
}

}
