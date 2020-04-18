# Webserver Apache + PHP

(ubuntu)

```bash
./ssh/forbid-pw-access.sh
./recipes/webspace-apache-php.sh

# requires manual monitoring scraper setup at monit-master
# firewall config for http/https not included
# does not setup ssl
```

## Single-Server Apache + PHP

```bash
# allow 80/443 in firewall
ufw allow 80
ufw allow 443

# setup default server page:
./apache/vhost-default.sh
./tool/server-page.sh

# create new custom vhost, with the folder name `example` and the main domain `example.org` (change those with yours!)
./apache/vhost-create.sh example example.org
./tool/server-page.sh example

# install lets encrypts certbot
./certbot/install-apache-certbot.sh
# create certificates
./apache/vhost-ssl-secure.sh example hostmaster@example.com
./apache/vhost-ssl-redir.sh example # force non-ssl to ssl redir for all

# or manual certbot management:
certbot run --apache -n -d example.org --agree-tos -m hostmaster@example.com
certbot renew --dry-run # check automatic renew of certification
```

## Loadbalanced Apache + PHP

Allow access to port 80 only from loadbalancer in firewall, replace `10.0.0.2` with the ip of your loadbalancer
 
```bash
ufw allow from 10.0.0.2 to any port 80
```
