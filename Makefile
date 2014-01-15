PREFIX     = /usr/local
BINDIR     = $(PREFIX)/bin
DATADIR    = $(PREFIX)/share
DESKTOPDIR = $(DATADIR)/applications
ICONDIR    = $(DATADIR)/icons/hicolor
APPICONDIR = $(ICONDIR)/scalable/apps

help:
	@echo "Usage:"
	@echo "   make install         Install under $(PREFIX)"
	@echo "   make install-home    Install under $(HOME)/.local"
	@echo "   make post-install    Update desktop database and icon cache"
	@echo "   make check           Check validity of .desktop file"

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


.PHONY: help install install-home uninstall post-install post-uninstall check
