BUILDROOT_BRANCH = 2022.02.x

BUILDROOT_OPTIONS =

BUILDROOT_VARIANT = buildroot

BUILDROOT_MACHINE = $(shell uname -m | sed -e 's/arm64/aarch64/')

BUILDROOT_TARGET = $(BUILDROOT_VARIANT)_$(BUILDROOT_MACHINE)_defconfig

all: build

buildroot:
	git clone --single-branch --branch=$(BUILDROOT_BRANCH) \
	          --no-tags --depth=1 https://github.com/buildroot/buildroot

buildroot/.config: buildroot
	$(MAKE) -C buildroot $(BUILDROOT_OPTIONS) $(BUILDROOT_TARGET)

.PHONY: build
build: buildroot/.config
	$(MAKE) -C buildroot $(BUILDROOT_OPTIONS) world

.PHONY: download
download: buildroot/.config
	$(MAKE) -C buildroot $(BUILDROOT_OPTIONS) source

.PHONY: toolchain
toolchain: buildroot/.config
	$(MAKE) -C buildroot $(BUILDROOT_OPTIONS) sdk

.PHONY: clean
clean:
	rm -f buildroot/.config
	$(MAKE) -C buildroot $(BUILDROOT_OPTIONS) clean

graph-size.pdf:
	$(MAKE) -C buildroot graph-size
	cp buildroot/output/graphs/graph-size.pdf $@

graph-size.png: graph-size.pdf
	pdftoppm <$< | pnmtopng >$@
