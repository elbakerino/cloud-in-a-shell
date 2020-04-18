#!/bin/bash

MASTER_TOKEN=$(consul acl bootstrap)

printf ${MASTER_TOKEN}

#

SECRET=$(echo "${MASTER_TOKEN}" | cut -f2 -d: | cut -f2 -d" " | sed -e 's/ //g')

echo "Exported Secret: ${SECRET}"
export CONSUL_HTTP_TOKEN=${SECRET}
