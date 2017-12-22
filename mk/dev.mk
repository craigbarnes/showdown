DIST_VERSIONS = 0.6 0.5 0.3 0.2 0.1
DIST_TARBALLS = $(addprefix showdown-, $(addsuffix .tar.gz, $(DIST_VERSIONS)))

dist: $(firstword $(DIST_TARBALLS))
dist-all: $(DIST_TARBALLS)

check-dist: dist-all
	@sha256sum -c mk/sha256sums.txt

$(DIST_TARBALLS): showdown-%.tar.gz:
	$(E) ARCHIVE $@
	$(Q) git archive --prefix='showdown-$*/' -o '$@' '$*'

# Note: gtk-builder-tool is not suitable for automated/headless testing
check-ui-files:
	$(foreach UI_FILE, $(filter %.ui, $(RESOURCES)), \
	  NO_AT_BRIDGE=1 gtk-builder-tool validate $(UI_FILE); \
	)


CLEANFILES += showdown-*.tar.gz
.PHONY: dist dist-all check-dist check-ui-files
