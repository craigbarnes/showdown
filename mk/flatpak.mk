flatpak: | build/flatpak-repo/

build/flatpak-repo/: | build/flatpak-build/files/bin/showdown
	flatpak build-export --gpg-sign=0330BEB4 $@ build/flatpak-build/

build/flatpak-build/files/bin/showdown: | $(DISCOUNT_SRCDIR)/ build/flatpak-build/
	flatpak build build/flatpak-build/ make USE_LOCAL_DISCOUNT=1
	flatpak build build/flatpak-build/ make install PREFIX=/app APPICON='$(APPID)'
	flatpak build-finish build/flatpak-build/ --command=showdown \
	  --filesystem=host:ro --share=ipc --share=network \
	  --socket=x11 --socket=session-bus

build/flatpak-build/: | build/
	flatpak build-init $@ '$(APPID)' org.gnome.Sdk org.gnome.Platform 3.22


.PHONY: flatpak
