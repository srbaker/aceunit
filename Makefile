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
	$(MAKE) CFLAGS+="-std=$* -Werror" CVERSION:=$*

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

.PHONY: install
## install:	Install AceUnit for the local system (Unix/POSIX/Cygwin/MinGW).
install: $(FILES_TO_INSTALL)

$(DESTDIR)$(PREFIX)/%: %
	install -d $(dir $@)
	install $^ $@

$(DESTDIR)$(PREFIX)/include/aceunit.mk: include/aceunit.mk
	install -d $(dir $@)
	sed -e 's#$${PREFIX}#$(PREFIX)#' <$< >$@

.PHONY: uninstall
## uninstall:	Remove AceUnit from the local system (Unix/POSIX/Cygwin/MinGW).
uninstall:
	$(RM) $(FILES_TO_INSTALL)

.PHONY: help
## help:		Print this help text.
help:
	@sed -n 's/^## \?//p' $(MAKEFILE_LIST)

.PHONY: debug
.ONESHELL: debug
debug:
	echo subs=$(subs)
	echo targets=$(targets)
	echo recurse_template='$(recurse_template)'
