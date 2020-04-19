#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

# from: https://www.haproxy.com/blog/truly-seamless-reloads-with-haproxy-no-more-hacks/#8-proving-the-solution
# but added '-x [socket_file]', as this is also used during enabling hitless reloads
haproxy -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid -sf $(cat /run/haproxy.pid) -x /var/run/haproxy.sock

# write current backend state to file and reloads haproxy, persisting e.g. added server-template servers
#(echo "show servers state" | socat stdio /var/run/haproxy.sock > /etc/haproxy/haproxy.state) && systemctl reload-or-restart haproxy

echo ""
