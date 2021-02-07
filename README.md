# proxyboxy

proxmox

## ansible setup

SSH keys - TODO

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

## k8s

The k8s playbook can be used to setup both worker nodes and master nodes. For both, the playbook installs and configures all the necessary dependencies and networking requirements. This is done in the `k8s` role, with tasks such as:

- static IP on ens18 for all
- DHCP on ens19 for workers
- installs kubeadm, kubectl 
- installs the Harbor cert
- disables swap

For master nodes, additional configuration is done using the `k8s_master` role:

- static IP on ens19
- DHCP server configuration
- cluster creation with kubeadm

To run both roles:

```bash
make k8s
```

### TODO

- [ ] configure Flannel for master node
- [ ] configure Metallb for master node
- [ ] don't apply the DHCP on ens19 to the master node in the `k8s` role

## postgres

```bash
ansible-playbook -i inventory postgres.yml -Kb -v
```

### TODO

- [ ] ensure options are set correctly (localization, ect.)

### linting

Linting is done using `ansible-lint`, which can be pip installed.

- [ ] Add Github action to run linting
