FROM alpine:3.12

RUN apk add --no-cache ansible openssh

WORKDIR /app
ENV ANSIBLE_HOST_KEY_CHECKING=False

COPY inventory .
COPY reboot.yml .

ENTRYPOINT ["ansible-playbook", "-i", "inventory", "reboot.yml"]
CMD []

