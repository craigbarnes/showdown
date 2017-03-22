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

Installation
------------

The easiest way to install Showdown is via [Flatpak] (0.8+), using the command:

    flatpak install https://craigbarnes.gitlab.io/showdown/showdown.flatpakref

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
