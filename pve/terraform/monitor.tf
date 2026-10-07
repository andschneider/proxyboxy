# Was created by pve/vms.yml. Moved to Terraform by destroying it by hand
# (`qm destroy 100 --purge`) and letting Terraform clone a fresh one.
locals {
  monitor_ip = "10.20.0.100"
}

resource "proxmox_virtual_environment_vm" "monitor" {
  name      = "monitor"
  node_name = local.node_name
  vm_id     = 100
  on_boot   = true

  # Never reboot it to apply a change: changes that need it offline fail, and
  # ones Proxmox can only stage (e.g. CPU, memory) warn and wait for a reboot.
  reboot_after_update = false

  clone {
    vm_id        = 9000 # template_vmid
    datastore_id = "fast"
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  operating_system {
    type = "l26"
  }

  scsi_hardware = "virtio-scsi-single"
  boot_order    = ["scsi0"]

  disk {
    datastore_id = "fast"
    interface    = "scsi0"
    size         = 64
    file_format  = "raw"
    discard      = "on"
    iothread     = true
    ssd          = true
  }

  network_device {
    bridge = local.lab_bridge
    model  = "virtio"
  }

  serial_device {}

  vga {
    type = "serial0"
  }

  initialization {
    datastore_id        = "fast"
    interface           = "ide2"
    vendor_data_file_id = local.vendor_snippet

    dns {
      domain  = local.vm_searchdomain
      servers = [local.vm_nameserver]
    }

    ip_config {
      ipv4 {
        address = "${local.monitor_ip}/24"
        gateway = local.vm_gateway
      }
    }

    user_account {
      username = local.vm_user
      keys     = [local.vm_ssh_pubkey]
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "ansible_host" "monitor" {
  name   = proxmox_virtual_environment_vm.monitor.name
  groups = ["lab"]
  # User and SSH key come from the lab group vars in inventory.yml.
  variables = {
    ansible_host = local.monitor_ip
  }
}
