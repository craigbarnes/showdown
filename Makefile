PREFIX = /usr/local
BINDIR = $(PREFIX)/bin
DTFDIR = $(PREFIX)/share/applications

install:
	install -Dpm0755 mdview $(DESTDIR)$(BINDIR)/mdview
	install -Dpm0644 mdview.desktop $(DESTDIR)$(DTFDIR)/mdview.desktop

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/mdview $(DESTDIR)$(DTFDIR)/mdview.desktop

home-install:
	@$(MAKE) --no-print-directory install PREFIX=~/.local


.PHONY: install uninstall home-install
