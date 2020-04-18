# DB Master MySQL

(ubuntu)

Installs and configures a MariaDB server, is interactive - as it need to create passwords and stuff.

```bash
./ssh/forbid-pw-access.sh
./recipes/db-mariadb-master.sh

# maybe allow remote access
ufw allow from 10.0.0.0/24 to any port 3306
./mariadb/remote-allow.sh
service mysql restart
```

Grant MySQL user rights, login to mysql as e.g. `root`
 
> Further examples on [mediatemple: grant-privileges-in-mysql](https://mediatemple.net/community/products/dv/204404494/how-do-i-grant-privileges-in-mysql)

```mysql
GRANT SELECT, INSERT, DELETE, UPDATE ON <dbname> TO '<uname>'@'%';
GRANT SELECT, INSERT, DELETE, UPDATE ON * . * TO '<uname>'@'10.0.0.%';
```

Public access for db user, `%` for any IP or `1.2.3.4` just for your IP.

```mysql
CREATE USER 'mysqld_exporter'@'%' IDENTIFIED BY '<pass>';
CREATE USER '<uname>'@'%' IDENTIFIED BY '<pass>';
CREATE DATABASE <dbname>;
GRANT SELECT, INSERT, DELETE, UPDATE ON <dbname> TO '<uname>'@'%';

CREATE USER '<uname>'@'1.2.3.4' IDENTIFIED BY '<pass>';
GRANT SELECT, INSERT, DELETE, UPDATE ON <dbname> TO '<uname>'@'1.2.3.4';
```
