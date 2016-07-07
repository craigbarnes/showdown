-include local.mk

PREFIX     = /usr/local
BINDIR     = $(PREFIX)/bin
DATADIR    = $(PREFIX)/share
DESKTOPDIR = $(DATADIR)/applications
ICONDIR    = $(DATADIR)/icons/hicolor
APPICONDIR = $(ICONDIR)/scalable/apps
VERSION    = $(or $(shell git describe --abbrev=0),$(error No version info))

VALAFLAGS  = -X '-Wno-incompatible-pointer-types' -X '-Wno-discarded-qualifiers'
VALAFLAGS += -X '-lmarkdown' --target-glib=2.48 --gresources=res/resources.xml
VALAPKGS   = --pkg gtk+-3.0 --pkg webkit2gtk-4.0 --vapidir . --pkg libmarkdown
VALAFILES  = $(addsuffix .vala, showdown window view utils)
RESCOMPILE = glib-compile-resources --sourcedir res/
RESOURCES  = $(shell $(RESCOMPILE) --generate-dependencies res/resources.xml)

define POST-INSTALL-MESSAGE
\n Installed to: $(DESTDIR)$(BINDIR)/showdown\n\n\
 If this installation is for personal use, you should also run\n\
 "make post-install" now to update the icon and .desktop caches.\n\n
endef

all: showdown

showdown: $(VALAFILES) resources.c libmarkdown.vapi
	valac $(VALAFLAGS) $(VALAPKGS) -o $@ $(VALAFILES) resources.c

resources.c: res/resources.xml $(RESOURCES)
	$(RESCOMPILE) --generate-source --target $@ $<

showdown-%.tar.gz:
	@git archive --prefix=showdown-$*/ -o $@ $*
	@echo 'Generated: $@'

install: all
	mkdir -p '$(DESTDIR)$(BINDIR)' '$(DESTDIR)$(APPICONDIR)'
	install -p -m 0755 showdown '$(DESTDIR)$(BINDIR)/showdown'
	install -p -m 0644 showdown.svg '$(DESTDIR)$(APPICONDIR)/showdown.svg'
	desktop-file-install --dir='$(DESTDIR)$(DESKTOPDIR)' showdown.desktop
	@printf '$(POST-INSTALL-MESSAGE)'

install-home:
	@$(MAKE) all install post-install PREFIX=$(HOME)/.local

uninstall:
	rm -f '$(DESTDIR)$(BINDIR)/showdown'
	rm -f '$(DESTDIR)$(APPICONDIR)/showdown.svg'
	rm -f '$(DESTDIR)$(DESKTOPDIR)/showdown.desktop'

post-install post-uninstall:
	update-desktop-database '$(DESKTOPDIR)'
	touch -c '$(ICONDIR)'
	gtk-update-icon-cache -t '$(ICONDIR)'

dist:
	@$(MAKE) --no-print-directory showdown-$(VERSION).tar.gz

clean:
	$(RM) showdown resources.c *.vala.c showdown-*.tar.gz

check:
	desktop-file-validate showdown.desktop
	gtk-builder-tool validate res/window.ui
	gtk-builder-tool validate res/menus.ui
	gtk-builder-tool validate res/help-overlay.ui


.PHONY: \
    all install install-home uninstall post-install post-uninstall \
    dist clean check

.DELETE_ON_ERROR:
