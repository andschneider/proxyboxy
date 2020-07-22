#!/bin/bash

HOST=influx
USER=andrew
KEY=~/.ssh/pri/ssh-privatekey

ansible -i inventory $HOST -a "/sbin/reboot" -u $USER --key-file $KEY
