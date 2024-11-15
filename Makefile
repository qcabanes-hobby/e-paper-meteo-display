SHELL := /bin/bash
PLATFORM := linux/arm64
DISTRO := debian-10
YOCTO_RELEASE := kirkstone
YOCTO_REPO := git://git.yoctoproject.org/poky
RASPBERRYPI_LAYER_REPO := git://git.yoctoproject.org/meta-raspberrypi
OPENEMBEDDED_LAYER_REPO := git://git.openembedded.org/meta-openembedded

.PHONY: setup
setup:
	@echo "Creating docker environment..."
	@docker volume create --name poky-volume
	@docker run --name poky-busybox -v poky-volume:/workdir busybox chown -R 1000:1000 /workdir
	@docker cp ./build poky-busybox:/workdir/build
	@docker rm poky-busybox
	@git clone https://github.com/crops/poky-container.git
	@sed -i '' 's/SPECIFY_ME/$(DISTRO)/' poky-container/Dockerfile
	@docker build -f poky-container/Dockerfile --platform=$(PLATFORM) -t crops/poky:selfbuilt poky-container
	@docker run --platform=$(PLATFORM) -v poky-volume:/workdir --workdir=/workdir --rm crops/poky:selfbuilt git clone -b $(YOCTO_RELEASE) $(YOCTO_REPO)
	@docker run --platform=$(PLATFORM) -v poky-volume:/workdir --workdir=/workdir --rm crops/poky:selfbuilt git clone -b $(YOCTO_RELEASE) $(RASPBERRYPI_LAYER_REPO)
	@docker run --platform=$(PLATFORM) -v poky-volume:/workdir --workdir=/workdir --rm crops/poky:selfbuilt git clone -b $(YOCTO_RELEASE) $(OPENEMBEDDED_LAYER_REPO)

.PHONY: run
run:
	@docker run --platform=$(PLATFORM) -v poky-volume:/workdir --workdir=/workdir -it crops/poky:selfbuilt

.PHONY: clean
clean:
	@rm -rf poky-container
	@containers=$$(docker ps -a --filter "volume=poky-volume" -q); \
	if [ -n "$$containers" ]; then \
	  docker stop $$containers; \
	  docker rm $$containers; \
	fi; \
	docker volume rm poky-volume || true