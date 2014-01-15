PREFIX     = /usr/local
BINDIR     = $(PREFIX)/bin
DATADIR    = $(PREFIX)/share
DESKTOPDIR = $(DATADIR)/applications
ICONDIR    = $(DATADIR)/icons/hicolor
APPICONDIR = $(ICONDIR)/scalable/apps

all: showdown

showdown: showdown.lua compile.sed gh.css
	sed -f compile.sed showdown.lua > $@
	chmod +x $@

install: all
	mkdir -p $(DESTDIR)$(BINDIR) $(DESTDIR)$(APPICONDIR)
	install -p -m 0755 showdown $(DESTDIR)$(BINDIR)/showdown
	install -p -m 0644 showdown.svg $(DESTDIR)$(APPICONDIR)/showdown.svg
	desktop-file-install --dir=$(DESTDIR)$(DESKTOPDIR) showdown.desktop

install-home:
	@$(MAKE) all install post-install PREFIX=$(HOME)/.local

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/showdown
	rm -f $(DESTDIR)$(APPICONDIR)/showdown.svg
	rm -f $(DESTDIR)$(DESKTOPDIR)/showdown.desktop

post-install post-uninstall:
	update-desktop-database $(DESKTOPDIR)
	touch -c $(ICONDIR)
	gtk-update-icon-cache -t $(ICONDIR)

clean:
	$(RM) showdown

check:
	@desktop-file-validate showdown.desktop && echo 'Desktop file valid'


.PHONY: all install install-home uninstall post-install post-uninstall
.PHONY: clean check
.DELETE_ON_ERROR:
