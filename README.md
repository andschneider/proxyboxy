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

- [ ] use https
- [ ] check that rebooting server doesn't kill harbor
- [ ] check docker and docker-compose restart and http docker login works
- [ ] convert files to templates and use IP address as variable

```bash
ansible-playbook -i inventory harbor.yml -Kb -v
```
