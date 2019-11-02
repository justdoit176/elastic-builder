# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

#resource "libvirt_pool" "pool" {
#  name = var.pool_name
#  type = "dir"
#  path = "/var/lib/libvirt/images/${var.pool_name}"
#}

resource "libvirt_volume" "instance-qcow2" {
  name = "${var.instance_name}-qcow2"
#  pool = libvirt_pool.pool.name
  base_volume_id = libvirt_volume.ubuntu-qcow2.id
  size = var.vol_size #10G
}

# Create the machine
resource "libvirt_domain" "vm" {
  name   = var.instance_name
  memory = var.memory_size
  vcpu   = var.cpu_qty

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "default"
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.instance-qcow2.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

terraform {
  required_version = ">= 0.12"
}

# IPs: use wait_for_lease true or after creation use terraform refresh and terraform show for the ips of domain
