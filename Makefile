# Ansible and ansible-lint come from uv.lock (pyproject.toml); `uv run` sets
# up .venv on first use.
.PHONY: lint
lint:
	uv run ansible-lint .

###############################
###           PVE           ###
###############################
.PHONY: pve-post
pve-post: inventory.yml post-install.yml
	uv run ansible-playbook -i inventory.yml post-install.yml --ask-pass -v

.PHONY: pve-template
pve-template: inventory.yml template.yml
	uv run ansible-playbook -i inventory.yml template.yml --ask-pass -v

###############################
###           Lab           ###
###############################
# Terraform-managed VMs come from the second inventory (terraform). Fail if
# it can't be read, rather than quietly running without those hosts.
LAB_INVENTORY = -i inventory.yml -i terraform-inventory.yml
postgres monitoring files brewstack: export ANSIBLE_INVENTORY_UNPARSED_FAILED = True

# Prompts for the vault password only once a host has a vault.yml.
.PHONY: postgres
postgres: inventory.yml postgres.yml
	uv run ansible-playbook $(LAB_INVENTORY) postgres.yml -v \
		$(if $(wildcard host_vars/postgres/vault.yml),--ask-vault-pass)

# --ask-pass is for root on pr3; lab VMs use the SSH key.
.PHONY: monitoring
monitoring: inventory.yml monitoring.yml
	uv run ansible-playbook $(LAB_INVENTORY) monitoring.yml --ask-pass -v \
		$(if $(wildcard host_vars/*/vault.yml),--ask-vault-pass)

.PHONY: files
files: inventory.yml files.yml
	uv run ansible-playbook $(LAB_INVENTORY) files.yml --ask-vault-pass -v

.PHONY: brewstack
brewstack: inventory.yml brewstack.yml
	uv run ansible-playbook $(LAB_INVENTORY) brewstack.yml -v

.PHONY: pve-backup
pve-backup: inventory.yml backup.yml
	uv run ansible-playbook -i inventory.yml backup.yml --ask-pass -v
