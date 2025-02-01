packer {
  required_plugins {
    vagrant = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vagrant"
    }
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "version" {
  type    = string
  default = "1.0.0"
}

variable "vm_name" {
  default = "cisco-catalyst-8kv"
}

variable "qcow2_path" {
  default = "/var/lib/libvirt/images/cisco-catalyst-8kv-17.10.01a.qcow2"
}

variable "qemu_binary" {
  default = "qemu-system-x86_64"
}

variable "telnet_port" {
  default = "52099"
}

source "qemu" "cisco-catalyst-8kv" {
  vm_name          = var.vm_name
  iso_url          = var.qcow2_path
  iso_checksum     = "none"
  disk_image       = true
  format           = "qcow2"
  accelerator      = "kvm"
  cpus             = 2
  memory           = "4096"
  headless         = true
  qemu_binary      = var.qemu_binary
  net_device       = "virtio-net"
  shutdown_timeout = "5m"

  qemuargs = [
    ["-cdrom", "/var/lib/libvirt/images/cisco-catalyst-8kv-17.10.01a.qcow2"],
    ["-nographic"],
    ["-serial", "telnet:127.0.0.1:${var.telnet_port},server,nowait"],
    ["-boot", "d"],
    ["-pidfile", "/tmp/cisco-catalyst-8kv.pid"]
  ]

  boot_wait = "2m"
  communicator = "none"
}


build {
  name = "cisco-catalyst-8kv"

  sources = [
    "qemu.cisco-catalyst-8kv"
  ]

  provisioner "shell-local" {
    inline = [
      "expect cisco_cat8kv_config.exp"
    ]
  }

  provisioner "shell-local" {
    inline = [
      "pkill -f '/usr/bin/qemu-system-x86_64.*-name cisco-catalyst-8kv'"
    ]
  }

  post-processor "vagrant" {
    output = "builds/cisco-catalyst-8kv-${var.version}.box"
  }
}
