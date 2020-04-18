#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
echo "   SD_KEY: '$(cat "${DIR_CUR}/../../conf.sh" | grep -o "SD_KEY=.*" | cut -f2 -d= | sed -e 's/"//g')'"
