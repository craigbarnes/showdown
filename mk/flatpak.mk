FLATPAK_PERMS = \
    --filesystem=host:ro \
    --share=ipc \
    --share=network \
    --socket=x11 \
    --socket=wayland \
    --socket=session-bus

flatpak: | public/flatpak/ public/showdown.flatpakref

public/flatpak/: | build/flatpak/files/bin/showdown public/
	flatpak build-export $(FLATPAK_EXPORT_FLAGS) $@ build/flatpak/

public/showdown.flatpakref: showdown.flatpakref | public/showdown.svg
	cp $< $@

public/showdown.svg: res/showdown.svg
	cp $< $@

build/flatpak/files/bin/showdown: | $(DISCOUNT_SRCDIR)/ build/flatpak/
	flatpak build build/flatpak/ make USE_LOCAL_DISCOUNT=1
	flatpak build build/flatpak/ make install PREFIX=/app APPICON='$(APPID)'
	flatpak build-finish build/flatpak/ --command=showdown $(FLATPAK_PERMS)

build/flatpak/: | build/
	flatpak build-init $@ '$(APPID)' org.gnome.Sdk org.gnome.Platform 3.24

public/:
	mkdir -p $@


.PHONY: flatpak
