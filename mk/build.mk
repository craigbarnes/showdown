VALAC ?= valac
RESGEN ?= glib-compile-resources
VERSION = $(shell mk/version.sh 0.6)

CWARNFLAGS = \
    -Wno-incompatible-pointer-types \
    -Wno-discarded-qualifiers

VALAFLAGS = \
    --target-glib=2.48 \
    --gresources=res/resources.xml \
    $(foreach f, $(CWARNFLAGS) $(DISCOUNT_FLAGS),-X '$(f)') \
    $(VALAFLAGS_EXTRA)

VALAPKGS = \
    --pkg gtk+-3.0 \
    --pkg webkit2gtk-4.0 \
    --vapidir src --pkg libmarkdown

VALAFILES = \
    src/showdown.vala \
    src/window.vala \
    src/view.vala \
    build/version.vala

RESOURCES = $(addprefix res/, \
    window.ui menus.ui help-overlay.ui \
    template.html error.html \
    main.css \
    showdown.svg )

# If "make install*" with no other named targets
ifeq "" "$(filter-out install%,$(or $(MAKECMDGOALS),all))"
  OPTCHECK = :
else
  OPTCHECK = SILENT_BUILD='$(MAKE_S)' mk/optcheck.sh
endif

showdown: $(VALAFILES) src/libmarkdown.vapi build/resources.c build/flags.txt
	$(E) VALAC $@
	$(Q) $(VALAC) $(VALAFLAGS) $(VALAPKGS) -o $@ $(filter %.vala %.c, $^)

build/resources.c: res/resources.xml $(RESOURCES) | build/
	$(E) RESGEN $@
	$(Q) $(RESGEN) --sourcedir res/ --generate-source --target $@ $<

build/version.vala: src/version.vala.in build/version.txt | build/
	$(E) GEN $@
	$(Q) printf "$$(cat $<)\n" "$$(cat build/version.txt)" > $@

build/version.txt: FORCE | build/
	@$(OPTCHECK) '$(VERSION)' $@

build/flags.txt: FORCE | build/
	@$(OPTCHECK) '$(VALAC) $(VALAFLAGS) $(VALAPKGS)' $@

build/:
	@mkdir -p $@


CLEANFILES += showdown src/*.vala.c
CLEANDIRS += build/
.PHONY: FORCE
.SECONDARY: build/
