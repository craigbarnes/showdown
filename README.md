Showdown
======

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
* [ldiscount]
* [LGI]

You can then clone the repository and install with:

    git clone git://github.com/craigbarnes/showdown.git
    cd showdown
    sudo make install

History
-------

### 0.2

* Add a table of contents to the rendered output
* Use a temporary file, to make internal fragment links work correctly
* Improve template stylesheet
* Use [ldiscount] instead of Lunamark (faster, fewer dependencies
  more stable, supports generating table of contents)

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
[WebKitGTK]: http://webkitgtk.org/
[ldiscount]: https://github.com/craigbarnes/ldiscount
[LGI]: https://github.com/pavouk/lgi
[Lua]: http://lua.org/
[GTK]: http://www.gtk.org/
[LuaJIT]: http://luajit.org/
