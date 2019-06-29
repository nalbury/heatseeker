#!/bin/bash

pip3 install -r ./exporter/requirements.txt

cp ./exporter/heatseeker.py /usr/local/bin/heatseeker.py

cp ./exporter/systemd/heatseeker.service /etc/systemd/system/heatseeker.service

systemctl enable heatseeker.service
systemctl start heatseeker.service
