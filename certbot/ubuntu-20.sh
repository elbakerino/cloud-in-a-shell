#!/bin/bash

apt install snapd

snap install core

snap refresh core

snap install --classic certbot
