-include local.mk
include mk/compat.mk
include mk/util.mk
include mk/discount.mk
-include mk/flatpak.mk
-include mk/dist.mk

# Installation directories (may be overridden on the command line)
prefix = /usr/local
bindir = $(prefix)/bin
datadir = $(prefix)/share
appdir = $(datadir)/applications
icondir = $(datadir)/icons/hicolor
appicondir = $(icondir)/scalable/apps

# The following 3 commands are run after the install and uninstall
# targets, unless the DESTDIR variable is set. The presence of DESTDIR
# usually indicates a distro packaging environment, in which case the
# equivalent, distro-provided macros/hooks should be used instead.
define POSTINSTALL
 update-desktop-database -q '$(appdir)' || :
 touch -c '$(icondir)' || :
 gtk-update-icon-cache -qtf '$(icondir)' || :
endef

ifeq "" "$(filter-out install,$(or $(MAKECMDGOALS),all))"
 # Don't run optcheck for "make install"
 OPTCHECK = :
else
 OPTCHECK = SILENT_BUILD='$(MAKE_S)' mk/optcheck.sh
endif

APPID = io.gitlab.craigbarnes.Showdown
APPICON = showdown
VERSION = 0.6

VALAC ?= valac
RESGEN ?= glib-compile-resources
INSTALL = install
INSTALL_DIR = $(INSTALL) -d -m755
RM = rm -f

VALAPKGS = --pkg gtk+-3.0 --pkg webkit2gtk-4.0 --vapidir src --pkg libmarkdown
CWARNFLAGS = -Wno-incompatible-pointer-types -Wno-discarded-qualifiers

VALAFLAGS = \
    --target-glib=2.48 \
    --gresources=res/resources.xml \
    $(foreach f, $(CWARNFLAGS) $(DISCOUNT_FLAGS),-X '$(f)') \
    $(VALAFLAGS_EXTRA)

VALAFILES = \
    src/showdown.vala \
    src/window.vala \
    src/view.vala \
    build/version.vala

RESOURCES = $(addprefix res/, \
    window.ui menus.ui help-overlay.ui \
    template.html error.html \
    main.css toc.css \
    showdown.svg \
)

all: showdown

run: all
	./showdown README.md

showdown: $(VALAFILES) src/libmarkdown.vapi build/resources.c build/flags.txt
	$(E) VALAC $@
	$(Q) $(VALAC) $(VALAFLAGS) $(VALAPKGS) -o $@ $(filter %.vala %.c, $^)

build/resources.c: res/resources.xml $(RESOURCES) | build/
	$(E) RESGEN $@
	$(Q) $(RESGEN) --sourcedir res/ --generate-source --target $@ $<

build/version.vala: src/version.vala.in build/version.txt | build/
	$(E) GEN $@
	$(Q) printf "$$(cat $<)" "$$(cat build/version.txt)" > $@

build/version.txt: FORCE | build/
	@$(OPTCHECK) '$(VERSION)' $@

build/flags.txt: FORCE | build/
	@$(OPTCHECK) '$(VALAC) $(VALAFLAGS) $(VALAPKGS)' $@

build/:
	@mkdir -p $@

install: all
	$(INSTALL_DIR) '$(DESTDIR)$(bindir)' '$(DESTDIR)$(appicondir)'
	$(INSTALL) -m755 showdown '$(DESTDIR)$(bindir)/showdown'
	$(INSTALL) -m644 res/showdown.svg '$(DESTDIR)$(appicondir)/$(APPICON).svg'
	desktop-file-install --dir='$(DESTDIR)$(appdir)' \
	  --set-key=Exec --set-value='$(bindir)/showdown %U' \
	  --set-icon='$(APPICON)' share/$(APPID).desktop
	$(if $(DESTDIR),, $(POSTINSTALL))

install-home:
	@$(MAKE) all install prefix=$(HOME)/.local

uninstall:
	$(RM) '$(DESTDIR)$(bindir)/showdown'
	$(RM) '$(DESTDIR)$(appicondir)/showdown.svg'
	$(RM) '$(DESTDIR)$(appdir)/$(APPID).desktop'
	$(if $(DESTDIR),, $(POSTINSTALL))

clean:
	$(RM) -r build/
	$(RM) showdown src/*.vala.c $(CLEANFILES)

# The tools used in this target require a display connection for some
# reason, so it shouldn't be used for headless/automated testing.
check:
	desktop-file-validate share/$(APPID).desktop
	$(foreach UI_FILE, $(filter %.ui, $(RESOURCES)), \
	  NO_AT_BRIDGE=1 gtk-builder-tool validate $(UI_FILE); \
	)


.DEFAULT_GOAL = all
.PHONY: all run install install-home uninstall clean check FORCE
.DELETE_ON_ERROR:
