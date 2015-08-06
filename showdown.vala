namespace Showdown {

class Window: Gtk.ApplicationWindow {
    public Window(Application app) {
        Object(application: app, title: "Showdown");

        var header = new Gtk.HeaderBar();
        header.show_close_button = true;
        header.set_title("Showdown");
        set_titlebar(header);

        var screen = Gdk.Screen.get_default();
        var height = screen.get_height() * 0.8;
        var width = screen.get_width() * 0.92;
        set_default_size((int)width, (int)height);

        var label = new Gtk.Label("TODO");
        add(label);
        set_border_width(20);

        show_all();
    }
}

class Application: Gtk.Application {
    public Application() {
        Object (
            application_id: "org.showdown",
            flags: 0 // ApplicationFlags.HANDLES_COMMAND_LINE
        );
    }

    void about() {
        unowned List<Gtk.Window> windows = get_windows();
        Gtk.show_about_dialog(windows != null ? windows.data : null,
            "program-name", "Showdown",
            "version", "0.1",
            "comments", "Simple Markdown viewer",
            "copyright", "Copyright 2015 Craig Barnes",
            "logo-icon-name", "showdown",
            "license-type", Gtk.License.GPL_3_0_ONLY,
            "website", "https://github.com/craigbarnes/showdown",
            "website-label", "https://github.com/craigbarnes/showdown"
        );
    }

    const ActionEntry[] actions = {
        {"about", about},
        {"quit", quit},
    };

    protected override void activate() {
        var window = new Window(this);
        add_window(window);
    }

    protected override void startup() {
        base.startup();
        add_action_entries(actions, this);

        var menu = new Menu();
        menu.append("About", "app.about");
        menu.append("Quit", "app.quit");
        menu.freeze();
        set_app_menu(menu);

        const string[] quit_accels = {"<Primary>Q", null};
        set_accels_for_action("app.quit", quit_accels);
        // TODO: Use the following (now deprecated) API for pre-3.12 GTK:
        // add_accelerator("<Primary>Q", "app.quit", null);
    }

    public static int main(string[] args) {
        var app = new Application();
        return app.run(args);
    }
}

}
