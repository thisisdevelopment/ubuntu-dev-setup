#!/bin/bash

set -o allexport
source .env
set +o allexport
envsubst "$(cat .env | sed 's/^/$/' | tr '\n' ' ')" < "$1" > "$2"
if [ -x "$1" ]; then
  chmod a+x "$2"
fi
