#!/bin/bash

cp -a manifests/ /var/lib/rancher/k3s/server/manifests/

curl -sfL https://get.k3s.io -o /tmp/k3sinstall.sh
chmod +x /tmp/k3sinstall.sh
/tmp/k3sinstall.sh
