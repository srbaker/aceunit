# Do not include cross in subs, people will not want to run this automatically.
subs:=\
    e2eTests/ \
    generatorTests/ \
    special/ \


include ../recurse.mk

all::
	$(MAKE) -C generatorTests clean
	$(MAKE) -C generatorTests all

ifneq ($(strip $(shell command -v objdump 2>/dev/null)),)
all::
	$(MAKE) -C generatorTests clean
	ACEUNIT_FLAGS="-t objdump" $(MAKE) -C generatorTests all
endif

ifneq ($(strip $(shell command -v nm 2>/dev/null)),)
all::
	$(MAKE) -C generatorTests clean
	ACEUNIT_FLAGS="-t nm"      $(MAKE) -C generatorTests all
endif

ifneq ($(strip $(shell command -v readelf 2>/dev/null)),)
all::
	$(MAKE) -C generatorTests clean
	ACEUNIT_FLAGS="-t readelf" $(MAKE) -C generatorTests all
endif
