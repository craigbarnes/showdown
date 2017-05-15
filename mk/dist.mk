TAGS = 0.5 0.3 0.2 0.1
DIST_TARBALLS = $(addprefix showdown-, $(addsuffix .tar.gz, $(TAGS)))

dist: $(addprefix public/dist/, $(DIST_TARBALLS) sha1sums.txt)

check-dist: dist
	cd public/dist/ && sha1sum -c sha1sums.txt

public/dist/showdown-%.tar.gz: | public/dist/
	git archive --prefix=showdown-$*/ -o $@ $*

public/dist/sha1sums.txt: mk/sha1sums.txt | public/dist/
	cp $< $@

public/dist/: | public/
	mkdir -p $@


.PHONY: dist check-dist
