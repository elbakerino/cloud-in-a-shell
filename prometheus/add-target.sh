#!/bin/bash

# todo: dynamic group by `job_name`

echo "Adding new monitoring targets to default group"
# todo: add duplicate check

for arg; do
  NEW_YML=$(yq w /etc/prometheus/prometheus.yml "scrape_configs[0].static_configs[0].targets[+]" "${arg}")
  cat >/etc/prometheus/prometheus.yml <<EOF
${NEW_YML}
EOF
   echo " ✓ Added ${arg}"
done

echo ""
echo "New Prometheus Targets:"
yq r /etc/prometheus/prometheus.yml 'scrape_configs[0].static_configs[0].targets'

echo "Restarting Prometheus"
systemctl restart prometheus
echo "Restarted Prometheus"

systemctl status prometheus
