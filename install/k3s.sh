#!/bin/bash

echo "127.0.0.1	raspberry" >> /etc/hosts

mkdir -p /var/lib/rancher/k3s/server/
cp -a manifests/ /var/lib/rancher/k3s/server/

curl -sfL https://get.k3s.io -o /tmp/k3sinstall.sh
chmod +x /tmp/k3sinstall.sh
/tmp/k3sinstall.sh --no-deploy traefik
