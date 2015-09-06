[CCode(cheader_filename = "mkdio.h")]
namespace Markdown {
    [Compact]
    [CCode(cname = "MMIOT", cprefix = "mkd_", free_function = "mkd_cleanup")]
    public class Document {
        internal int compile(int flags);
        private int document(out char **text);
        private int toc(out char **text);

        public string render_html() {
            char **html;
            int size = this.document(out html);
            return (string)html;
        }

        public string? render_html_toc() {
            char **html;
            int size = this.toc(out html);
            return html != null ? (string)html : null;
        }
    }

    [CCode(cname = "mkd_string")]
    private Document _parse(char *bfr, int size, int flags);

    public Document parse(string text, int flags = 0x00001000) {
        var document = _parse(text, text.length, flags);
        document.compile(flags);
        return document;
    }
}
