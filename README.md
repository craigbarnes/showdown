Showdown
======

Showdown is a simple [Markdown] viewer. It renders Markdown as HTML (using
[Lunamark]) and loads it in a [WebKitGTK] view (using [LGI]), so instead of
doing this:

    markdown somefile.md > tmp.html
    $BROWSER tmp.html
    rm tmp.html

you can use:

    showdown somefile.md

While running, the open file is monitored, and any changes are quickly and
automatically reloaded.

Installation
------------

The following dependencies should be installed first:

* [Lua] 5.1/5.2 or [LuaJIT] 2
* [Lunamark]
* [LGI]

You can then clone the repository and install with:

    git clone git://github.com/craigbarnes/showdown.git
    cd showdown
    sudo make install

Todo
----

* Use WebKitFindController to allowing searching documents
* Allow opening/browsing directories

License
-------

[GNU GPL v3](http://www.gnu.org/licenses/gpl-3.0.html)


[Markdown]: http://daringfireball.net/projects/markdown/
[WebKitGTK]: http://webkitgtk.org/
[Lunamark]: http://jgm.github.com/lunamark/
[LGI]: https://github.com/pavouk/lgi
[Lua]: http://lua.org/
[LuaJIT]: http://luajit.org/
