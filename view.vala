using WebKit;

class Showdown.WebView: WebKit.WebView {
    Showdown.Window parent_window;

    public WebView(Showdown.Window window) {
        Object(user_content_manager: new UserContentManager());
        parent_window = window;
        vexpand = true;
        hexpand = true;
        var settings = get_settings();
        settings.enable_javascript = false;
        settings.enable_plugins = false;
        settings.enable_page_cache = false;
        web_context.set_cache_model(WebKit.CacheModel.DOCUMENT_VIEWER);
        var app = parent_window.application as Showdown.Application;
        if (app.user_stylesheet != null) {
            user_content_manager.add_style_sheet(new UserStyleSheet (
                app.user_stylesheet,
                UserContentInjectedFrames.TOP_FRAME,
                UserStyleLevel.USER,
                null, // whitelist
                null // blacklist
            ));
        }
    }

    protected override bool decide_policy (
        PolicyDecision decision,
        PolicyDecisionType type
    ) {
        if (type == PolicyDecisionType.RESPONSE) {
            var d = decision as ResponsePolicyDecision;
            var mt = d.response.mime_type;
            if (mt == "text/markdown" || mt == "text/x-markdown") {
                // TODO: Rework the reload() function
                // to make this kind of hack unnecessary
                try {
                    var filename = Filename.from_uri(d.response.uri, null);
                    parent_window.filename = filename;
                    parent_window.reload();
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
