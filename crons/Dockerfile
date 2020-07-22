FROM ubuntu:18.04

RUN apt update && apt -y upgrade && \
    apt install -y software-properties-common && \
    apt-add-repository --yes --update ppa:ansible/ansible && \
    apt install -y ansible

WORKDIR /app
ENV ANSIBLE_HOST_KEY_CHECKING=False

COPY inventory .
COPY reboot.yml .

ENTRYPOINT ["ansible-playbook", "-i", "inventory", "reboot.yml"]
CMD []

