RELEASE_VERSIONS = 0.6 0.5 0.3 0.2 0.1
RELEASE_DIST = $(addprefix showdown-, $(addsuffix .tar.gz, $(RELEASE_VERSIONS)))
DISTVER = $(VERSION)
CLEANFILES += showdown-*.tar.gz

dist: showdown-$(DISTVER).tar.gz
dist-latest-release: $(firstword $(RELEASE_DIST))
dist-all-releases: $(RELEASE_DIST)

showdown-%.tar.gz:
	$(E) ARCHIVE $@
	$(Q) git archive --prefix='showdown-$*/' -o '$@' '$*'

check-release-digests: dist-all-releases
	@sha256sum -c mk/sha256sums.txt

# Note: gtk-builder-tool is not suitable for automated/headless testing
check-ui-files:
	$(foreach UI_FILE, $(filter %.ui, $(RESOURCES)), \
	  NO_AT_BRIDGE=1 gtk-builder-tool validate $(UI_FILE); \
	)


.PHONY: \
    dist dist-latest-release dist-all-releases \
    check-release-digests check-ui-files
