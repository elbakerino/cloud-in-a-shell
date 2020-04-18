#!/bin/bash

apt update && apt upgrade -y && apt install -yq --no-install-recommends ufw \
  software-properties-common lsb-release \
  apt-transport-https ca-certificates

ufw allow 21
ufw allow out 20/tcp
ufw allow 22
ufw --force enable

apt update

apt install -yq --no-install-recommends \
  gcc binutils \
  wget curl \
  htop \
  make python3 python3-pip supervisor \
  unattended-upgrades uuid-runtime

# yaml editor for bash
apt-add-repository ppa:rmescandon/yq -y

apt-add-repository universe -y # universe is also needed by certbot
# certbot may fail at debian, but `certbot` is included
apt-add-repository ppa:certbot/certbot -y

wget -O /etc/apt/trusted.gpg.d/apache2.gpg https://packages.sury.org/apache2/apt.gpg
apt-add-repository ppa:ondrej/apache2 -y

wget -O /etc/apt/trusted.gpg.d/nginx.gpg https://packages.sury.org/nginx/apt.gpg
apt-add-repository ppa:ondrej/nginx -y

wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
apt-add-repository ppa:ondrej/php -y

apt update

apt install -yq --no-install-recommends \
  git \
  openssl \
  locales \
  zip unzip \
  yq # yaml processor

apt install -yq --no-install-recommends \
  bzip2 arj nomarch lzop `# compression libs` \
  libmcrypt4 libpcre3-dev `# php cryptography dependencies` \
  zlib1g-dev libxml2-dev libonig-dev # imagick/gd dependencies

# Setup Unattended Security Updates
echo "Setup Unattended Security Updates"
cat >/etc/apt/apt.conf.d/50unattended-upgrades <<EOF
Unattended-Upgrade::Allowed-Origins {
"Ubuntu bionic-security";
};
Unattended-Upgrade::Package-Blacklist {
//
};
EOF

cat >/etc/apt/apt.conf.d/10periodic <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
echo " ✓ Ubuntu Basics"
INSTALLED_UBUNTU_BASICS=true
sed -i "s/INSTALLED_UBUNTU_BASICS=false/INSTALLED_UBUNTU_BASICS=true/" ${DIR_CUR}/../../state_init.sh
