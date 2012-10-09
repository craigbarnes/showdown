PREFIX = /usr/local
BINDIR = $(PREFIX)/bin

install:
	install -Dpm0755 mdview $(DESTDIR)$(BINDIR)/mdview

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/mdview

home-install:
	@$(MAKE) --no-print-directory install PREFIX=~/.local


.PHONY: install uninstall home-install
