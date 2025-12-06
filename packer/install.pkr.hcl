packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.1.4"
    }
  }
}

variables {
  ubuntu_version  = "24.04.3"
  zscaler_version = "3.7.1.71-1"

  port_dbus_socat = 5556
  port_microsocks = 1080
}

source "qemu" "ubuntu" {
  accelerator      = "kvm"
  cpus             = 16
  memory           = 8192
  disk_size        = "10G"
  disk_discard     = "unmap"
  disk_compression = true
  headless         = true

  iso_url      = "https://releases.ubuntu.com/${var.ubuntu_version}/ubuntu-${var.ubuntu_version}-live-server-amd64.iso"
  iso_checksum = "file:https://releases.ubuntu.com/${var.ubuntu_version}/SHA256SUMS"

  http_directory = "autoinstall"
  boot_command = [
    "e<wait>",
    "<down><down><down>",
    "<end><bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<f10>"
  ]

  ssh_password     = "ubuntu"
  ssh_username     = "ubuntu"
  ssh_timeout      = "30m"
  shutdown_command = "sudo -S shutdown -P now"

  output_directory = "output"
  vm_name          = "ubuntu.qcow2"
  format           = "qcow2"
}

build {
  name    = "ubuntu-${var.ubuntu_version}"
  sources = ["source.qemu.ubuntu"]

  provisioner "file" {
    source      = "./zscaler-client_${var.zscaler_version}_amd64.deb"
    destination = "/tmp/zscaler.deb"
  }

  provisioner "shell" {
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"

    script  = "install.sh"
    timeout = "30m"
  }

  provisioner "shell" {
    inline = [
      "echo '[ -n \"$DISPLAY\" ] && systemctl --user set-environment DISPLAY=\"$DISPLAY\"' >> ~/.profile",
      "echo 'eval $(echo -n \"xxx\" | gnome-keyring-daemon --unlock | sed -e \"s/^/export /\")' >> ~/.profile",
      "systemctl --user enable dbus-session-socat@${var.port_dbus_socat}",
      "systemctl --user enable microsocks@${var.port_microsocks}"
    ]
  }
}
