#!/bin/bash

read -sp "Enter the public key to authorize: " ssh_key_pub

comment=$(echo "${ssh_key_pub}" | cut -f3 -d' ' | sed -e 's/ //g')

if test -z "${ssh_key_pub}"; then
  echo "#! Empty SSH Key"
  exit 1
fi

tmp=$(echo ${ssh_key_pub} >>~/.ssh/authorized_keys)

systemctl restart ssh

echo " ✓ Allowed SSH key ${comment}"
