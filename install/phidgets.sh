#!/bin/bash

pushd /tmp/

curl -Lo /tmp/libphidget22.tar.gz https://www.phidgets.com/downloads/phidget22/libraries/linux/libphidget22.tar.gz
tar -xvf libphidget22.tar.gz -C ./

pushd libphidget22-*

./configure
make
make install

popd
