VERSION    = 0.2

PREFIX     = /usr/local
BINDIR     = $(PREFIX)/bin
DATADIR    = $(PREFIX)/share
DESKTOPDIR = $(DATADIR)/applications
ICONDIR    = $(DATADIR)/icons/hicolor
APPICONDIR = $(ICONDIR)/scalable/apps

install:
	install -Dpm0755 showdown.lua $(DESTDIR)$(BINDIR)/showdown
	install -Dpm0644 showdown.svg $(DESTDIR)$(APPICONDIR)/showdown.svg
	desktop-file-install --dir=$(DESTDIR)$(DESKTOPDIR) showdown.desktop

install-home:
	@$(MAKE) install post-install PREFIX=$(HOME)/.local

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/showdown
	rm -f $(DESTDIR)$(APPICONDIR)/showdown.svg
	rm -f $(DESTDIR)$(DESKTOPDIR)/showdown.desktop

post-install post-uninstall:
	update-desktop-database $(DESKTOPDIR)
	touch --no-create $(ICONDIR)
	gtk-update-icon-cache -t $(ICONDIR)

check:
	@desktop-file-validate showdown.desktop && echo 'Desktop file valid'


.PHONY: install install-home uninstall post-install post-uninstall check
