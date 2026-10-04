# pve

Fresh Proxmox VE 9 install on `pr3.lab.andschneider.net` (192.168.1.7).

## Disk layout

| Disk                  | by-id                                | Use                                      |
|-----------------------|--------------------------------------|------------------------------------------|
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
