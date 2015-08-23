[CCode(lower_case_cprefix = "cmark_", cheader_filename = "cmark.h")]
namespace CMark {
    [CCode(cname = "cmark_node_type", cprefix = "CMARK_NODE_")]
    public enum NodeType {
        NONE,
        // Block
        DOCUMENT,
        BLOCK_QUOTE,
        LIST,
        ITEM,
        CODE_BLOCK,
        HTML,
        PARAGRAPH,
        HEADER,
        HRULE,
        // Inline
        TEXT,
        SOFTBREAK,
        LINEBREAK,
        CODE,
        INLINE_HTML,
        EMPH,
        STRONG,
        LINK,
        IMAGE,
    }

    [Compact]
    [CCode(cname = "cmark_node", cprefix = "cmark_node_", free_function = "cmark_node_free")]
    public class Node {
        public NodeType get_type();

        [CCode(cname = "cmark_render_html")]
        public string render_html(int options = 0);

        internal string render_html_toc() {
            return "TODO: Table of Contents";
        }
    }

    public Node parse_document(char* buffer, size_t len, int options = 0);
}
