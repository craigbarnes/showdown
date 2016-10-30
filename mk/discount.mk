DISCOUNT_SRCDIR = build/discount-2.2.1
PKGCONFIG ?= pkg-config --silence-errors 2>/dev/null

ifdef USE_LOCAL_DISCOUNT
 DISCOUNT_LDFLAGS = -Wl,-Bstatic -L$(DISCOUNT_SRCDIR) -lmarkdown -Wl,-Bdynamic
 DISCOUNT_CFLAGS = -I$(DISCOUNT_SRCDIR)
 showdown: | $(DISCOUNT_SRCDIR)/libmarkdown.a
else ifeq '$(shell $(PKGCONFIG) --exists libmarkdown && echo 1)' '1'
 DISCOUNT_LDFLAGS ?= $(shell $(PKGCONFIG) --libs libmarkdown)
 DISCOUNT_CFLAGS ?= $(shell $(PKGCONFIG) --cflags libmarkdown)
else
 DISCOUNT_LDFLAGS ?= -lmarkdown
endif

DISCOUNT_FLAGS = $(DISCOUNT_CFLAGS) $(DISCOUNT_LDFLAGS)

build/discount-%/libmarkdown.a: | build/discount-%/
	cd $| && ./configure.sh && make

build/discount-%/: | build/discount-%.tar.gz
	cd build && gunzip -d < discount-$*.tar.gz | tar -xf -

build/discount-%.tar.gz: | build/
	curl -sSL -o $@ https://github.com/Orc/discount/archive/v$*.tar.gz

build/:
	mkdir -p $@


.SECONDARY: $(DISCOUNT_SRCDIR)/
