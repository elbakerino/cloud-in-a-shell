#!/bin/bash

dnf install tar \
  wget curl \
  git openssl \
  zip unzip \
  firewalld \
  openssl-devel systemd-devel -y

systemctl enable firewalld
systemctl start firewalld
