#!/bin/bash

docker build -t ubuntu-dev-setup .
docker run -v $(pwd):/src ubuntu-dev-setup ./make-image.sh
usb-creator-gtk -i ./ubuntu-22.04.1-TID-oem-amd64.iso