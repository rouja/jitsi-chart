#!/bin/bash

random-string()
{
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1 | tr -d '\n'
}

cat <<EOF
################################################
JICOFO_AUTH_PASSWORD: $(random-string 16|base64)
JICOFO_COMPONENT_SECRET: $(random-string 16|base64)
JVB_AUTH_PASSWORD: $(random-string 16|base64)
################################################
EOF
