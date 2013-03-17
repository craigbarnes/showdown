VERSION  = 0.1

PREFIX   = /usr/local
BINDIR   = $(PREFIX)/bin
DATADIR  = $(PREFIX)/share
APPDIR   = $(DATADIR)/applications
ICONDIR  = $(DATADIR)/icons/hicolor/scalable/apps

SRCROCK  = mdview-$(VERSION)-1.src.rock
ROCKSPEC = mdview-$(VERSION)-1.rockspec

install:
	install -Dpm0755 mdview $(DESTDIR)$(BINDIR)/mdview
	install -Dpm0644 mdview.svg $(DESTDIR)$(ICONDIR)/mdview.svg
	desktop-file-install --dir=$(DESTDIR)$(APPDIR) mdview.desktop

install-home:
	@$(MAKE) install post-install PREFIX=$(HOME)/.local

post-install:
	update-desktop-database $(APPDIR)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/mdview
	rm -f $(DESTDIR)$(ICONDIR)/mdview.svg
	rm -f $(DESTDIR)$(APPDIR)/mdview.desktop

rock: $(SRCROCK)
rockspec: $(ROCKSPEC)

$(SRCROCK): $(ROCKSPEC)
	luarocks pack $<

$(ROCKSPEC): rockspec.in
	@sed 's/@VERSION@/$(VERSION)/g; s/@RELEASE@/1/g' $< > $@
	@echo 'Generated: $@'

check: $(ROCKSPEC)
	@desktop-file-validate mdview.desktop && echo 'Desktop file valid'
	@luarocks lint $(ROCKSPEC) && echo 'Rockspec file valid'

clean:
	rm -f $(SRCROCK) $(ROCKSPEC)


MAKEFLAGS += --no-print-directory
.PHONY: install install-home post-install uninstall rock rockspec check clean
