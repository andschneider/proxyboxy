.PHONY: lint
lint:
	ansible-lint *.yml

clean-vm: inventory clean.yml
	ansible-playbook -i inventory clean.yml -Kb -v

harbor: inventory harbor.yml
	@mkdir -p /home/andrew/harbor
	ansible-playbook -i inventory harbor.yml -Kb -v
	@sudo cp /home/andrew/harbor/ca.crt /usr/local/share/ca-certificates/ca.crt
	@sudo update-ca-certificates
	@sudo systemctl restart docker.service
