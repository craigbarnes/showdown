MAKE_S = $(findstring s,$(firstword -$(MAKEFLAGS)))$(filter -s,$(MAKEFLAGS))

ifneq "$(MAKE_S)" ""
  # Make "-s" flag was used (silent build)
  Q = @
  E = @:
else ifeq "$(V)" "1"
  # "V=1" variable was set (verbose build)
  Q =
  E = @:
else
  # Normal build
  Q = @
  E = @printf ' %7s  %s\n'
endif
