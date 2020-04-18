#!/bin/bash

# - server performance
if test -z "${1}"
then
    CORES=1
    # CORES=$(nproc)
else
    CORES=${1}
fi

if (( ${CORES} > 2 )); then
  StartServers=$(expr ${CORES} '/' 2)
  # Server Limit incl. float conversion:
  ServerLimit=$(echo "1.5*${CORES}" | bc)
  ServerLimit=${ServerLimit%.*}
  ThreadsPerChild=64
  # must be the same as ThreadsPerChild
  ThreadLimit=64
else
  StartServers=1
  ServerLimit=2
  #ServerLimit=$(expr 2 '*' ${CORES})
  ThreadsPerChild=$(expr 24 '*' ${CORES})
  # must be the same as ThreadsPerChild
  ThreadLimit=$(expr 24 '*' ${CORES})
fi

echo "Setup Apache Performance"
echo "  Actual Cores:        $(nproc)"
echo "  Setup Cores:         ${CORES}"
echo "  StartServers:        ${StartServers}"
echo ""
echo "  ServerLimit:         ${ServerLimit} *"
echo "  ThreadsPerChild:     ${ThreadsPerChild}"
echo "  = MaxRequestWorkers: $(expr ${ThreadsPerChild} '*' ${ServerLimit})"

cat >/etc/apache2/mods-enabled/mpm_event.conf <<EOF
# event MPM
# StartServers: initial number of server processes to start
# MinSpareThreads: minimum number of worker threads which are kept spare
# MaxSpareThreads: maximum number of worker threads which are kept spare
# ThreadsPerChild: constant number of worker threads in each server process
# MaxRequestWorkers: maximum number of worker threads
# MaxConnectionsPerChild: maximum number of requests a server process serves
<IfModule mpm_event_module>
    StartServers             ${StartServers}
    ServerLimit              ${ServerLimit}
    ThreadsPerChild          ${ThreadsPerChild}
    # should be the same as ThreadsPerChild
    ThreadLimit              ${ThreadLimit}
    MaxRequestWorkers        $(expr ${ThreadsPerChild} '*' ${ServerLimit})

    # MinSpareThreads          25
    # MaxSpareThreads          75
    # not needed to set manually, default to "ServerLimit x ThreadsPerChild", but we set it to not get warnings with "apache2ctl -S"
    # MaxRequestWorkers        100
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOF

echo " !> execute manually: systemctl restart apache2"
