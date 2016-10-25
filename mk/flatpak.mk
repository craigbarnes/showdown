FLATPAK_EXPORT_FLAGS ?= --gpg-sign=0330BEB4

flatpak: | public/flatpak/

public/flatpak/: | build/flatpak/files/bin/showdown public/
	flatpak build-export $(FLATPAK_EXPORT_FLAGS) $@ build/flatpak/

build/flatpak/files/bin/showdown: | $(DISCOUNT_SRCDIR)/ build/flatpak/
	flatpak build build/flatpak/ make USE_LOCAL_DISCOUNT=1
	flatpak build build/flatpak/ make install PREFIX=/app APPICON='$(APPID)'
	flatpak build-finish build/flatpak/ --command=showdown \
	  --filesystem=host:ro --share=ipc --share=network \
	  --socket=x11 --socket=session-bus

build/flatpak/: | build/
	flatpak build-init $@ '$(APPID)' org.gnome.Sdk org.gnome.Platform 3.22

public/:
	mkdir -p $@


.PHONY: flatpak
