# Shared VM settings, matching the vm_* defaults in host_vars/pr3.yml.
locals {
  node_name       = "pr3"
  lab_bridge      = "vmbr1"
  vm_gateway      = "10.20.0.1"
  vm_nameserver   = "192.168.1.6"
  vm_searchdomain = "lab.andschneider.net"
  vm_user         = "ubuntu"
  vm_ssh_pubkey   = trimspace(file(pathexpand("~/.ssh/homelab_ed25519.pub")))
  vendor_snippet  = "iso:snippets/vendor-base.yaml"
}
