#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

touch ~/.bash_profile
touch ~/.ssh/environment

cat <<EOF >>~/.bash_profile
SSH_ENV="\$HOME/.ssh/environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "\${SSH_ENV}"
    echo succeeded
    chmod 600 "\${SSH_ENV}"
    . "\${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "\${SSH_ENV}" ]; then
    . "\${SSH_ENV}" > /dev/null
    #ps \${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep \${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi
EOF

source ~/.bash_profile

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
SETUP_SSH_AGENT=true
sed -i "s/SETUP_SSH_AGENT=false/SETUP_SSH_AGENT=true/" ${DIR_CUR}/../../state_init.sh
