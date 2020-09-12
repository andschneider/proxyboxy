# proxyboxy

proxmox

## clean 

Used to reset a fresh VM clone.

```bash
ansible-playbook -i inventory clean.yml -Kb -v
```

## harbor

Install Harbor container registry on a VM.

### TODO

- [X] use https
- [X] check that rebooting server doesn't kill harbor
- [ ] convert files to templates and use host as variable (create-certs.sh, harbor-template.yml)
- [ ] create a system service for harbor docker-compose file
- [ ] add scanning capabilities
- [ ] copy back ca.crt to client

Copy ca.crt to local client machine which needs to use Harbor.
```bash
get /tmp/certs/ca.crt
sudo mv ca.crt /usr/local/share/ca-certificates/ca.crt
sudo update-ca-certificates
sudo systemctl restart docker.service
```

```bash
ansible-playbook -i inventory harbor.yml -Kb -v
```

## proxmox vm clone

Clone a template and create a new VM.

### TODO 

- [ ] clean up inventory and variables
- [ ] make sure templates have guest agent installed (cleanup templates)
- [ ] fix DNS issue
- [ ] setup vault for password
- [ ] clean up ssh password usage (set default private key or something)
- [ ] create a stop and remove playbook

```bash
ansible-playbook -i clone-inventory create-vm.yml -Kbv --ask-pass
```

### linting

Linting is done using `ansible-lint`, which can be pip installed.

- [ ] Add Github action to run linting
