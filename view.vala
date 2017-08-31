using WebKit;

class Showdown.MarkdownView: WebKit.WebView {
    static UserStyleSheet? user_stylesheet = null;
    static UserScript? user_script = null;
    Showdown.Window parent_window;

    public MarkdownView(Showdown.Window window) {
        Object(user_content_manager: new UserContentManager());
        parent_window = window;
        visible = true;
        vexpand = true;
        hexpand = true;
        var settings = get_settings();
        settings.enable_plugins = false;
        settings.enable_page_cache = false;
        web_context.set_cache_model(WebKit.CacheModel.DOCUMENT_VIEWER);
        if (user_stylesheet != null) {
            user_content_manager.add_style_sheet(user_stylesheet);
        }
        if (user_script != null) {
            settings.enable_javascript = true;
            user_content_manager.add_script(user_script);
        } else {
            settings.enable_javascript = false;
        }
    }

    internal static void load_user_assets() {
        const UserContentInjectedFrames FTOP = UserContentInjectedFrames.TOP_FRAME;
        const UserScriptInjectionTime ISTART = UserScriptInjectionTime.START;
        const UserStyleLevel USER = UserStyleLevel.USER;
        unowned string config_dir = Environment.get_user_config_dir();
        var user_stylesheet_path = @"$config_dir/showdown/stylesheet.css";
        var user_script_path = @"$config_dir/showdown/script.js";
        try {
            string text;
            FileUtils.get_contents(user_stylesheet_path, out text);
            user_stylesheet = new UserStyleSheet(text, FTOP, USER, null, null);
        } catch (Error e) {}
        try {
            string text;
            FileUtils.get_contents(user_script_path, out text);
            user_script = new UserScript(text, FTOP, ISTART, {"file://*"}, null);
        } catch (Error e) {}
    }

    protected override bool context_menu (
        ContextMenu context_menu,
        Gdk.Event event,
        HitTestResult hit_test_result
    ) {
        return true; // Prevent context menu being shown
    }

    protected override bool decide_policy (
        PolicyDecision decision,
        PolicyDecisionType type
    ) {
        if (type == PolicyDecisionType.RESPONSE) {
            var d = decision as ResponsePolicyDecision;
            var mt = d.response.mime_type;
            if (mt == "text/markdown" || mt == "text/x-markdown") {
                try {
                    var filename = Filename.from_uri(d.response.uri, null);
                    parent_window.load_file(filename);
                } catch (ConvertError e) {
                    stderr.printf("%s\n", e.message);
                }
            } else {
                var ctx = new AppLaunchContext();
                try {
                    AppInfo.launch_default_for_uri(d.response.uri, ctx);
                } catch (Error e) {
                    stderr.printf("%s\n", e.message);
                }
            }
            decision.ignore();
            return false;
        }
        return true;
    }
}
