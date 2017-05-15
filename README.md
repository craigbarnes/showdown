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

* Uses a GitHub-inspired stylesheet by default
* Supports custom user stylesheets
* Generates a hierarchical table of contents from the document outline
* Integrated search bar

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

...which are available via package manager on most distros:

    # Debian 8+/Ubuntu 15.04+:
    sudo apt-get -y install valac gcc make libgtk-3-dev libwebkit2gtk-4.0-dev libmarkdown2-dev

    # Fedora 21+:
    sudo dnf -y install vala gcc make webkitgtk4-devel libmarkdown-devel

    # Arch Linux
    # (Compile and install Discount, either from source or via AUR)
    sudo pacman --needed -Sy vala gcc make webkitgtk

...then download and extract the latest release tarball:

    wget https://craigbarnes.gitlab.io/showdown/dist/showdown-0.5.tar.gz
    tar xzf showdown-0.5.tar.gz
    cd showdown-0.5/

...and compile and install:

    make && sudo make install

Packaging
---------

**Variables:**

The Makefile supports most common packaging conventions, such as the
[`DESTDIR`] variable and various other install path variables.

For packaging, usually only `DESTDIR` and `PREFIX` will need to be
changed. For example:

    make
    make install DESTDIR=./buildroot PREFIX=/usr

**Post-install commands:**

The `Makefile` automatically updates the system icon and MIME type
caches after installation, *unless* the `DESTDIR` variable is set.

If `DESTDIR` is set, it is assumed that the installation is being used
for packaging purposes, in which case the packager should use the
equivalent, distro-provided macros/hooks instead. The icon and MIME
type caches should also be updated after *uninstallation*.

License
-------

Copyright (C) 2015-2016 Craig Barnes

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
[GTK]: http://www.gtk.org/
[GLib]: https://developer.gnome.org/glib/
[GNU Make]: https://www.gnu.org/software/make/
[Discount]: http://www.pell.portland.or.us/~orc/Code/discount/
[WebKit2GTK]: https://webkitgtk.org/
[Flatpak]: http://flatpak.org/
[`DESTDIR`]: https://www.gnu.org/prep/standards/html_node/DESTDIR.html
