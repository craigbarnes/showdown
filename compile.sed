/^$TEMPLATE/ {
    r template.html
    d
}

/^$STYLESHEET/ {
    r gh.css
    d
}

