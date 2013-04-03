VERSION    = 0.2

PREFIX     = /usr/local
BINDIR     = $(PREFIX)/bin
DATADIR    = $(PREFIX)/share
DESKTOPDIR = $(DATADIR)/applications
ICONDIR    = $(DATADIR)/icons/hicolor
APPICONDIR = $(ICONDIR)/scalable/apps

SRCROCK    = showdown-$(VERSION)-1.src.rock
ROCKSPEC   = showdown-$(VERSION)-1.rockspec

install:
	install -Dpm0755 showdown $(DESTDIR)$(BINDIR)/showdown
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

rock: $(SRCROCK)
rockspec: $(ROCKSPEC)

$(SRCROCK): $(ROCKSPEC)
	luarocks pack $(ROCKSPEC)

$(ROCKSPEC): rockspec.in
	@sed 's/@VERSION@/$(VERSION)/g; s/@RELEASE@/1/g' rockspec.in > $@
	@echo 'Generated: $@'

check: $(ROCKSPEC)
	@desktop-file-validate showdown.desktop && echo 'Desktop file valid'
	@luarocks lint $(ROCKSPEC) && echo 'Rockspec file valid'

clean:
	rm -f $(SRCROCK) $(ROCKSPEC)


MAKEFLAGS += --no-print-directory
.PHONY: install install-home uninstall post-install post-uninstall \
        rock rockspec check clean
