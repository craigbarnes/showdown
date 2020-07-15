include mk/compat.mk
-include local.mk
include mk/util.mk
include mk/discount.mk
include mk/build.mk
-include mk/flatpak.mk
-include mk/dev.mk

# Installation directories (may be overridden on the command line)
prefix = /usr/local
bindir = $(prefix)/bin
datadir = $(prefix)/share
appdir = $(datadir)/applications
appdatadir = $(datadir)/metainfo
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

APPID = io.gitlab.craigbarnes.Showdown
APPICON = showdown
INSTALL = install
INSTALL_DIR = $(INSTALL) -d -m755
RM = rm -f

all: showdown

run: all
	./showdown README.md

install: all installdirs
	$(INSTALL) -m755 showdown '$(DESTDIR)$(bindir)/showdown'
	$(INSTALL) -m644 res/showdown.svg '$(DESTDIR)$(appicondir)/$(APPICON).svg'
	desktop-file-install --dir='$(DESTDIR)$(appdir)' \
	  --set-key=Exec --set-value='$(bindir)/showdown %U' \
	  --set-icon='$(APPICON)' share/$(APPID).desktop
	$(INSTALL) -m644 share/$(APPID).appdata.xml '$(DESTDIR)$(appdatadir)'
	$(if $(DESTDIR),, $(POSTINSTALL))

installdirs:
	$(Q) $(INSTALL_DIR) '$(DESTDIR)$(bindir)'
	$(Q) $(INSTALL_DIR) '$(DESTDIR)$(appdir)'
	$(Q) $(INSTALL_DIR) '$(DESTDIR)$(appicondir)'
	$(Q) $(INSTALL_DIR) '$(DESTDIR)$(appdatadir)'

install-home:
	@$(MAKE) all install prefix=$(HOME)/.local

uninstall:
	$(RM) '$(DESTDIR)$(bindir)/showdown'
	$(RM) '$(DESTDIR)$(appicondir)/showdown.svg'
	$(RM) '$(DESTDIR)$(appdir)/$(APPID).desktop'
	$(RM) '$(DESTDIR)$(appdatadir)/$(APPID).appdata.xml'
	$(if $(DESTDIR),, $(POSTINSTALL))

check: all
	desktop-file-validate share/$(APPID).desktop
	appstream-util --nonet validate-relax share/$(APPID).appdata.xml

clean:
	$(RM) $(CLEANFILES)
	$(if $(CLEANDIRS),$(RM) -r $(CLEANDIRS))


.DEFAULT_GOAL = all
.PHONY: all run install installdirs install-home uninstall check clean
.DELETE_ON_ERROR:
