# Cloud in a Shell: Server Creation Helper

(bash) scripts for easy deployment of servers - run some scripts and launch!

Useful for single-server and small cluster with services on multiple servers: loadbalancer, computing units, file-server, database, monitoring and more.

🚧 WIP, just some scripts to have the most repeated code as documentation.

Tested/used on Ubuntu 18.04 LTS and CentOS 8 virtual cloud server.

- [Upload to Server](#upload-to-server)
- [Config](#config)
- [Tools](#tools)
    - [Ansible](#ansible)
    - [Apache](#apache-ubuntu)
    - [Certbot](#certbot-for-ssl--tls)
    - [Grafana](#grafana)
    - [HAProxy](#haproxy)
    - [Hetzner](#hetzner)
    - [MariaDB / MySQL](#mariadb--mysql)
    - [NGINX](#nginx)
    - [PHP](#php)
    - [Prometheus](#prometheus)
    - [SSH](#ssh)
    - [Extras](#extras)
- [Todos](#todos)
- [License](#license)
- [Special Thanks](#special-thanks)

## Recipes

Use these recipes for a full setup of specific service-servers, they just combine multiple other scripts:  

- [Webserver Apache + PHP](./HOW_Webserver-Apache-PHP.md)
- [DB Master MySQL](./HOW_DB-Master-MySQL.md)
- [Loadbalancer HAProxy](./HOW_Loadbalancer-HAProxy.md)
- [Monitoring Master](./HOW_Monitoring-Master.md)
- [Bastion Host](./HOW_Bastion-Host.md)

## Upload to Server

Pack this folder to `inits.tgz`, upload to server and unpack there. Uses `ssh-pageant` to determine SSH_AUTH_SOCK, tested on windows with putty-pageant.

```bash
npm i

npm run upload <host> <user> <remote_dir>
npm run upload 1.2.3.4 root /root

# open server terminal

# CentOS needs tar, Ubuntu has it
dnf install tar -y

# switch to upload dir, create target dir, unpack and allow execution:
# should display `on Ubuntu` or `on Centos` at the end:
cd /root && mkdir -p inits && tar xvf inits.tgz -C inits && cd inits && find . -type f -name "*.sh" -print0 | xargs -0 chmod u+x && ./_boot.sh
```

<details>
<summary>Further Unpack and Update Snippets</summary>
<br>

```bash
# in new dir
mkdir -p inits && tar xvf inits.tgz -C inits && cd inits && find . -type f -name "*.sh" -print0 | xargs -0 chmod u+x && ./_boot.sh

# in current dir
tar xvf inits.tgz && find . -type f -name "*.sh" -print0 | xargs -0 chmod u+x

# update in /root/inits
rm -rf /root/inits/ && cd /root && tar xvf inits.tgz -C inits && cd inits && find . -type f -name "*.sh" -print0 | xargs -0 chmod u+x

# only execution rights (in folder `inits`)
find . -type f -name "*.sh" -print0 | xargs -0 chmod u+x
```

</details>

## Config

A few things can be configured through the [conf.sh](./_boot/conf.sh).

Use `./conf-set.sh` for ease, copies default conf.sh up one folder if it not exists there.

```bash
./conf-set.sh \
    --php-mem-lim="1024M" \
    --php-max-upload="256M" \
    --php-timezone="UTC" \
    --php-max-req="60" \
    \
    --net-websrv="10.0.10.1" \
    --net-websrv-port="80" \
    \
    --net-monit="10.0.1.0" \
    --gw-monit="10.0.1.1" \
    \
    --net-service-discovery="10.0.2.0" \
    --gw-service-discovery="10.0.2.1" \
    --sd-nodes="10.0.0.2 10.0.2.3 10.0.2.4" \
    --sd-key="$(consul keygen)"

# when using single network for everything:
IP=10.0.0.0;./conf-set.sh --net-websrv="${IP}" --net-monit="${IP}" --net-service-discovery="${IP}";

# when using single gateway for everything:
IP=10.0.0.2;./conf-set.sh --net-monit="${IP}" --net-service-discovery="${IP}";
```

Without `conf-set.sh`:

```bash
# copy conf outside project
cp ./_boot/conf.sh ../
# then change variables there to overwrite defaults
vi ../conf.sh
```

*todo: update process of new conf vars*

## Scripts

These scripts contain the different setup, configuration or management logic for the different services.

### Basics

Includes basic packages which are used throughout the other scripts or are important for the most used features.

- `./tool/basics-ubuntu.sh`
- `./tool/basics-centos.sh`

### Ansible 

❌

- `./ansible/install-ansible.sh` (ubuntu)

### Apache (ubuntu)

- **install**: `./apache/install-apache.sh` (**relies on basics-ubuntu**)
    - firewall ports needs to be enabled manually
- **performance**: `./apache/conf-performance.sh [cores]`, configures mpm server limits based on cpu
    - `./apache/conf-performance.sh 1`, `./apache/conf-performance.sh 4`
    
Apache vhost management:

- **create**: `./apache/vhost-create.sh <vh-name> <server-name>`, creates a new vhost with the specified main server_name, *has todos*
- **create default**: `./apache/vhost-default.sh`, creates the catch all localhost vhost: `/var/www/vhosts/example` and config: `/etc/apache2/sites-available/example.conf`
- **disable**: `./apache/vhost-dis.sh <vh-name>`, disables the vhost
- **docroot change**: `./apache/vhost-docroot-change.sh <vh-name> <rel-path>`, changes the documentroot for the vhost
    - `./apache/vhost-docroot-change.sh example new_public`, changes the root from `/var/www/vhosts/example` to `/var/www/vhosts/example/new_public`
- **list**: `./apache/vhost-list.sh`, list infos about all configured vhosts
- **rm**: `./apache/vhost-rm.sh <vh-name>`, removes the vhost config at all, **deletes the config file!**
- **alias add**: `./apache/vhost-alias-add.sh <vh-name> <alias>`, add server_alias to vhost, includes duplicate check, *todo: duplicate check not includes main server_name*
    - `./apache/vhost-alias-add.sh example demo.example.org`, adds alias to vhost `/var/www/vhosts/example` and config: `/etc/apache2/sites-available/example.conf`
- **alias rm**: `./apache/vhost-alias-rm.sh <vh-name> <alias>`

Apache SSL (uses certbot):

- **ssl redir** on: `./apache/vhost-ssl-redir.sh <vh-name>`
- **ssl secure**: `./apache/vhost-ssl-secure.sh <vh-name> <notify-email> [<force>]`
    - enables/renews ssl security for already configured domains in the vhost
    - creates/updates a single certificate per vhost
    - enables vhost redirection with certbot
    - just rerun after added some alias or server to a config
    - `./apache/vhost-ssl-secure.sh example hostmaster@example.org`
    - `./apache/vhost-ssl-secure.sh example hostmaster@example.org 1`, for forcing renewing

### certbot for SSL / TLS

> Legal Notice for using certbot:
>
> Let’s Encrypt usage to provision TLS certificates oblige to the [Let’s Encrypt Subscriber Agreement(s) & Terms of Services](https://letsencrypt.org/repository/). You accept the terms by using the SSL scripts supplied by cloud-in-a-shell.

- **apache**: `./certbot/install-apache-certbot.sh` (**relies on basics-ubuntu**) (ubuntu)
    - for management use: `./apache-vhost-ssl-secure`
- **haproxy**: `./certbot/install-haproxy-certbot.sh <cert-name> <email> [<(new)-host>]`, installs certbot and setups certs, only installs when not installed
    - `./certbot/install-haproxy-certbot.sh example hostmaster@example.org`, creates or updates the cert `example.pem` with the warning email 
    - `./certbot/install-haproxy-certbot.sh example hostmaster@example.org demo.example.org`, creates or updates the cert `example.pem` with the warning email, adds the host `demo.example.org` to the hosts of the file
- **nginx**: `./certbot/install-nginx-certbot.sh` (ubuntu/centos) (**relies on basics-ubuntu**)
- **centos**: `./certbot/install-centos.sh` installs certbot-auto on centos

### Consul

❌

### Grafana

- **install**: `./grafana/install-grafana.sh` (ubuntu) (**relies on basics-ubuntu**)

### HAProxy

HAProxy is used as loadbalancer, these scripts work with an abstraction config which controls HAProxy and certbot.

Create the file `~/haproxy.conf` for the user running the scripts, the order is important for the ACL rules and the config vars must be set in the correct order (currently):

```text
[backendname1]
acl_host=example.org .example.org
ssl_domains=example.org www.example.org dev.example.org
maxconn=400
server=10.0.0.10:80 10.0.0.11:80
```

- **install**: `./haproxy/install-haproxy.sh` (centos) (**relies on basics-centos**)
- **reload**: `./haproxy/reload.sh`
- **(re-)configure**: `./haproxy/config-haproxy.sh [<ssl>]`, builds the `haproxy.cfg` from the `~/haproxy.conf`
    - configure with ssl on: `./haproxy/config-haproxy.sh ssl`
    - configure with ssl off: `./haproxy/config-haproxy.sh`
- **certs creation/update**: `./haproxy/cert-check.sh [<email>]`
    - uses the `~/haproxy.conf` and existing certs for the certbot commands
    - uses the backend_name as name of the cert
    - makes a HAProxy compatible cert from the certbot created cert

Servers:

- **list**: `./haproxy/server-list.sh`
- **add**: `./haproxy/server-add.sh`
- **drain**: `./haproxy/server-drain.sh`
- **enable**: `./haproxy/server-enable.sh`
- **disable**: `./haproxy/server-disable.sh`

Stats:

- **stats-secure**: `./haproxy/stats-secure.sh <username>`, secures the stats page with custom basic-auth credentials, (interactive)

Stats defaults to: `hostname:8080/stats` (or ip instead of host)

### Hetzner

- **float ip bind**: `./hetzner/floatip-bind.sh <ip4> [<ip6>]` (centos/ubuntu)

### MariaDB / MySQL

- **install**: `./mariadb/install-mariadb.sh`, (interactive)
- **user create**: `./mariadb/create-user.sh`, (interactive)
- **db create**: `./mariadb/create-db.sh`, (interactive)
- **remote allow**: `./mariadb/remote-allow.sh`
- **remote forbid**: `./mariadb/remote-forbid.sh`

### NGINX

❌

- **install**: `./nginx/install-nginx.sh` (centos)
- **server disable**: `./nginx/server-dis.sh`
- **server set**: `./nginx/server-set.sh`

### PHP

- **install**: `./php/install-php.sh`, installs php (7.4) and composer, (ubuntu) 
- **config cli**: `./php/php-cli.sh`, basic configuration for cli usage
- **config fpm**: `./php/php-fpm.sh`, basic configuration for fpm servers
    - currently optimized for apache usage / apache has mpm_event which controls fpm servers

### Prometheus

- **install**: `./prometheus/install-master.sh` install prometheus master and grafana, (ubuntu) 
- install exporter: 
    - **apache**: `./prometheus/exporter-apache.sh`, (ubuntu/centos)
    - **haproxy**: `./prometheus/exporter-haproxy.sh`, (ubuntu/centos) (*todo: fail after reboot, wrong owner of stats*)
    - **mysql/mariadb**: `./prometheus/exporter-mysql.sh`, (ubuntu/centos)
    - **system**: `./prometheus/exporter-node.sh`, (cpu, memory, network...), (ubuntu/centos)
    - **statsd**: `./prometheus/exporter-statsd.sh`, [statsd](https://github.com/statsd/statsd) a generic stats daemon, (ubuntu/centos) (*scribble*)
- master tools:
    - **target add**: `./prometheus/add-target.sh <target>`, add new scraper targets, (ubuntu)
        - `./prometheus-add-target.sh 10.0.0.2:9100 10.0.0.2:9100` supports multiple at once
        - *todo*: not adding already existing once
- exporter tools:
    - network tools allow scraper access from within configured `NET_MONIT`/24
    - **haproxy**: `./prometheus/network-haproxy.sh` 9101 (ubuntu/centos)
    - **statsd**: `./prometheus/network-statsd.sh` 9102 (ubuntu/centos)
    - **apache**: `./prometheus/network-apache.sh` 9117 (ubuntu/centos)
    - **mysql**: `./prometheus/network-mysql.sh` 9104 (ubuntu/centos)
    - **node**: `./prometheus/network-node.sh` 9100 (ubuntu/centos)

### SSH 

- `./ssh/agent-enable.sh`, register/enable SSH-Agent for all processes, enabling start at boot, (automatic) (ubuntu/centos)
- `./ssh/forbid-pw-access.sh`, forbid PW login, only cert login allowed, (ubuntu/centos)
- `./ssh/key-allow.sh`, allow access with a key, asks for the key, (interactive) (ubuntu/centos) (*todo: check duplicates*)
- `./ssh/key-gen.sh <name> [<pass>]`, generate new SSH key, prints new public key at end, (interactive) (ubuntu/centos)
    - `./ssh/key-gen.sh bitbucketbot`
    - `./ssh/key-gen.sh bitbucketbot ds3E2#$78`

### Extras

- `./tool/git-fingerprints.sh`
- `./tool/hostname-change.sh`
- `./tool/server-page.sh`
- `./tool/timezone-set.sh` (uses `conf.sh` timezone)  

## Todos

- HAProxy update-haproxy-if-changed, auto-renew
- Multi monit and service-discovery firewall network config through .conf/conf-set
- Security Checks
- Failure Aware State
- Re-Do Task Option check everywhere, already exists as `--redo` in `init.sh` and `setup-certbot-haproxy.sh` is compatible
- The one-time copied `../state_init.sh` must be updated on next run if `state_init.sh` contains new variables
- Docker Files & Docker Compose
    - maybe some Docker File converter out there
    - maybe using scripts during Docker build
- Make adding a new state/task execution easier or automatic
- Check if `remove domain from cert` needed at rm-alias/moving domain from one vhost to another
- Adding vhost checker: if :80 and auto generated are in parity
- Adding Debian support for current Ubuntu scripts
- Adding CentOS - Debian - Ubuntu concurrent support to as much as possible
- Add interactive/non-interactive  to haproxy-server-list
- Todo's within code files and this file ¯\_(ツ)_/¯

## Privacy

For getting the servers own public IP, the scripts ping `8.8.8.8`, so a Google DNS Server will receive info about the server.

For SSL/TLS certificates the Let's Encrypt certbot is used, for automation the `--agree-tos` is applied automatically, see [Let’s Encrypt: Policy and Legal Repository](https://letsencrypt.org/repository/).

## Security

If you discover any security related issues, please email security@bemit.codes instead of using the issue tracker.

## License

This project is free software distributed under the **MIT License**.

See: [LICENSE](LICENSE).

### Contributors

By committing your code to the code repository you agree to release the code under the MIT License attached to the repository.

### Special Thanks

Shout-out to the authors of following articles, which helped to create this:

- [webdock.io/en/docs/stacks/ubuntu-lemp-74](https://webdock.io/en/docs/stacks/ubuntu-lemp-74)
- [webdock.io/en/docs/perfect-server-stacks/ubuntu-lamp-73](https://webdock.io/en/docs/perfect-server-stacks/ubuntu-lamp-73)
- [www.tecmint.com/things-to-do-after-minimal-rhel-centos-7-installation](https://www.tecmint.com/things-to-do-after-minimal-rhel-centos-7-installation/)
- [devconnected.com/how-to-setup-grafana-and-prometheus-on-linux](https://devconnected.com/how-to-setup-grafana-and-prometheus-on-linux/)
- [mikejung.biz/Apache](https://wiki.mikejung.biz/Apache), especialy Performance MPM Directives
- [servebolt.com/articles/calculate-how-many-simultaneous-website-visitors](https://servebolt.com/articles/calculate-how-many-simultaneous-website-visitors/)
- [PHP-FPM-jetzt-mit-mod_proxy_fcgi](https://netz-rettung-recht.de/archives/1909-PHP-FPM-jetzt-mit-mod_proxy_fcgi.html), outdated, in German, now happens automatic what is described there manually

Further Docs:
- [certbot NGINX](https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx)
- [cloud-init service announce](https://cloudinit.readthedocs.io/en/latest/topics/examples.html#call-a-url-when-finished)
- [haproxy dynamic services/consul disco](https://www.haproxy.com/blog/dynamic-scaling-for-microservices-with-runtime-api/)

***

Maintained by [Michael Becker](https://mlbr.xyz) and [3A9gnpGUQiZRC](https://github.com/3A9gnpGUQiZRC) (*some mystery sounds in the background*)
