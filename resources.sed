/^$TEMPLATE/ {
    r template.html
    d
}

/^$ERROR_TEMPLATE/ {
    r error.html
    d
}

/^$STYLESHEET/ {
    r gh.css
    d
}

/^$TOC_STYLESHEET/ {
    r toc.css
    d
}
