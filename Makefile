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
