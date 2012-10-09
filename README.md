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

So instead of making a shell alias like a sane person, I wrote an application
using Lua and GTK. It converts Markdown to HTML (using Lunamark) and loads
it in a GtkWebView (using LGI).

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

License
-------

ISC
