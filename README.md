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

Features
--------

* Minimal interface -- launches faster than most web browsers and has no
  unrelated UI cutter.
* Extended styling -- the HTML output is rendered into a template with a
  GitHub-inspired stylesheet
* Automatic refresh -- the opened file is watched for changes and refreshed
  immediately when edited. You can have a text editor and Showdown side
  by side and preview the output as you save.

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

* Keep scroll position after reloading
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
