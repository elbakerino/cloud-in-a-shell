# Loadbalancer HAProxy

(centos)

```bash
./ssh/forbid-pw-access.sh
./recipes/loadbalancer-haproxy.sh

# check with stats: 1.2.3.4:8080/stats
# secure stats, asks for new password:
./haproxy/stats-secure.sh <username>

# includes firewall config for http/https and stats
# requires manual monitoring scraper setup at monit-master
# does not setup ssl

# setup ssl:
./certbot/install-haproxy-certbot.sh example hostmaster@example.org balancer.example.org

# uncomment the marked lines in `/etc/haproxy/haproxy.cfg`
vi /etc/haproxy/haproxy.cfg
systemctl restart haproxy

# check with ssl stats: https://balancer.example.org:8080/stats

# add more ssl to an already/new cert:
./certbot/install-haproxy-certbot.sh <cert-name> <email> <new-domain> 
```
