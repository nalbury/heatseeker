# Heatseeker

Use prometheues and grafana to monitor temperature

## Background

I use prometheus and grafana at work to monitor the health of our kubernetes clusters. I also like to grill meat...

Enter heatseeker! Using open source monitoring applications (prometheus, grafana), simple usb connected sensors (phidgets), a little python and a raspberry pi, heatseeker will record and display temerature data for anything you can think of... or you know... meat!

![demo](https://heatseeker-assets.s3.amazonaws.com/ezgif.com-crop.gif)

## Components and Requirements

### [Phidgets](https://www.phidgets.com)

Phidgets are simple usb powered sensors that can be accessed using several common programming languages. This project uses their python library and the following hardware:

- [Phidgets VINT Hub (HUB0000_0)][1]: provides a common USB interface for multiple phidgets devices.
- [Phidgets Isolated Thermocouple Phidget (TMP1100_0)][2]: provides I/O for the thermocouple probe.
- [Phidgets K-Type Probe Thermocouple 11cm (TMP4106_0)][3]: the actual thermocouple sensor.
- [Phidget Cable 10cm (3003_3)][4]: cable to connect the thermocouple phidget to the hub

[1]: https://www.phidgets.com/?tier=3&catid=2&pcid=1&prodid=643
[2]: https://www.phidgets.com/?tier=3&catid=14&pcid=12&prodid=725
[3]: https://www.phidgets.com/?tier=3&catid=14&pcid=12&prodid=729
[4]: https://www.phidgets.com/?tier=3&catid=30&pcid=26&prodid=153


NOTE: The usb connection from the VINT Hub to your Rasberry Pi needs a **MINI** usb cable. This is a slightly uncommon cable so I recommend buying it from the phidgets store when you purchase the phidgets themselves. 

The components should be pretty easy to connect:
- Connect probe to thermocouple sensor (red=`+`, black=`-`)
- Connect thermocouple sensor to the VINT hub port 1 (need to change `exporter/heatseeker.py if another port is used) using the phidget cable 
- Connect VINT hub to usb port on the Raspberry Pi

I highly recommend checking out the fantistic [Phidgets docs](https://www.phidgets.com/docs/Main_Page) if you want to learn more about what they are and how they work.

### Raspberry Pi

This project uses the Raspberry Pi 3 running Rasbian. I highly recommend buying one of the [starter kits from Canakit](https://www.canakit.com/raspberry-pi-3-model-b-plus-starter-kit.html). Info on creating a Rasbian SD card can be found on [the official raspberrypi.org site](https://www.raspberrypi.org/documentation/installation/installing-images/README.md). Either the Desktop or Lite versions will work.

Once installed, make sure you configure a network configuration. Docs for configuring wifi from the command line can also be found [on raspberrypi.org](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md).


### Heatseeker

Under the hood heatseeker is a simple http server that exposes the temerature metrics exposed by the Phidgets sensors in an [OpenMetrics](https://openmetrics.io)/[Prometheus](https://prometheus.io/docs/instrumenting/exposition_formats/) format. 

The code can be found in the `exporter` directory of this repo. 

### Prometheus

Prometheus is a timeseries database capable of scraping and storing data from any target that exposes OpenMetrics/Prometheus formatted data. It has a powerful query language, a dashboard template library, and can be extended with an alertmanager to handle sending/managing alerts based on time series data. I highly recommend reading the [Prometheus docs](https://prometheus.io/docs/introduction/overview/) if you want to extend/reconfigure the monitoring/alerting components of heatseeker.

### Grafana

Grafana is a very powerful graphing application that can graph and alert on data from Prometheus. There is a default dashboard for this project (`dashboard.json`) but part of the fun of building this was thinking of new ways I could graph data from the phidget sensors. [The Grafana docs](https://grafana.com/docs/guides/basic_concepts/) are a great source of inspiration if you're looking to build your own dashboards or even set up alerting for various conditions.

### k3s (kubernetes)

To run prometheus/grafana and enable service discovery of the heatseeker http endpoint, this project uses a minimal kubernetes distrobution called k3s. K3s is designed to run kubernetes on minimal hardware and wraps the essential kuberentes compenents a single binary making it perfectly suited to a Raspberry Pi.

Kuberentes is a vast subject with tons of projects, so I won't dive too deep into it, but the important part is that it gives us a reliable, repeatable way to schedule/orchestrate containers. For this project, we use it to run Prometheus and Grafana (see above). If you want to learn more about k3s, the [docs can be found here.](https://github.com/rancher/k3s/blob/master/README.md)

All of the kubernetes manifests for our Grafana and Prometheus installs can be found in `./manifests`

## Install

- [Connect phidgets](https://www.phidgets.com/?tier=3&catid=14&pcid=12&prodid=725#Getting_Started)
- Boot up rasbian and configure a network connection.
- Log in as the root user (`sudo su -`)
- Depending on the rasbian image you used you may need to install git:

```
apt-get update
apt-get install git
```

Then clone this repo make any desired configuration changes, and run the install script:

```
cd ~
git clone https://gitlab.pizza/nalbury/heatseeker.git
cd heatseeker/
./install.sh
```
This should install:
- python3 and pip3
- basic linux utilities (build essential, curl)
- libusb for Phidgets
- Phidgets usb drivers
- Phidgets/prometheus exporter python libraries (via pip3)
- heatseeker.py in `/usr/local/bin/heatseeker.py`
- a systemd service to run `heatseeker.py`, `heatseeker.service`
- k3s kubernetes cluster
- Prometheus preconfigured to scrape heatseeker
- Grafana exposed on port 80 (http) of the Raspberry Pi

You can check that everything is running with:
`kubectl get pods --all-namespaces`

It make take a minute or two for everything to come online but the finished output should something like:
```
NAMESPACE            NAME                                      READY   STATUS    RESTARTS   AGE
grafana              grafana-0                                 1/1     Running   0          13h
grafana              svclb-grafana-btnwh                       1/1     Running   0          13h
kube-system          coredns-695688789-5nmjv                   1/1     Running   0          13h
prometheus           prometheus-0                              1/1     Running   0          13h
prometheus           svclb-prometheus-gphsl                    1/1     Running   0          13h
```

You can get the IP of your raspberry pi by running `kubectl get service -n grafana` (the `EXTERNAL-IP`). Enter this in a webbrowser to access Grafana. The default login is admin/admin.

Once logged into grafana add the prometheus data source (this will hopefully be part of the install soo :-) by navigating to **Configuration** -> **Data Sources**, and click **Add Data Source**. From there simply enter the url for prometheus: http://prometheus.prometheus.svc:9090 and click **Save & Test**.

To load the default dashboard, navigate to **Create** -> **Import**, click **Upload .json file**, and upload dashboard.json from this repo.



## Install (no prometheus/grafana)

In addition to the self contained install described above, you can also use an existing kubernetes cluster with network access to your Raspberry Pi to run the Prometheus/Grafana compenents. To do so:

- [Connect phidgets](https://www.phidgets.com/?tier=3&catid=14&pcid=12&prodid=725#Getting_Started)
- Boot up rasbian and configure a network connection.
- Log in as the root user (`sudo su -`)

```
cd ~
git clone https://gitlab.pizza/nalbury/heatseeker.git
cd heatseeker/
./install/dependencies.sh
./install/phidgets.sh
./install/exporter.sh
```

Once the heatseeker systemd service is running you should be able to see metrics by running:

```
curl localhost:8000/metrics |grep fahrenheit
```

You can then add a scrape config for this endpoint in an existing prometheus install.

## Misc

- All pods should restart and systemd should enable heatseeker at boot, however there is currently no persistent state for Prometheus (time series data), or Grafana(configuration and dashboard data).

- The thermocouble sensor must be connected to  **hub port 1** on the VINT hub.
