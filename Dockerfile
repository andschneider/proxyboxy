FROM ubuntu:18.04

RUN apt update && apt -y upgrade && \
    apt install -y software-properties-common && \
    apt-add-repository --yes --update ppa:ansible/ansible && \
    apt install -y ansible

# CMD ["/usr/bin/ansible", "--version"]

# TODO the entrypoint command works when run normally exec'd into a container
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh
ENTRYPOINT ["ssh-keyscan", "192.168.1.210", ">", "/root/.ssh/known_hosts"]
CMD ["ssh", "-i", "~/.ssh/pri/ssh-privatekey", "andrew@192.168.1.210"]

