# Server Inits - Server Creation Helper

(bash) scripts for easy deployment of servers - run some scripts and launch!

Useful for single-server and small cluster with services on multiple servers: loadbalancer, computing units, file-server, database, monitoring and more.

🚧 WIP, mostly scripts which are in use for creating base images of servers and having the most repeated code as documentation.

Tested/used on Ubuntu 18.04 LTS and CentOS 8 virtual cloud server.

- [Upload to Server](#markdown-header-upload-to-server)
- [Config](#markdown-header-config)
- [Tools](#markdown-header-tools)
- [Add New Task](#markdown-header-add-new-task)
- [Todos](#markdown-header-todos)
- [License](#markdown-header-license)
- [Special Thanks](#markdown-header-special-thanks)

## Upload to Server

Upload to server from a client, uses `ssh-pageant` to determine SSH_AUTH_SOCK, tested on windows with putty-pageant.

```bash
npm i

npm run upload <host> <user> <remote_dir>
npm run upload 1.2.3.4 root /root
```

Extract on Server:

```bash
# CentOS needs tar, Ubuntu has it
dnf install tar -y

# in new dir
mkdir -p inits && tar xvf inits.tgz -C inits && cd inits && chmod -R u+x *.sh

mkdir -p inits && tar xvf inits.tgz -C inits && cd inits && find . -type f -name "*.sh" -print0 | xargs -0 chmod u+x

# in current dir
tar xvf inits.tgz && chmod -R u+x *.sh

# update in ~/inits
rm -rf ~/inits/ && cd ~/inits && tar xvf inits.tgz -C inits && cd inits && chmod -R u+x *.sh

# only execution rights (in folder `inits`)
find . -type f -name "*.sh" -print0 | xargs -0 chmod u+x
```

## Config

A few things can easily configured through the [conf.sh](conf.sh) - if needed.

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

## Tools

### Ansible 

- `./ansible/install-ansible.sh` (ubuntu)

### Apache (ubuntu)

- install: `./apache/install-apache.sh` (**relies on ubuntu-basics**)
    - firewall ports needs to be enabled manually
- performance: `./apache/conf-performance.sh [cores]`, configures mpm server limits based on cpu
    - `./apache/conf-performance.sh 1`, `./apache/conf-performance.sh 4`
    
Apache vhost management:

- create: `./apache/vhost-create.sh <vh-name> <server-name>`, creates a new vhost with the specified main server_name, *has todos*
- create default: `./apache/vhost-default.sh`, creates the catch all localhost vhost: `/var/www/vhosts/example` and config: `/etc/apache2/sites-available/example.conf`
- disable: `./apache/vhost-dis.sh <vh-name>`, disables the vhost
- docroot change: `./apache/vhost-docroot-change.sh <vh-name> <rel-path>`, changes the documentroot for the vhost
    - `./apache/vhost-docroot-change.sh example new_public`, changes the root from `/var/www/vhosts/example` to `/var/www/vhosts/example/new_public`
- list: `./apache/vhost-list.sh`, list infos about all configured vhosts
- rm: `./apache/vhost-rm.sh <vh-name>`, removes the vhost config at all, **deletes the config file!**
- alias add: `./apache/vhost-alias-add.sh <vh-name> <alias>`, add server_alias to vhost, includes duplicate check, *todo: duplicate check not includes main server_name*
    - `./apache/vhost-alias-add.sh example demo.example.org`, adds alias to vhost `/var/www/vhosts/example` and config: `/etc/apache2/sites-available/example.conf`
- alias rm: `./apache/vhost-alias-rm.sh <vh-name> <alias>`

Apache SSL:

- enables ssl redir: `./apache/vhost-ssl-redir.sh <vh-name>`
- ssl secure: `./apache/vhost-ssl-secure.sh <vh-name> <notify-email>`
    - enables/renews ssl security for already configured domains in the vhost
    - creates/updates a single certificate per vhost
    - just rerun after added some alias or server to a config
    - `./apache/vhost-ssl-secure.sh <vh-name> <notify-email>`

### certbot for SSL / TLS

> Legal Notice for using certbot:
>
> Let’s Encrypt usage to provision TLS certificates oblige to the [Let’s Encrypt Subscriber Agreement(s) & Terms of Services](https://letsencrypt.org/repository/). You accept the terms by using the certbot scripts supplied by serverinits.

- apache: `./certbot/install-apache-certbot.sh` (**relies on ubuntu-basics**) (ubuntu)
    - for management use: `./apache-vhost-ssl-secure`
- haproxy: `./certbot/install-haproxy-certbot.sh <cert-name> <email> [<(new)-host>]`, installs certbot and setups certs, only installs when not installed
    - `./certbot/install-haproxy-certbot.sh example hostmaster@example.org`, creates or updates the cert `example.pem` with the warning email 
    - `./certbot/install-haproxy-certbot.sh example hostmaster@example.org demo.example.org`, creates or updates the cert `example.pem` with the warning email, adds the host `demo.example.org` to the hosts of the file
- nginx: `./certbot/install-nginx-certbot.sh` (ubuntu/centos) (**relies on ubuntu-basics**)
- centos: `./certbot/install-centos.sh` installs certbot-auto on centos

### Consul 

### HAProxy

❌

- install: `./haproxy/install-haproxy.sh` (centos) (*todo: split centos basic setup*)
- reload: `./haproxy/reload.sh`

HAProxy Servers:

- add: `./haproxy/server-add.sh`
- drain: `./haproxy/server-drain.sh`
- enable: `./haproxy/server-enable.sh`
- list: `./haproxy/server-list.sh`
- maint: `./haproxy/server-maint.sh`
- stats-secure: `./haproxy/stats-secure.sh`

### Hetzner

❌

- float ip bind: `./hetzner/floatip-bind.sh` (todo: not dynamic)

### MariaDB / MySQL

❌

- install: `./mariadb/install-mariadb.sh`

### NGINX

❌

- install: `./nginx/install-nginx.sh` (centos)
- server disable: `./nginx/server-dis.sh`
- server set: `./nginx/server-set.sh`

### PHP

- install: `./php/install-php.sh`, installs php (7.4) and composer (ubuntu) 
- config cli: `./php/php-cli.sh`, basic configuration for cli usage
- config fpm: `./php/php-fpm.sh`, basic configuration for fpm servers
    - currently optimized for apache usage / apache has mpm_event which controls fpm servers

### Prometheus

- install: `./prometheus/install-master.sh` install prometheus master and grafana, (ubuntu) (*todo: split grafana*) 
- install exporter: 
    - apache: `./prometheus/exporter-apache.sh`, (ubuntu/centos)
    - haproxy: `./prometheus/exporter-haproxy.sh`, (ubuntu/centos) (*todo: fail after reboot, wrong owner of stats*)
    - mysql/mariadb: `./prometheus/exporter-mysql.sh`, (ubuntu/centos)
    - system: `./prometheus/exporter-node.sh`, (cpu, memory, network), (ubuntu/centos)
    - statsd: `./prometheus/exporter-statsd.sh`, [statsd](https://github.com/statsd/statsd) a generic stats daemon, (ubuntu/centos) (*scribble*)
- master tools:
    - target add: `./prometheus/add-target.sh <target>`, add new scraper targets, (ubuntu)
        - `./prometheus-add-target.sh 10.0.0.2:9100 10.0.0.2:9100` supports multiple at once
        - *todo*: not adding already existing once
- exporter tools: (*todo finalize*)
    - network tools allow scraper access from within configured `NET_MONIT`/24
    - haproxy: `./prometheus/network-haproxy.sh` 9101 (ubuntu/centos)
    - statsd: `./prometheus/network-statsd.sh` 9102 (ubuntu/centos)
    - apache: `./prometheus/network-apache.sh` 9117 (ubuntu/centos)
    - node: `./prometheus/network-node.sh` 9100 (ubuntu/centos)

### SSH 

❌

- `./ssh/agent-enable.sh`, register/enable SSH-Agent for all processes, enabling start at boot, (automatic) (ubuntu/centos)
- `./ssh/forbid-pw-access.sh`, forbid PW login, only cert login allowed, (ubuntu/centos)
- `./ssh/key-allow.sh`, allow access with a key, asks for the key, (interactive) (ubuntu/centos) (*todo: check duplicates*)
- `./ssh/key-gen.sh <name> [<pass>]`, generate new SSH key, prints new public key at end, (interactive) (ubuntu/centos)
    - `./ssh/key-gen.sh  bitbucketbot`
    - `./ssh/key-gen.sh  bitbucketbot ds3E2#$78`

### Tool 

❌

- `./tool/git-fingerprints.sh`
- `./tool/hostname-change.sh`
- `./tool/server-page.sh`
- `./tool/ubuntu-basics.sh`
- `./tool/timezone-set.sh`

## Recipes

### Webserver Apache + PHP

(ubuntu)

```bash
./recipes/webspace-apache-php.sh

# requires manual monitoring scraper setup at monit-master
# firewall config for http/https not included
# does not setup ssl
```

#### Single-Server Apache + PHP

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

#### Loadbalanced Apache + PHP

Allow access to port 80 only from loadbalancer in firewall, replace `10.0.0.2` with the ip of your loadbalancer
 
```bash
ufw allow from 10.0.0.2 to any port 80
``` 

### Setup Bastion Host

Todo add how-to: configure firewalls for non-ssh entry when not from bastion host and how to configure e.g. putty for full-project access.

Todo add how-to: further usage scenarios of bastion hosts, e.g. deploy-master  

## Add New Task

Through `./init.sh` available installation and setup arguments are organized as tasks.
 
The execution is saved in [_boot/state_init.sh](_boot/state_init.sh), which is copied to project parent's folder at first run.

The server inits can simply be updated with `git pull` - no file within this project changes while using it. 

Adding the example task `--install-loadtest`:

**Create Task File:**

1. Create File: `install/install-loadtest.sh`
2. Define the installation of loadtest there
3. Add state updating at the end: 
```bash
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
echo " ✓ Installed Loadtest"
INSTALLED_LOADTEST=true
sed -i "s/INSTALLED_LOADTEST=false/INSTALLED_LOADTEST=true/" ${DIR_CUR}/../../state_init.sh
```

**Define Task Argument:**

1. Open [init.sh](init.sh)
2. Add new `TO_INSTALL_LOADTEST=false` within the top variables
3. Add new argument like the others:
```bash
   --install-loadtest)
      TO_INSTALL_LOADTEST=true
          ;;
```
4. Add task file execution: `runTask "Loadtest" ${TO_INSTALL_LOADTEST} ${INSTALLED_LOADTEST} "install/install-loadtest.sh"`
5. Open [_boot/state_init.sh](_boot/state_init.sh)
6. Add default `false` variable: `INSTALLED_LOADTEST=false`
7. Open [_boot/print_state.sh](_boot/print_state.sh)
8. Add current-state output with: `printState ${INSTALLED_LOADTEST} "Loadtest"`
9. Open [_boot/print_state_selected.sh](_boot/print_state_selected.sh)
10. Add current-state and if selected output with: `printStateSelected ${INSTALLED_LOADTEST} "Loadtest" ${TO_INSTALL_LOADTEST}`

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
