# pve

Fresh Proxmox VE 9 install on `pr3.lab.andschneider.net` (10.10.0.7, `lab-mgmt` VLAN 10).

## Network

VLANs live on the UDM Pro. The switch can't tag, so each network gets its own untagged port: `vmbr0`
(`nic0`) is on `lab-mgmt` and carries pr3's address; `vmbr1` (`nic2`, 10G) is on `lab` with no host
address, and VMs attach to it untagged.

| VLAN           | Subnet         | Hosts                                        |
| -------------- | -------------- | -------------------------------------------- |
| 10, `lab-mgmt` | `10.10.0.0/24` | pr3 `10.10.0.7`, BMC `10.10.0.8`; no DHCP    |
| 20, `lab`      | `10.20.0.0/24` | VMs; DHCP `.10`–`.99`, statics `.100`–`.254` |

## Disk layout

| Disk                  | by-id                                | Use                                      |
| --------------------- | ------------------------------------ | ---------------------------------------- |
| Samsung 970 EVO 500GB | `nvme-Samsung_SSD_970_EVO_500GB_...` | Boot/OS (ext4, installer)                |
| 2x WD SN750 1TB       | `nvme-WDS100T3X0C-00SJG0_*`          | `fast` ZFS mirror (VMs)                  |
| 2x Crucial MX500 2TB  | `ata-CT2000MX500SSD1_*`              | `tank` ZFS mirror (VMs)                  |
| Seagate IronWolf 4TB  | `ata-ST4000VN008-2DR166_ZGY73D0C`    | `backup` ZFS pool (vzdump)               |
| Crucial MX500 1TB     | `ata-CT1000MX500SSD1_2052E4E1E9BB`   | `scratch` ZFS pool (throwaway VMs, ISOs) |

## Post-install playbook

```bash
make pve-post
```

What it does:

- Swaps enterprise repos for `pve-no-subscription` and runs a full upgrade
- Caps journald at 200M and disables HA services (single node) to cut boot SSD writes
- Caps ZFS ARC at 16 GiB
- Creates the `fast`, `tank`, `backup` and `scratch` pools
- Adds PVE storage: `fast`, `tank`, `scratch` (VM disks), `backup` (vzdump, with pruning) and `iso`
  (ISOs/templates on `scratch/iso`)
- Restricts `local` to ISOs, templates and snippets
- Configures smartd self-tests and email alerts
- Creates `ansible@pve` with an API token, saved to `pve/secrets/` (gitignored)

Run only some parts with tags:

```bash
ansible-playbook -i pve/inventory.yml pve/post-install.yml --ask-pass --tags zfs,storage
```

## VMs

VMs are Ubuntu 26.04 clones of a cloud-init template, on the `lab` VLAN with static IPs. Log in as
`ubuntu` with `~/.ssh/homelab_ed25519`. VMID matches the last IP octet: `.100`–`.109` are core
services (monitor, files), `.110` and up are apps and databases.

```bash
make pve-template   # download the cloud image and build template 9000
make pve-vms        # create any VMs in pve_vms (host_vars/pr3.yml) that don't exist yet
```

| VM       | VMID | IP            | Storage |
| -------- | ---- | ------------- | ------- |
| postgres | 110  | `10.20.0.110` | `fast`  |

### postgres

PostgreSQL from the PGDG repo, reachable from `lab` and the home LAN with password auth.

- Settings, allowed networks, roles and databases are in `host_vars/postgres/vars.yml`.
- Role passwords go in an ansible-vault encrypted `host_vars/postgres/vault.yml`.
- Needs the `community.postgresql` collection (bundled with the full `ansible` package; otherwise
  `ansible-galaxy collection install -r pve/requirements.yml`).

```bash
make postgres
```
