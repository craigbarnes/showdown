using WebKit;

class Showdown.WebView: WebKit.WebView {
    const UserContentInjectedFrames FTOP = UserContentInjectedFrames.TOP_FRAME;
    const UserStyleLevel USER = UserStyleLevel.USER;
    Showdown.Window parent_window;

    public WebView(Showdown.Window window) {
        Object(user_content_manager: new UserContentManager());
        parent_window = window;
        visible = true;
        vexpand = true;
        hexpand = true;
        var settings = get_settings();
        settings.enable_javascript = false;
        settings.enable_plugins = false;
        settings.enable_page_cache = false;
        web_context.set_cache_model(WebKit.CacheModel.DOCUMENT_VIEWER);
        var app = parent_window.application as Showdown.Application;
        var usstext = app.user_stylesheet;
        if (usstext != null) {
            var uss = new UserStyleSheet(usstext, FTOP, USER, null, null);
            user_content_manager.add_style_sheet(uss);
        }
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
