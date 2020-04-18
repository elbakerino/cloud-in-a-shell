#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

DO_REDO=false

POSITIONAL=()
while [ "$1" != "" ]; do
  PARAM=$(echo $1 | awk -F= '{print $1}')
  VALUE=$(echo $1 | awk -F= '{print $2}')
  DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
  case $PARAM in
  --redo)
    DO_REDO=true
    ;;
  *)
    POSITIONAL+=("$1") # save it in an array for later
    ;;
  esac
  shift
done
set -- "${POSITIONAL[@]}"

if [[ ${INSTALLED_PROMETHEUS_EXPORTER_STATSD} != true || ${DO_REDO} = true ]]; then
  echo "Installing Prometheus StatsD Exporter"

  useradd -rs /bin/false statsd_exporter

  V_STATSD_EXPORTER=0.13.0
  wget https://github.com/prometheus/statsd_exporter/releases/download/v${V_STATSD_EXPORTER}/statsd_exporter-${V_STATSD_EXPORTER}.linux-amd64.tar.gz
  tar xvf statsd_exporter-${V_STATSD_EXPORTER}.linux-amd64.tar.gz
  cp statsd_exporter-${V_STATSD_EXPORTER}.linux-amd64/statsd_exporter /usr/local/bin
  chown statsd_exporter:statsd_exporter /usr/local/bin/statsd_exporter
  rm -rf statsd_exporter-${V_STATSD_EXPORTER}.linux-amd64.tar.gz statsd_exporter-${V_STATSD_EXPORTER}.linux-amd64
  if ! test -f "/usr/local/bin/statsd_exporter"; then
    echo " X Download or installation failed"
    exit
  fi
fi

touch /var/run/statsd_exporter.yml
chown statsd_exporter:statsd_exporter /var/run/statsd_exporter.yml

# todo: switch config/multiple exporter configs
cat >/var/run/statsd_exporter.yml <<EOF

EOF

touch /etc/systemd/system/statsd_exporter.service
cat >/etc/systemd/system/statsd_exporter.service <<EOF
[Unit]
Description=Prometheus StatsD exporter.
Documentation=https://github.com/prometheus/statsd_exporter
After=network.target

[Service]
#EnvironmentFile=-/etc/default/statsd_exporter
User=statsd_exporter
Group=statsd_exporter
ExecStart=/usr/local/bin/statsd_exporter \
    --web.listen-address=0.0.0.0:9102 \
    --statsd.mapping-config=/var/run/statsd_exporter.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start statsd_exporter
systemctl enable statsd_exporter

echo " > allow port 9102 for prometheus master"

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
echo " ✓ Prometheus StatsD Exporter"
INSTALLED_PROMETHEUS_EXPORTER_STATSD=true
sed -i "s/INSTALLED_PROMETHEUS_EXPORTER_STATSD=false/INSTALLED_PROMETHEUS_EXPORTER_STATSD=true/" ${DIR_CUR}/../../state_init.sh
