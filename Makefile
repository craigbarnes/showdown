PREFIX = /usr/local
BINDIR = $(PREFIX)/bin
DTFDIR = $(PREFIX)/share/applications

install:
	install -Dpm0755 mdview $(DESTDIR)$(BINDIR)/mdview
	desktop-file-install --dir=$(DESTDIR)$(DTFDIR) mdview.desktop

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/mdview $(DESTDIR)$(DTFDIR)/mdview.desktop

home-install:
	@$(MAKE) install PREFIX=$(HOME)/.local

# This should be done post-install/post-uninstall when packaging
# or immediately after a manual installation
updatedb:
	update-desktop-database $(DTFDIR)

check:
	@desktop-file-validate mdview.desktop
	@echo 'Desktop file valid'


MAKEFLAGS += -Rr --no-print-directory
.PHONY: install uninstall home-install updatedb check
