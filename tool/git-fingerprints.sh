#!/bin/bash

mkdir -p ~/.ssh-hosts
cat >~/.ssh-hosts/githubKey <<EOF
$(ssh-keyscan github.com)
EOF
cat >~/.ssh-hosts/githubKey.sig <<EOF
$(ssh-keygen -lf ~/.ssh-hosts/githubKey)
EOF

cat >~/.ssh-hosts/bitbucketKey <<EOF
$(ssh-keyscan bitbucket.org)
EOF
cat >~/.ssh-hosts/bitbucketKey.sig <<EOF
$(ssh-keygen -lf ~/.ssh-hosts/bitbucketKey)
EOF

if [[ "$(tail ~/.ssh-hosts/bitbucketKey.sig)" == "2048 SHA256:zzXQOXSRBEiUtuE8AikJYKwbHaxvSc0ojez9YXaGp1A bitbucket.org (RSA)" ]]; then
  echo "✓ Bitbucket key is valid.."
  tail ~/.ssh-hosts/bitbucketKey >>~/.ssh/known_hosts
  echo "added to known_hosts."
else
  echo "❌ Bitbucket key is invalid."
fi

if [[ "$(tail ~/.ssh-hosts/githubKey.sig)" == "2048 SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8 github.com (RSA)" ]]; then
  echo "✓ Github key is valid..."
  tail ~/.ssh-hosts/githubKey >>~/.ssh/known_hosts
  echo "added to known_hosts."
else
  echo "❌ Github key is invalid."
fi

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
SETUP_GIT_FINGERPRINTS=true
sed -i "s/SETUP_GIT_FINGERPRINTS=false/SETUP_GIT_FINGERPRINTS=true/" ${DIR_CUR}/../../state_init.sh
