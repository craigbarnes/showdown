VERSION  = 0.1

PREFIX   = /usr/local
BINDIR   = $(PREFIX)/bin
DATADIR  = $(PREFIX)/share
APPDIR   = $(DATADIR)/applications
ICONDIR  = $(DATADIR)/icons/hicolor/scalable/apps

SRCROCK  = showdown-$(VERSION)-1.src.rock
ROCKSPEC = showdown-$(VERSION)-1.rockspec

install:
	install -Dpm0755 showdown $(DESTDIR)$(BINDIR)/showdown
	install -Dpm0644 showdown.svg $(DESTDIR)$(ICONDIR)/showdown.svg
	desktop-file-install --dir=$(DESTDIR)$(APPDIR) showdown.desktop

install-home:
	@$(MAKE) install post-install PREFIX=$(HOME)/.local

post-install:
	update-desktop-database $(APPDIR)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/showdown
	rm -f $(DESTDIR)$(ICONDIR)/showdown.svg
	rm -f $(DESTDIR)$(APPDIR)/showdown.desktop

rock: $(SRCROCK)
rockspec: $(ROCKSPEC)

$(SRCROCK): $(ROCKSPEC)
	luarocks pack $<

$(ROCKSPEC): rockspec.in
	@sed 's/@VERSION@/$(VERSION)/g; s/@RELEASE@/1/g' $< > $@
	@echo 'Generated: $@'

check: $(ROCKSPEC)
	@desktop-file-validate showdown.desktop && echo 'Desktop file valid'
	@luarocks lint $(ROCKSPEC) && echo 'Rockspec file valid'

clean:
	rm -f $(SRCROCK) $(ROCKSPEC)


MAKEFLAGS += --no-print-directory
.PHONY: install install-home post-install uninstall rock rockspec check clean
