# Ansible and ansible-lint come from uv.lock (pyproject.toml); `uv run` sets
# up .venv on first use.
.PHONY: lint
lint:
	uv run ansible-lint .

###############################
###           PVE           ###
###############################
.PHONY: pve-post
pve-post: inventory.yml playbooks/post-install.yml
	uv run ansible-playbook -i inventory.yml playbooks/post-install.yml --ask-pass -v

.PHONY: pve-template
pve-template: inventory.yml playbooks/template.yml
	uv run ansible-playbook -i inventory.yml playbooks/template.yml --ask-pass -v

###############################
###           Lab           ###
###############################
# Terraform-managed VMs come from the second inventory (terraform). Fail if
# it can't be read, rather than quietly running without those hosts.
LAB_INVENTORY = -i inventory.yml -i terraform-inventory.yml
postgres monitoring files brewstack: export ANSIBLE_INVENTORY_UNPARSED_FAILED = True

# Prompts for the vault password only once a host has a vault.yml.
.PHONY: postgres
postgres: inventory.yml playbooks/postgres.yml
	uv run ansible-playbook $(LAB_INVENTORY) playbooks/postgres.yml -v \
		$(if $(wildcard host_vars/postgres/vault.yml),--ask-vault-pass)

# --ask-pass is for root on pr3; lab VMs use the SSH key.
.PHONY: monitoring
monitoring: inventory.yml playbooks/monitoring.yml
	uv run ansible-playbook $(LAB_INVENTORY) playbooks/monitoring.yml --ask-pass -v \
		$(if $(wildcard host_vars/*/vault.yml),--ask-vault-pass)

.PHONY: files
files: inventory.yml playbooks/files.yml
	uv run ansible-playbook $(LAB_INVENTORY) playbooks/files.yml --ask-vault-pass -v

.PHONY: brewstack
brewstack: inventory.yml playbooks/brewstack.yml
	uv run ansible-playbook $(LAB_INVENTORY) playbooks/brewstack.yml -v

.PHONY: pve-backup
pve-backup: inventory.yml playbooks/backup.yml
	uv run ansible-playbook -i inventory.yml playbooks/backup.yml --ask-pass -v
