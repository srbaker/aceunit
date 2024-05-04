#subs:=lib test examples #$(patsubst %/Makefile,%,$(wildcard */Makefile))

include recurse.mk

## all:		Build and test AceUnit (library, generator, and integration).
## clean:		Remove all generated files.
## lib-all:	Build and self-test the AceUnit library.

test-all examples-all install: lib-all

versions:=c90 c99 c11 c17 c2x gnu90 gnu99 gnu11 gnu17 gnu2x
## compiler-test:	Test AceUnit with different versions of C.
compiler-test: $(versions:%=compiler-test-%)

compiler-test-%:
	$(MAKE) clean
	$(MAKE) CFLAGS+="-std=$*" CVERSION:=$*

PREFIX?=/usr/local/
MANDIR?=share/man

FILES_TO_INSTALL:=\
    $(DESTDIR)$(PREFIX)/bin/aceunit \
    $(DESTDIR)$(PREFIX)/include/aceunit.h \
    $(DESTDIR)$(PREFIX)/include/aceunit.mk \
    $(DESTDIR)$(PREFIX)/lib/libaceunit-abort.a \
    $(DESTDIR)$(PREFIX)/lib/libaceunit-fork.a \
    $(DESTDIR)$(PREFIX)/lib/libaceunit-setjmp.a \
    $(DESTDIR)$(PREFIX)/lib/libaceunit-simple.a \
    $(DESTDIR)$(PREFIX)/share/aceunit/nm.ac \
    $(DESTDIR)$(PREFIX)/share/aceunit/objdump.ac \
    $(DESTDIR)$(PREFIX)/share/aceunit/readelf.ac \
    $(DESTDIR)$(PREFIX)/share/doc/aceunit/copyright \
    $(DESTDIR)$(PREFIX)/$(MANDIR)/man1/aceunit.1 \
    $(DESTDIR)$(PREFIX)/$(MANDIR)/man3/aceunit.3

.PHONY: build
## build	Build the AceUnit library without running any tests.
build:
	$(MAKE) -C lib libs

.PHONY: install
## install:	Install AceUnit for the local system (Unix/POSIX/Cygwin/MinGW).
install: $(FILES_TO_INSTALL)

$(DESTDIR)$(PREFIX)/bin/aceunit: bin/aceunit
	install -d $(dir $@)
	install $^ $@

$(DESTDIR)$(PREFIX)/%: %
	install -d $(dir $@)
	install -m 644 $^ $@

$(DESTDIR)$(PREFIX)/include/aceunit.mk: include/aceunit.mk
	install -d $(dir $@)
	sed -e 's#$${PREFIX}#$(PREFIX)#' <$< >$@

.PHONY: uninstall
## uninstall:	Remove AceUnit from the local system (Unix/POSIX/Cygwin/MinGW).
uninstall:
	$(RM) $(FILES_TO_INSTALL)

.PHONY: dist
## dist:	Creates source and binary distribution archives.
dist: dist-src dist-bin

.PHONY: dist-src
## dist-src:	Creates source distribution archives.
dist-src: archive:=aceunit-3.0.0-src
dist-src:
	mkdir -p dist-src/
	git archive -o dist-src/$(archive).tar --prefix $(archive)/ HEAD .
	<dist-src/$(archive).tar gzip  -9 >dist-src/$(archive).tar.gz
	<dist-src/$(archive).tar bzip2 -9 >dist-src/$(archive).tar.bz2
	<dist-src/$(archive).tar xz    -9 >dist-src/$(archive).tar.xz

.PHONY: dist-bin
## dist-bin:	Creates a binary distribution archive.
dist-bin: os:=$(shell uname -s)
dist-bin: hw:=$(shell uname -m)
dist-bin: archive:=aceunit-3.0.0-bin-$(os)-$(hw)
dist-bin:
	mkdir -p dist-bin/$(archive)/
	$(MAKE) DESTDIR=dist-bin/$(archive)/ PREFIX=/usr/ install
	tar cfC dist-bin/$(archive).tar dist-bin/ --owner=0 --group=0 --mode='og-w' $(archive)/
	<dist-bin/$(archive).tar gzip  -9 >dist-bin/$(archive).tar.gz
	<dist-bin/$(archive).tar bzip2 -9 >dist-bin/$(archive).tar.bz2
	<dist-bin/$(archive).tar xz    -9 >dist-bin/$(archive).tar.xz

.PHONY: help
## help:		Print this help text.
help:
	@sed -En 's/^## ?//p' $(MAKEFILE_LIST)

.PHONY: debug
.ONESHELL: debug
debug:
	echo subs=$(subs)
	echo targets=$(targets)
	echo recurse_template='$(recurse_template)'
