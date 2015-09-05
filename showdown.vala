namespace Showdown {

private string stylesheet;

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
        {"about", about},
        {"quit", quit},
    };

    protected override void startup() {
        base.startup();
        add_action_entries(actions, this);

        var menu = new Menu();
        menu.append("About", "app.about");
        menu.append("Quit", "app.quit");
        menu.freeze();
        set_app_menu(menu);

        #if HAVE_PRE_3_12_GTK
            add_accelerator("<Primary>Q", "app.quit", null);
        #else
            const string[] quit_accels = {"<Primary>Q", null};
            set_accels_for_action("app.quit", quit_accels);
        #endif

        var config_dir = GLib.Environment.get_user_config_dir();
        var style_path = config_dir + "/showdown/stylesheet.css";
        var style_file = File.new_for_path(style_path);
        try {
            uint8[] text;
            if (style_file.load_contents(null, out text, null)) {
                stylesheet = (string)text;
            } else {
                stylesheet = default_stylesheet;
            }
        } catch (Error e) {
            stylesheet = default_stylesheet;
        }
    }

    public static int main(string[] args) {
        var app = new Application();
        return app.run(args);
    }
}

}
