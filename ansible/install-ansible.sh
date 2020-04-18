#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

DO_REDO=false

while [ "$1" != "" ]; do
  PARAM=$(echo $1 | awk -F= '{print $1}')
  VALUE=$(echo $1 | awk -F= '{print $2}')
  DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
  case $PARAM in
  --redo)
    DO_REDO=true
    ;;
  *)
    # ignoring unkown
    printf ""
    ;;
  esac
  shift
done

if [[ ${INSTALLED_ANSIBLE} != true || ${DO_REDO} = true ]]; then
  #

  if [ ${OS} = "Ubuntu" ]; then
    apt-add-repository -y --update ppa:ansible/ansible
    apt update
    apt install ansible -y
  elif [ ${OS} = "CentOS" ]; then
    # todo
    echo "todo"
    exit 1
  fi

  touch /var/lib/ansible/hosts
  cat >/var/lib/ansible/hosts <<EOF
[develop]
10.0.0.2
10.0.0.3
10.0.0.4
10.0.0.7
EOF

  #touch /var/lib/ansible/ansible.cfg
  #cat >/var/lib/ansible/ansible.cfg <<EOF
#[defaults]
#inventory=hosts
#EOF

  #chown -R ansible:ansible /var/lib/ansible
fi

#systemctl daemon-reload
#systemctl start consul
#systemctl enable consul

echo " ✓ Installed + Enabled Ansible"
INSTALLED_ANSIBLE=true
updateState "INSTALLED_ANSIBLE"
