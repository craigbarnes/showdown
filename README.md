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

![Showdown screenshot](https://craigbarnes.github.io/img/showdown.png)

Requirements
------------

* [Vala] compiler
* [GNU Make] `>= 3.81`
* [cmark] `>= 0.21.0`
* [WebKit2GTK] `>= 2.8.4`

Installation
------------

    git clone git://github.com/craigbarnes/showdown.git
    cd showdown
    make
    sudo make install

If you're compiling and installing for personal use, also run the
following command to update the desktop file and icon caches:

    sudo make post-install

For packaging purposes, most distros have equivalent
post-install/post-uninstall macros that should be used instead.

Usage
-----

### Keyboard commands:

Keys    | Command
--------|------------------------------------------------
Ctrl+o  | Open file
Ctrl+f  | Show search bar
Ctrl+r  | Return to document (e.g. after clicking a link)
Ctrl+q  | Quit

License
-------

Copyright (C) 2015 Craig Barnes

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU [General Public License version 3], as published
by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License version 3 for more details.


[General Public License version 3]: http://www.gnu.org/licenses/gpl-3.0.html
[Markdown]: https://en.wikipedia.org/wiki/Markdown
[Vala]: https://wiki.gnome.org/Projects/Vala
[GTK]: http://www.gtk.org/
[GNU Make]: https://www.gnu.org/software/make/
[cmark]: https://github.com/jgm/cmark
[WebKit2GTK]: http://webkitgtk.org/
