#!/bin/bash

docker build -t ubuntu-dev-setup .
docker run -v $(pwd):/src ubuntu-dev-setup ./make-image.sh
usb-creator-gtk -i $(ls -at *.iso | head -n 1)
