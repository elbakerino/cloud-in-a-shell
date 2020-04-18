#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

dnf install dnf-utils -y

cat >/etc/yum.repos.d/nginx.repo <<EOF
[nginx-stable]
name=nginx stable repo
# todo: enable automatic releasever when working in centos0
# baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
baseurl=http://nginx.org/packages/centos/8/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
# todo: enable automatic releasever when working in centos0
# baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
baseurl=http://nginx.org/packages/mainline/centos/8/x86_64/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF

yum-config-manager --enable nginx-mainline

dnf install nginx -y

systemctl start nginx
systemctl enable nginx

echo " ✓ Installed + Enabled NGINX"
INSTALLED_NGINX=true
updateState "INSTALLED_NGINX"
