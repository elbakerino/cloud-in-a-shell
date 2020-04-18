#!/bin/bash

#
# Usage: ./key-gen.sh bitbucketbot <pass>
#

KEY_NAME=${1}

ssh-keygen -b 4096 -C "${KEY_NAME}" -t rsa -f ~/.ssh/${KEY_NAME} -q -N "${2}"

touch ~/.bash_profile

cat <<EOF >>~/.bash_profile
ssh-add -k ~/.ssh/${KEY_NAME}
EOF

source ~/.bash_profile

echo " ✓ Added SSH key ${KEY_NAME}:"

cat ~/.ssh/${KEY_NAME}.pub
