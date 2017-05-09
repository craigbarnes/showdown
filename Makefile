-include local.mk
include mk/compat.mk
include mk/discount.mk
include mk/flatpak.mk

# Installation directories (may be overridden on the command line)
PREFIX     = /usr/local
BINDIR     = $(PREFIX)/bin
DATADIR    = $(PREFIX)/share
DESKTOPDIR = $(DATADIR)/applications
ICONDIR    = $(DATADIR)/icons/hicolor
APPICONDIR = $(ICONDIR)/scalable/apps

# The following 3 commands are run after the install and uninstall
# targets, unless the DESTDIR variable is set. The presence of DESTDIR
# usually indicates a distro packaging environment, in which case the
# equivalent, distro-provided macros/hooks should be used instead.
define POSTINSTALL
 update-desktop-database '$(DESKTOPDIR)'
 touch -c '$(ICONDIR)'
 gtk-update-icon-cache -t '$(ICONDIR)'
endef

APPID      = org.gnome.Showdown
APPICON    = showdown
VERSION    = $(or $(shell git describe --abbrev=0),$(error No version info))

CWARNFLAGS = -Wno-incompatible-pointer-types -Wno-discarded-qualifiers
VALAFLAGS  = --target-glib=2.48 --gresources=res/resources.xml
VALAFLAGS += $(foreach f, $(CWARNFLAGS) $(DISCOUNT_FLAGS),-X '$(f)')
VALAPKGS   = --pkg gtk+-3.0 --pkg webkit2gtk-4.0 --vapidir . --pkg libmarkdown
VALAFILES  = $(addsuffix .vala, showdown window view)
RESCOMPILE = glib-compile-resources --sourcedir res/
RESOURCES  = $(shell $(RESCOMPILE) --generate-dependencies res/resources.xml)

all: showdown

run: all
	./showdown README.md

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
	install -p -m 0644 res/showdown.svg '$(DESTDIR)$(APPICONDIR)/$(APPICON).svg'
	desktop-file-install --dir='$(DESTDIR)$(DESKTOPDIR)' \
	  --set-key=Exec --set-value='$(BINDIR)/showdown %U' \
	  --set-icon='$(APPICON)' share/$(APPID).desktop
	$(if $(DESTDIR),, $(POSTINSTALL))

install-home:
	@$(MAKE) all install PREFIX=$(HOME)/.local

uninstall:
	rm -f '$(DESTDIR)$(BINDIR)/showdown'
	rm -f '$(DESTDIR)$(APPICONDIR)/showdown.svg'
	rm -f '$(DESTDIR)$(DESKTOPDIR)/$(APPID).desktop'
	$(if $(DESTDIR),, $(POSTINSTALL))

dist:
	@$(MAKE) --no-print-directory showdown-$(VERSION).tar.gz

clean:
	$(RM) showdown resources.c *.vala.c showdown-*.tar.gz

check:
	desktop-file-validate share/$(APPID).desktop
	$(foreach UI_FILE, $(filter %.ui, $(RESOURCES)), \
	  NO_AT_BRIDGE=1 gtk-builder-tool validate $(UI_FILE); \
	)


.DEFAULT_GOAL = all
.PHONY: all run install install-home uninstall dist clean check
.DELETE_ON_ERROR:
