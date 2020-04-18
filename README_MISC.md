# Know-How Scribbles

## UFW

Ubuntu Firewall

    ufw status
    ufw status numbered
    ufw delete <number> # delete by number (IP v4 or v6)
    ufw delete allow 80 # delete by rule (IP v4 + v6)
    
    # ufw activates rule automatic, no reload needed
    ufw reload
    
## FirewallD

CentOS Firewall

    firewall-cmd --list-all
    firewall-cmd --zone=public --list-services

# Unsorted Notes

Notes and commands for different purposes, not really sorted.

## Ubuntu Misc

Get Users:
```bash
cat /etc/passwd
```

## Mount Volume

```bash
mkdir /mnt/volume-develop
mount -o discard,defaults /dev/disk/by-id/scsi-0HC_Volume_2660413 /mnt/volume-develop
echo "/dev/disk/by-id/scsi-0HC_Volume_2660413 /mnt/volume-develop ext4 discard,nofail,defaults 0 0" >> /etc/fstab
```

## Disable PW Access

```bash
sed -i "s/#PasswordAuthentication .*/PasswordAuthentication no/" /etc/ssh/sshd_config && \
sed -i "s/#ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/" /etc/ssh/sshd_config && \
sed -i "s/#UsePAM .*/UsePAM no/" /etc/ssh/sshd_config && \
     service ssh restart
```

## Floating IP - Ubuntu
```bash
FLOATING_IP=88.198.202.97

mkdir -p /etc/network/interfaces.d
cat >/etc/network/interfaces.d/60-my-floating-ip.cfg <<EOF
auto eth0:1
iface eth0:1 inet static
    address ${FLOATING_IP}
    netmask 32
EOF

sudo service networking restart
```

## Floating IP - CentOS

```bash
FLOATING_IP=88.198.202.97

mkdir -p /etc/sysconfig/network-scripts
cat >/etc/sysconfig/network-scripts/ifcfg-eth0:1 <<EOF
BOOTPROTO=static
DEVICE=eth0:1
IPADDR=${FLOATING_IP}
PREFIX=32
TYPE=Ethernet
USERCTL=no
ONBOOT=yes
EOF

systemctl restart NetworkManager
```

- centos 7
    - systemctl restart network
- centos 8: `reboot` or
    - systemctl restart NetworkManager

# Add MySQL User

mysql -uroot -p
CREATE USER '<uname>'@'%' IDENTIFIED BY '<pass>';
GRANT ALL PRIVILEGES ON * . * TO '<uname>'@'%';
GRANT SELECT, INSERT, DELETE, UPDATE PRIVILEGES ON <databasename> TO '<uname>'@'%';
FLUSH PRIVILEGES;
exit;

# Monit

https://devconnected.com/how-to-setup-grafana-and-prometheus-on-linux/

Add node-exporter with `prometheus/exporter.sh` on target and register it at the main-monit for the zone 

    vi /etc/prometheus/prometheus.yml

add new target to yml:

```yml
    static_configs:
    - targets: 
      - <prometheus-server>:9090
      - <prometheus-target>:9100
```

> Note on array syntax, in .yml no ['localhost:9090'] syntax can be used, not supported by `yq` https://mikefarah.github.io/yq/
  
and: `systemctl restart prometheus`

# Ubuntu Change Hostname

```bash

```

# Firewall

Allow connection to `firewalld`/centos Prometheus Node Exporter only from trusted subnet:

```bash
firewall-cmd --permanent --zone=trusted \
    --add-rich-rule='rule family="ipv4" source address="10.0.0.0/24" port port="9100" protocol="tcp" accept'

firewall-cmd --reload

firewall-cmd --zone=public --add-port=5000/tcp --permanent
firewall-cmd --zone=public --remove-port=443/tcp --permanent
```


Allow everyone to access port 22:

```bash
ufw allow 22
```

Allow subnet to access a single port:

```bash
# ssh
ufw allow from 10.0.0.0/24 to any port 22

# mysql
ufw allow from 10.0.0.0/24 to any port 3306

# prometheus node-exporter
ufw allow from 10.0.0.0/24 to any port 9100
# prometheus mysql-exporter
ufw allow from 10.0.0.0/24 to any port 9104
# prometheus apache-exporter
ufw allow from 10.0.0.0/24 to any port 9117
# prometheus nginx-exporter
ufw allow from 10.0.0.0/24 to any port <9100>
# prometheus haproxy-exporter
ufw allow from 10.0.0.0/24 to any port <8404>
```

Deny access for IP:

```bash
ufw deny from 15.15.15.51

ufw deny from 15.15.15.51/24
```
