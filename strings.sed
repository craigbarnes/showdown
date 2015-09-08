/^$DOCUMENT_TEMPLATE/ {
    r template.html
    d
}

/^$ERROR_TEMPLATE/ {
    r error.html
    d
}

/^$MAIN_STYLESHEET/ {
    r main.css
    d
}

/^$TOC_STYLESHEET/ {
    r toc.css
    d
}
