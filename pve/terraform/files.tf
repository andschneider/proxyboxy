# Was created by pve/vms.yml. Moved to Terraform by destroying it by hand
# (`qm destroy 101 --purge`) and letting Terraform clone a fresh one.
locals {
  files_ip = "10.20.0.101"
}

resource "proxmox_virtual_environment_vm" "files" {
  name      = "files"
  node_name = local.node_name
  vm_id     = 101
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
    dedicated = 2048
  }

  operating_system {
    type = "l26"
  }

  scsi_hardware = "virtio-scsi-single"
  boot_order    = ["scsi0"]

  disk {
    datastore_id = "fast"
    interface    = "scsi0"
    size         = 32
    file_format  = "raw"
    discard      = "on"
    iothread     = true
    ssd          = true
  }

  # The share (files.yml finds it by its scsi1 by-id name). Left out of
  # vzdump backups for now.
  disk {
    datastore_id = "tank"
    interface    = "scsi1"
    size         = 200
    file_format  = "raw"
    discard      = "on"
    iothread     = true
    ssd          = true
    backup       = false
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
        address = "${local.files_ip}/24"
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

resource "ansible_host" "files" {
  name   = proxmox_virtual_environment_vm.files.name
  groups = ["lab"]
  # User and SSH key come from the lab group vars in inventory.yml.
  variables = {
    ansible_host = local.files_ip
  }
}
