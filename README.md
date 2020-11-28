# proxyboxy

proxmox

## clean 

Used to reset a fresh VM clone.

```bash
make clean-vm
```

## harbor

Install Harbor container registry on a VM with `make harbor`.

To download the cert to the local machine, use `make get-harbor-certs`. See the Makefile for how to update Docker to use it.

### TODO

- [X] use https
- [X] check that rebooting server doesn't kill harbor (it does)
- [X] create a system service for harbor docker-compose file
- [X] copy back ca.crt to client
- [X] convert files to templates and use host as variable (create-certs.sh, harbor-template.yml)
- [ ] convert shell script to task
- [X] add scanning capabilities
- [ ] setup replication to GCR
- [ ] use the cert with k8s nodes

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

## postgres

```bash
ansible-playbook -i inventory postgres.yml -Kb -v
```

### TODO

- [ ] ensure options are set correctly (localization, ect.)

### linting

Linting is done using `ansible-lint`, which can be pip installed.

- [ ] Add Github action to run linting
