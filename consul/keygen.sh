#!/bin/bash

consul_key=$(/usr/local/bin/consul keygen)

DIR_CUR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source ${DIR_CUR}/../conf-set.sh --sd-key="${consul_key}"
