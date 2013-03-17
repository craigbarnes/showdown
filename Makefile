VERSION = 0.1
PREFIX  = /usr/local
BINDIR  = $(PREFIX)/bin
DATADIR = $(PREFIX)/share
APPDIR  = $(DATADIR)/applications
ICONDIR = $(DATADIR)/icons/hicolor/scalable/apps

install:
	install -Dpm0755 mdview $(DESTDIR)$(BINDIR)/mdview
	install -Dpm0644 mdview.svg $(DESTDIR)$(ICONDIR)/mdview.svg
	desktop-file-install --dir=$(DESTDIR)$(APPDIR) mdview.desktop

post-install:
	update-desktop-database $(APPDIR)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/mdview
	rm -f $(DESTDIR)$(ICONDIR)/mdview.svg
	rm -f $(DESTDIR)$(APPDIR)/mdview.desktop

check:
	@desktop-file-validate mdview.desktop
	@echo 'Desktop file valid'

install-home:
	@$(MAKE) install updatedb PREFIX=$(HOME)/.local


MAKEFLAGS += -Rr --no-print-directory
.PHONY: install post-install uninstall check install-home
