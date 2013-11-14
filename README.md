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

...but now you get proper styling, a generated table of contents and
automatic document reloading.

Screenshot
----------

![Showdown screenshot](http://cra.igbarn.es/img/showdown.png)

Installation
------------

The following dependencies should be installed first:

* [Lua] 5.1/5.2 or [LuaJIT] 2
* [lua-discount]
* [LGI]

You can then clone the repository and install with:

    git clone git://github.com/craigbarnes/showdown.git
    cd showdown
    sudo make install

History
-------

### Pending release

* Switch to new [lua-discount API]
* Set document/window title from [Pandoc-style header], if available
* Enable `DOCUMENT_VIEWER` cache model via `WebKitWebContext`
* Disable JavaScript, plugins and page cache via `WebKitSettings`
* Process command-line arguments via `on_command_line` signal handler
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

* Keep scroll position after reloading
* Use WebKitFindController to allow searching documents
* Allow opening/browsing directories
* Add some way of opening files once running to allow launching without
  command-line arguments
* Add support for drag and drop
* Support other to-html languages and use `g_content_type_guess()` to
  decide how to render

License
-------

[GNU GPL v3](http://www.gnu.org/licenses/gpl-3.0.html)


[Markdown]: http://daringfireball.net/projects/markdown/
[Lua]: http://lua.org/
[LuaJIT]: http://luajit.org/
[LGI]: https://github.com/pavouk/lgi
[GTK]: http://www.gtk.org/
[WebKitGTK]: http://webkitgtk.org/
[lua-discount]: https://github.com/craigbarnes/lua-discount
[lua-discount API]: https://github.com/craigbarnes/lua-discount#usage
[Pandoc-style header]: http://www.pell.portland.or.us/~orc/Code/discount/#headers
