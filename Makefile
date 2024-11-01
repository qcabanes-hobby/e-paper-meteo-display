SHELL := /bin/bash
YOCTO_DIR := poky
YOCTO_RELEASE := kirkstone
YOCTO_REPO := git://git.yoctoproject.org/poky
YOCTO_BRANCH := ${YOCTO_RELEASE}
RASPBERRYPI_LAYER_REPO := git://git.yoctoproject.org/meta-raspberrypi
BUILD_DIR := build

# Ensure all necessary dependencies are installed (Ubuntu example)
.PHONY: dependencies
dependencies:
	sudo apt-get update && sudo apt-get install -y \
		gawk \
		wget \
		git \
		diffstat \
		unzip \
		texinfo \
		gcc \
		build-essential \
		chrpath \
		socat \
		cpio \
		python3 \
		python3-pip \
		python3-pexpect \
		xz-utils \
		debianutils \
		iputils-ping \
		python3-git \
		python3-jinja2 \
		python3-subunit \
		zstd \
		liblz4-tool \
		file \
		locales \
		libacl1
	locale-gen en_US.UTF-8

# Clone or update the Yocto repository
.PHONY: download
download:
	@if [ ! -d "$(YOCTO_DIR)" ]; then \
		git clone -b $(YOCTO_BRANCH) $(YOCTO_REPO) $(YOCTO_DIR); \
	else \
		cd $(YOCTO_DIR) && git pull; \
	fi

	@if [ ! -d "$(YOCTO_DIR)/meta-raspberrypi" ]; then \
		git clone -b $(YOCTO_BRANCH) $(RASPBERRYPI_LAYER_REPO) $(YOCTO_DIR)/meta-raspberrypi; \
	else \
		cd $(YOCTO_DIR)/meta-raspberrypi && git pull; \
	fi

# Initialize Yocto environment
.PHONY: setup
setup:
	@if [ ! -d "$(YOCTO_DIR)" ]; then \
		echo "Yocto directory not found. Run 'make download' first."; \
		exit 1; \
	fi
	source $(YOCTO_DIR)/oe-init-build-env $(BUILD_DIR)

.PHONY: configure
configure: setup
#	./build/wpa-supplicant/load_wpa_supplicant.sh poky/meta/recipes-connectivity/wpa-supplicant/wpa-supplicant/wpa_supplicant.conf-sane


# Build the Yocto image (core-image-minimal in this case)
.PHONY: build
build: setup configure
	source $(YOCTO_DIR)/oe-init-build-env $(BUILD_DIR) && bitbake core-image-minimal

# Clean the build environment
.PHONY: clean
clean:
	rm -rf $(YOCTO_DIR)

# Full build process
.PHONY: all
all: dependencies download build