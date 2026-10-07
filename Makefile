.PHONY: lint
lint:
	ansible-lint *.yml

clean-vm: inventory clean.yml
	ansible-playbook -i inventory clean.yml -Kb -v

###############################
###         Harbor          ###
###############################
.PHONY: get-harbor-certs install-harbor harbor
HARBOR_HOST=192.168.17.170

get-harbor-certs:
	scp ${HARBOR_HOST}:/harbor/certs/ca.crt ./roles/k8s/files/ca.crt

install-harbor: inventory harbor.yml
	ansible-playbook -i inventory harbor.yml -Kb -v

harbor: install-harbor  get-harbor-certs
	@sudo cp ./roles/k8s/files/ca.crt /usr/local/share/ca-certificates/ca.crt
	@sudo update-ca-certificates
	@sudo systemctl restart docker.service

###############################
###           K8S           ###
###############################
k8s: inventory k8s.yml
	ansible-playbook -i inventory k8s.yml -Kb -v

###############################
###           PVE           ###
###############################
.PHONY: pve-post
pve-post: pve/inventory.yml pve/post-install.yml
	ansible-playbook -i pve/inventory.yml pve/post-install.yml --ask-pass -v

.PHONY: pve-template
pve-template: pve/inventory.yml pve/template.yml
	ansible-playbook -i pve/inventory.yml pve/template.yml --ask-pass -v

###############################
###           Lab           ###
###############################
# Terraform-managed VMs come from the second inventory (pve/terraform). Fail if
# it can't be read, rather than quietly running without those hosts.
LAB_INVENTORY = -i pve/inventory.yml -i pve/terraform-inventory.yml
export ANSIBLE_INVENTORY_UNPARSED_FAILED = True

# Prompts for the vault password only once a host has a vault.yml.
.PHONY: postgres
postgres: pve/inventory.yml pve/postgres.yml
	ansible-playbook $(LAB_INVENTORY) pve/postgres.yml -v \
		$(if $(wildcard pve/host_vars/postgres/vault.yml),--ask-vault-pass)

# --ask-pass is for root on pr3; lab VMs use the SSH key.
.PHONY: monitoring
monitoring: pve/inventory.yml pve/monitoring.yml
	ansible-playbook $(LAB_INVENTORY) pve/monitoring.yml --ask-pass -v \
		$(if $(wildcard pve/host_vars/*/vault.yml),--ask-vault-pass)

.PHONY: files
files: pve/inventory.yml pve/files.yml
	ansible-playbook $(LAB_INVENTORY) pve/files.yml --ask-vault-pass -v

.PHONY: pve-backup
pve-backup: pve/inventory.yml pve/backup.yml
	ansible-playbook -i pve/inventory.yml pve/backup.yml --ask-pass -v
