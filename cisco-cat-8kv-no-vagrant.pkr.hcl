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
  default = "unknown"
}

variable "gui_disabled" {
  type    = bool
  default = true
}

variable "boot_time" {
  type    = string
  default = "2m"
}

variable "boot_key_interval" {
  type    = string
  default = "50ms"
}

variable "vm_name" {
  default = "cisco-catalyst-8kv"
}

variable "image_name" {
  type    = string
  default = "cisco-catalyst-8kv"
}

variable "image_path" {
  default = "/var/lib/libvirt/images"
}

variable "qemu_binary" {
  default = "qemu-system-x86_64"
}

variable "telnet_port" {
  default = "52099"
}

variable "out_dir" {
  type    = string
  default = "tmp_out"
}

source "qemu" "cisco-catalyst-8kv" {
  accelerator       = "kvm"
  qemu_binary       = var.qemu_binary
  cpus              = 2
  memory            = "4096"
  disk_image        = true
  format            = "qcow2"
  net_device        = "virtio-net"
  iso_checksum      = "none"
  iso_url           = "${var.image_path}/${var.image_name}"
  boot_wait         = "${var.boot_time}"
  boot_key_interval = "${var.boot_key_interval}"
  headless          = "${var.gui_disabled}"
  communicator      = "none"
  vm_name           = var.vm_name
  output_directory = "${var.out_dir}"
  shutdown_timeout  = "5m"
  qemuargs          = [
    ["-cdrom", "${var.image_path}/${var.image_name}"],
    ["-nographic"],
    ["-serial", "telnet:127.0.0.1:${var.telnet_port},server,nowait"],
    ["-boot", "d"],
    ["-pidfile", "/tmp/cisco-catalyst-8kv.pid"]
  ]
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
}
