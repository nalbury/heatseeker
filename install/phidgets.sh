#!/bin/bash

wget -qO- http://www.phidgets.com/gpgkey/pubring.gpg | apt-key add -
echo 'deb http://www.phidgets.com/debian stretch main' > /etc/apt/sources.list.d/phidgets.list
apt-get update
apt-get install libphidget22
