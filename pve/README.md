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
| monitor  | 100  | `10.20.0.100` | `fast`  |
| files    | 101  | `10.20.0.101` | `fast`  |
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

### monitor

Prometheus (`:9090`, 90 day retention) and Grafana (`:3000`) on `monitor`, scraping:

- `node_exporter` on pr3 and every lab VM (`:9100`). On pr3 the textfile collectors add SMART,
  NVMe and IPMI sensor metrics (fans, temps, voltages).
- `prometheus-pve-exporter` on pr3 (`:9221`), using a read-only `prometheus@pve` token whose secret
  stays on pr3.
- `postgres_exporter` on postgres (`:9187`), logging in with peer auth as `prometheus`.

The UDM rule `server-prometheus-scrape` must allow `10.20.0.100` to reach `10.10.0.7` on 9100 and
9221. Grafana starts with `admin`/`admin` and asks for a new password on first login.

Dashboards are provisioned into the Homelab folder and are read-only in the UI; use **Save as** to
make an editable copy. Community ones (Node Exporter Full, Proxmox, PostgreSQL) come from
grafana.com via `grafana_dashboards` in `host_vars/monitor.yml`. Our own live in
`files/grafana-dashboards/`: **pr3 hardware** shows fans, CPU, board and disk temperatures, SSD
wear, disk errors and ZFS pool state. To change one, edit a copy in Grafana, export it as JSON and
replace the file.

```bash
make pve-vms      # create the monitor VM
make monitoring
```

### files

One folder, `/srv/share`, on a 200 GB data disk on `tank`, shared over NFSv4 and SMB. Every client
acts as the `share` user (uid 2000), so files from Macs and Linux clients mix without permission
clashes.

- NFS (`files.lab.andschneider.net:/srv/share`) is open to the IPs in `share_nfs_clients` in
  `host_vars/files/vars.yml`, `lab` by default. Add LAN devices there by IP.
- SMB (`smb://files.lab.andschneider.net/share`) is open to `lab` and the home LAN, with user
  `share` and the password from `host_vars/files/vault.yml`.
- The data disk is only formatted when it's blank; the playbook never wipes it.

```bash
ansible-vault edit pve/host_vars/files/vault.yml     # vault_share_smb_password: ...
make pve-vms   # create the files VM
make files
```
