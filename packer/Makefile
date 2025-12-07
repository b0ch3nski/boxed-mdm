# Project settings
PORT_SSH := 2222
PORT_DBUS := 5556
PORT_PROXY := 1080

# Make settings
MAKEFLAGS += --no-print-directory
.ONESHELL:

# Make goals
init: ## Initializes Packer plugins
	packer init .

fmt: ## Formats Packer templates
	packer fmt .

test: ## Tests Packer templates
	packer validate .

build: init ## Builds VM image using Packer
	PACKER_LOG=1 packer build \
		-var "port_dbus_socat=$(PORT_DBUS)" \
		-var "port_microsocks=$(PORT_PROXY)" \
		.

output/runtime.qcow2: output/ubuntu.qcow2
	qemu-img create -f qcow2 -b ubuntu.qcow2 -F qcow2 $@

run: output/runtime.qcow2 ## Runs the built VM image with QEMU
	qemu-system-x86_64 \
		-enable-kvm \
		-m 2048 \
		-smp 2 \
		-drive file=output/runtime.qcow2,format=qcow2 \
		-net nic -net user,hostfwd=tcp::$(PORT_SSH)-:22,hostfwd=tcp::$(PORT_DBUS)-:$(PORT_DBUS),hostfwd=tcp::$(PORT_PROXY)-:$(PORT_PROXY) \
		-daemonize

ssh: ## Connects to the VM via SSH
	@sshpass -p "ubuntu" ssh -Y -p $(PORT_SSH) ubuntu@localhost "$(cmd)"

stop: ## Shuts down VM gracefully
	@$(MAKE) cmd="sudo -S shutdown -P now" ssh

clean: ## Reset runtime overlay
	@rm -fv output/runtime.qcow2
