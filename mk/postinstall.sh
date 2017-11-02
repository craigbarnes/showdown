#!/bin/sh

DESKTOPDIR="$1"
ICONDIR="$2"

if test -z "$DESTDIR"; then
    echo "Updating desktop database in $DESKTOPDIR"
    update-desktop-database -q "$DESKTOPDIR"

    echo "Updating icon cache in $ICONDIR"
    touch -c "$ICONDIR"
    gtk-update-icon-cache -qtf "$ICONDIR"
else
    echo 'DESTDIR is set; skipping post-install script'
fi

exit 0
