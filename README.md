Showdown
========

Showdown is a simple [Markdown] viewer written in [Vala] and [GTK]. It
converts Markdown into HTML, then presents it in a [WebKit2GTK] view. So
instead of doing this:

    markdown somefile.md > tmp.html
    $BROWSER tmp.html
    rm tmp.html

you can use:

    showdown somefile.md

Features
--------

* GitHub inspired default stylesheet.
* Table of contents navigation.
* Integrated search bar
* User styles (`~/.config/showdown/stylesheet.css`)
* User scripts (`~/.config/showdown/script.js`)

Screenshot
----------

![Showdown screenshot](https://craigbarnes.bitbucket.io/img/showdown.png)

Installing
----------

The easiest way to install Showdown is via [Flatpak] (0.8+), using the command:

    flatpak install https://craigbarnes.gitlab.io/showdown/showdown.flatpakref

Building
--------

To build Showdown from source, first install the following dependencies:

* [Vala]
* [GNU Make] (3.81+)
* [GTK] (3.20+)
* [GLib] (2.48+)
* [WebKit2GTK] (2.8.4+)
* [Discount] (2.1.7+)
* [xmllint] (*optional* -- used to shrink XML [resources], if available)

...which are available via package manager on most Linux distros:

    # Debian 8+/Ubuntu 15.04+:
    sudo apt-get -y install valac gcc make libgtk-3-dev libwebkit2gtk-4.0-dev libmarkdown2-dev libxml2-utils

    # Fedora 21+:
    sudo dnf -y install vala gcc make webkitgtk4-devel libmarkdown-devel libxml2

    # Arch Linux
    # (Compile and install Discount, either from source or via AUR)
    sudo pacman --needed -Sy vala gcc make webkitgtk libxml2

...then download and extract the latest release tarball:

    curl -LO https://craigbarnes.gitlab.io/dist/showdown/showdown-0.5.tar.gz
    tar -xzf showdown-0.5.tar.gz
    cd showdown-0.5/

...and compile and install:

    make && sudo make install

Packaging
---------

**Variables:**

The makefile supports most common packaging conventions, such as the
[`DESTDIR`] variable and various other [install path variables]:

Example usage:

    make V=1
    make install V=1 prefix=/usr DESTDIR=PKG

**Post-install commands:**

The makefile automatically [updates][POSTINSTALL] the system icon and
MIME type caches after installation, *unless* the `DESTDIR` variable is
set.

If `DESTDIR` is set, it is assumed that the installation is being used
for packaging purposes, in which case the packager should use the
equivalent, distro-provided macros/hooks instead. The icon and MIME
type caches should also be updated after *uninstallation*.

License
-------

Copyright (C) 2015-2017 Craig Barnes

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU [General Public License version 3], as published
by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License version 3 for more details.


[General Public License version 3]: https://www.gnu.org/licenses/gpl-3.0.html
[Markdown]: https://en.wikipedia.org/wiki/Markdown
[Vala]: https://wiki.gnome.org/Projects/Vala
[GTK]: https://www.gtk.org/
[GLib]: https://developer.gnome.org/glib/
[GNU Make]: https://www.gnu.org/software/make/
[Discount]: http://www.pell.portland.or.us/~orc/Code/discount/
[WebKit2GTK]: https://webkitgtk.org/
[Flatpak]: http://flatpak.org/
[xmllint]: http://xmlsoft.org/xmllint.html
[resources]: https://github.com/craigbarnes/showdown/blob/master/res/resources.xml
[`DESTDIR`]: https://www.gnu.org/prep/standards/html_node/DESTDIR.html
[install path variables]: https://github.com/craigbarnes/showdown/blob/master/GNUmakefile#L8-L14
[POSTINSTALL]: https://github.com/craigbarnes/showdown/blob/master/GNUmakefile#L19-L23
