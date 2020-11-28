.PHONY: lint
lint:
	ansible-lint *.yml

clean-vm: inventory clean.yml
	ansible-playbook -i inventory clean.yml -Kb -v

get-harbor-certs:
	scp 192.168.17.170:/harbor/certs/ca.crt ./roles/k8s/files/ca.crt

install-harbor: inventory harbor.yml
	ansible-playbook -i inventory harbor.yml -Kb -v

harbor: install-harbor  get-harbor-certs
	@sudo cp ./roles/k8s/files/ca.crt /usr/local/share/ca-certificates/ca.crt
	@sudo update-ca-certificates
	@sudo systemctl restart docker.service
