# boxed-mdm

Run enterprise device management in an isolated environment with selective bridging to host.

## Approaches

There are two operation methods available: containerized (Docker) and virtualized (Packer). Both expose D-Bus session
socket for message routing between environments.

### docker

Container-based isolation without SystemD dependency. \
All services run inside single container with D-Bus started manually. \
D-Bus session socket exposed via Socat on port 5556 for external bridging. \
GUI applications accessible through X11 forwarding from host. \
Requires LUKS encrypted block devices from host exposed as volumes to satisfy disk encryption policies.

This is a semi-working solution - can be used, but requires manual block device management which is uncomfortable.

For build details, see [docker/Makefile](docker/Makefile) and [docker/Dockerfile](docker/Dockerfile).

```sh
# build image
$ make build

# run container
$ make run
```

### packer

VM-based solution with full enrollment compliance. \
[Packer][packer] builds all-in-one virtual machine with all needed tools and configurations, like password policy. \
It's LUKS encrypted and fulfills all enrollment requirements. \
QEMU image includes automatic keyfile unlock for unattended boot.

D-Bus session socket exposed via Socat (port 5556) and SOCKS5 proxy via Microsocks (port 1080) on startup. \
X11 forwarding over SSH enabled by default for GUI applications (Xorg over SSH pattern).

This is the most complete solution yet not perfect.

For provisioning details, see [packer/Makefile](packer/Makefile), [packer/install.pkr.hcl](packer/install.pkr.hcl),
[packer/install.sh](packer/install.sh) and [packer/autoinstall/user-data](packer/autoinstall/user-data).

```sh
# build VM image
$ make build

# run VM with port forwarding
$ make run
```

## D-Bus Bridging

Both approaches expose D-Bus session socket over TCP (port 5556 by default). \
Use [dbus-proxy][dbus-proxy] to forward messages between isolated environment and host session bus.

This enables D-Bus services to communicate with host desktop environment for authentication flows and notifications.


[packer]: https://www.packer.io
[dbus-proxy]: https://github.com/b0ch3nski/dbus-proxy
