#!/bin/bash

# Clean Installation Rests
apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
