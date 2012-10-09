mdview
======
Simple Markdown viewer

Rationale
---------

I wanted a way of quickly viewing Markdown files from the command-line
and got tired of constantly using:

    markdown somefile.md > tmp.html
    $BROWSER tmp.html
    rm tmp.html

So instead of using an alias or a Makefile like a sane person, I wrote a
small application in Lua and GTK. It converts Markdown to HTML (using
Lunamark) and loads it in a WebKitGTK view (using LGI).

Installation
------------

    luarocks install lunamark
    luarocks install lgi

    git clone git://github.com/craigbarnes/mdview.git
    cd mdview
    sudo make install

Usage
-----

    mdview FILE.md

Todo
----

* Refresh on change, for "real-time" previewing
* Better stylesheet

License
-------

ISC
