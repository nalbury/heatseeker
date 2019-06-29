#!/bin/bash

apt-get update
apt-get install -y \
  build-essential \
  libusb-1.0-0-dev \
  curl \
  python3 \
  python3-pip

mkdir -p /usr/local/bin/
