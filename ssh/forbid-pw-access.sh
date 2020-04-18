#!/bin/bash

sed -i "s/#PasswordAuthentication .*/PasswordAuthentication no/" /etc/ssh/sshd_config &&
  sed -i "s/#ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/" /etc/ssh/sshd_config &&
  sed -i "s/#UsePAM .*/UsePAM no/" /etc/ssh/sshd_config &&
  service ssh restart

echo " ✓ Forbidden PW Login, only SSH Cert login allowed"
