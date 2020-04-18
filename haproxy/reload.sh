#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

# write current backend state to file and reloads haproxy, persisting e.g. added server-template servers
(echo "show servers state" | socat stdio /var/run/haproxy.sock > /etc/haproxy/haproxy.state) && systemctl reload-or-restart haproxy

echo ""
