PREFIX  = /usr/local
BINDIR  = $(PREFIX)/bin
DATADIR = $(PREFIX)/share
APPDIR  = $(DATADIR)/applications
ICONDIR = $(DATADIR)/icons/hicolor/scalable/apps

install:
	install -Dpm0755 mdview $(DESTDIR)$(BINDIR)/mdview
	install -Dpm0644 mdview.svg $(DESTDIR)$(ICONDIR)/mdview.svg
	desktop-file-install --dir=$(DESTDIR)$(APPDIR) mdview.desktop

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/mdview
	rm -f $(DESTDIR)$(ICONDIR)/mdview.svg
	rm -f $(DESTDIR)$(APPDIR)/mdview.desktop

home-install:
	@$(MAKE) install PREFIX=$(HOME)/.local

# This should be done post-install/post-uninstall when packaging
# or immediately after a manual installation
updatedb:
	update-desktop-database $(APPDIR)

check:
	@desktop-file-validate mdview.desktop
	@echo 'Desktop file valid'


MAKEFLAGS += -Rr --no-print-directory
.PHONY: install uninstall home-install updatedb check
