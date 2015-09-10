-include local.mk

PREFIX     = /usr/local
BINDIR     = $(PREFIX)/bin
DATADIR    = $(PREFIX)/share
DESKTOPDIR = $(DATADIR)/applications
ICONDIR    = $(DATADIR)/icons/hicolor
APPICONDIR = $(ICONDIR)/scalable/apps
VERSION    = $(or $(shell git describe --abbrev=0),$(error No version info))

VALAFLAGS  = -X '-lmarkdown' -X '-Wno-incompatible-pointer-types'
VALAFLAGS += --target-glib=2.42 --gresources=res/resources.xml
VALAPKGS   = --pkg gtk+-3.0 --pkg webkit2gtk-4.0 --vapidir . --pkg libmarkdown
VALAFILES  = $(addsuffix .vala, showdown window view open utils)
RESCOMPILE = glib-compile-resources --sourcedir res/
RESOURCES  = $(shell $(RESCOMPILE) --generate-dependencies res/resources.xml)

all: showdown

showdown: $(VALAFILES) resources.c libmarkdown.vapi
	valac $(VALAFLAGS) $(VALAPKGS) -o $@ $(VALAFILES) resources.c

resources.c: res/resources.xml $(RESOURCES)
	$(RESCOMPILE) --generate-source --target $@ $<

showdown-%.tar.gz:
	@git archive --prefix=showdown-$*/ -o $@ $*
	@echo 'Generated: $@'

install: all
	mkdir -p $(DESTDIR)$(BINDIR) $(DESTDIR)$(APPICONDIR)
	install -p -m 0755 showdown $(DESTDIR)$(BINDIR)/showdown
	install -p -m 0644 showdown.svg $(DESTDIR)$(APPICONDIR)/showdown.svg
	desktop-file-install --dir=$(DESTDIR)$(DESKTOPDIR) showdown.desktop

install-home:
	@$(MAKE) all install post-install PREFIX=$(HOME)/.local

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/showdown
	rm -f $(DESTDIR)$(APPICONDIR)/showdown.svg
	rm -f $(DESTDIR)$(DESKTOPDIR)/showdown.desktop

post-install post-uninstall:
	update-desktop-database $(DESKTOPDIR)
	touch -c $(ICONDIR)
	gtk-update-icon-cache -t $(ICONDIR)

dist:
	@$(MAKE) --no-print-directory showdown-$(VERSION).tar.gz

clean:
	$(RM) showdown resources.c *.vala.c showdown-*.tar.gz

check:
	@desktop-file-validate showdown.desktop && echo 'Desktop file valid'


.PHONY: all install install-home uninstall post-install post-uninstall
.PHONY: dist clean check
.DELETE_ON_ERROR:
