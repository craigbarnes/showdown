mdview
======

mdview is a simple [Markdown] previewer. It renders Markdown as HTML (using
[Lunamark]) and loads it in a [WebKitGTK] view (using [LGI]), so instead of
doing this:

    markdown somefile.md > tmp.html
    $BROWSER tmp.html
    rm tmp.html

you can use:

    mdview somefile.md

The interface is very minimal, since it's only intended purpose is to
preview Markdown files from the command line as quickly as possible.

If you follow an external link, you can return to the original file by
pressing Backspace.

Installation
------------

The following dependencies should be installed first:

* [Lua] 5.1/5.2 or [LuaJIT] 2
* [Lunamark]
* [LGI]

You can then clone the repository and install with:

    git clone git://github.com/craigbarnes/mdview.git
    cd mdview
    sudo make install

Todo
----

* Refresh on change, for "real-time" previewing
* Allow opening/browsing directories
* Add rockspec

License
-------

[GNU GPL v3](http://www.gnu.org/licenses/gpl-3.0.html)


[Markdown]: http://daringfireball.net/projects/markdown/
[WebKitGTK]: http://webkitgtk.org/
[Lunamark]: http://jgm.github.com/lunamark/
[LGI]: https://github.com/pavouk/lgi
[Lua]: http://lua.org/
[LuaJIT]: http://luajit.org/
