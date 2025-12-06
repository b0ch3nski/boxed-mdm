# Project settings
IMAGE_NAME := intune-indocker
PORT_DBUS := 5556

# Make settings
.ONESHELL:

# Make goals
build: ## Builds Docker image
	docker build \
		--file="Dockerfile" \
		--label="org.opencontainers.image.title=$(IMAGE_NAME)" \
		--label="org.opencontainers.image.revision=$(shell git log -1 --format=%H)" \
		--label="org.opencontainers.image.created=$(shell date --iso-8601=seconds)" \
		--tag="$(IMAGE_NAME):latest" \
		.

run: ## Runs the built Docker image
	docker run \
		--detach \
		--restart unless-stopped \
		--name="intune" \
		--hostname="ubuntu" \
		--env DISPLAY \
		--env USER_ID="$(shell id --user)" \
		--publish 127.0.0.1:$(PORT_DBUS):5556/tcp \
		--volume "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
		--volume "/dev/mapper/vg-root:/dev/mapper/vg-root:ro" \
		--volume "/dev/dm-2:/dev/dm-2:ro" \
		--device=/dev/dri \
		--security-opt="seccomp=unconfined" \
		$(IMAGE_NAME):latest
