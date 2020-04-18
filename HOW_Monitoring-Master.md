# Monitoring Master

(ubuntu)

```bash
./ssh/forbid-pw-access.sh
./recipes/monitoring-master.sh

# includes firewall configs
# does not setup ssl

# custom prometheus basic auth, asks for password
htpasswd -c /etc/prometheus/.credentials <user>

./grafana/config-nginx.sh <grafana-host>
./prometheus/config-nginx.sh <prometheus-host>

# ssl, first install certbot, then create certs, '-n = non-interactive':
./certbot/install-nginx-certbot.sh
certbot run --nginx -n -d <grafana-host -d <prometheus-host> --agree-tos -m hostmaster@example.com
```
