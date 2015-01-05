Showdown
========

Showdown is a simple [Markdown] viewer written in [Lua] and [GTK]. It
converts Markdown into HTML, then presents it in a [WebKitGTK] view. So
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
* Automatic refresh when the source document is changed
* Integrated search bar

Screenshot
----------

![Showdown screenshot](http://cra.igbarn.es/img/showdown.png)

Requirements
------------

* [Lua] 5.1/5.2 or [LuaJIT] 2
* [lua-discount]
* [LGI]

**Note:** [lua-discount] is not to be confused with the unmaintained
module at <https://github.com/asb/lua-discount/>, which is not
compatible with Showdown.

Installation
------------

    git clone git://github.com/craigbarnes/showdown.git
    cd showdown
    [sudo] make install [PREFIX=<prefix>] [DESTDIR=<destdir>]

Usage
-----

### Keyboard commands:

Keys    | Command
--------|------------------------------------------------
Ctrl+f  | Open/close search bar
Ctrl+r  | Return to document (e.g. after clicking a link)
Ctrl+q  | Quit

History
-------

### Pending release

* Switch to new [lua-discount API]
* Set document/window title from [Pandoc-style header], if available
* Add a [GtkSearchBar]
* Allow opening files from within the app via a [GtkFileChooserDialog]
* Replace `key-press-event` handler with accelerator keys
* Improve default stylesheet
* Allow loading user stylesheet from `$XDG_CONFIG_HOME/showdown/stylesheet.css`
* Enable `DOCUMENT_VIEWER` cache model with `WebKitWebContext::set_cache_model`
* Disable JavaScript, plugins and page cache via `WebKitSettings`
* Process command-line arguments using `GApplication::command-line`
* Load document directly, instead of as temporary file (upstream bug
  necessitating this was fixed)

### 0.2

* Add a table of contents to the rendered output
* Use a temporary file, to make internal fragment links work correctly
* Improve template stylesheet
* Use [lua-discount] instead of Lunamark

### 0.1

* Converted to WebKit2 API
* Immediately reload document when edited (using GIO file monitoring)
* Add an application menu
* Add an application icon

Todo
----

* Allow installation via [LuaRocks]
* Keep scroll position after reloading
* Add support for drag and drop
* Add support for other compile-to-html languages and use
  `g_content_type_guess()` to determine how to render

License
-------

Copyright (C) 2012-2014 Craig Barnes

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU [General Public License version 3], as published
by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License version 3 for more details.


[General Public License version 3]: http://www.gnu.org/licenses/gpl-3.0.html
[Markdown]: https://en.wikipedia.org/wiki/Markdown
[Lua]: http://lua.org/
[LuaJIT]: http://luajit.org/
[LuaRocks]: http://luarocks.org/
[LGI]: https://github.com/pavouk/lgi
[GTK]: http://www.gtk.org/
[GtkSearchBar]: https://developer.gnome.org/gtk3/stable/GtkSearchBar.html
[GtkFileChooserDialog]: https://developer.gnome.org/gtk3/stable/GtkFileChooserDialog.html
[WebKitGTK]: http://webkitgtk.org/
[lua-discount]: https://github.com/craigbarnes/lua-discount
[lua-discount API]: https://github.com/craigbarnes/lua-discount#usage
[Pandoc-style header]: http://www.pell.portland.or.us/~orc/Code/discount/#headers
