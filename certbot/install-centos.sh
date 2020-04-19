#!/bin/bash

wget https://dl.eff.org/certbot-auto
mv certbot-auto /usr/local/bin/certbot
chown root /usr/local/bin/certbot
chmod 0755 /usr/local/bin/certbot
