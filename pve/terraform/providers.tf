terraform {
  required_version = ">= 1.5.0"

  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.5.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.116.0"
    }
  }
}

# Reuses the ansible@pve!automation token from pve/tasks/api-token.yml.
locals {
  pve_token = jsondecode(file("${path.module}/../secrets/pr3-ansible-token.json"))
}

provider "proxmox" {
  endpoint  = "https://10.10.0.7:8006/"
  api_token = "${local.pve_token["full-tokenid"]}=${local.pve_token.value}"
  # PVE's self-signed cert.
  insecure = true
}
