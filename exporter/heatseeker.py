from prometheus_client import start_http_server, Gauge
from Phidget22.PhidgetException import *
from Phidget22.Phidget import *
from Phidget22.Devices.TemperatureSensor import *
import time

TEMPERATURE_FAHRENHEIT = Gauge('current_temperature_fahrenheit', 'Current Temperature in FahrenHeit')
TEMPERATURE_CELCIUS = Gauge('current_temperature_celcius', 'Current Temperature in Celcius')

tc = TemperatureSensor()
tc.setHubPort(1)
tc.setChannel(0)

tc.openWaitForAttachment(5000)

def c_to_f(c):
    return (9/5 * c + 32)

def get_temp(fahrenheit=False):
    temp_celcius = tc.getTemperature()
    if fahrenheit:
        temp = c_to_f(temp_celcius)
    else:
        temp = temp_celcius
    return round(temp, 1)

if __name__ == '__main__':
    start_http_server(8000)
    while True:
        TEMPERATURE_FAHRENHEIT.set_function(lambda: get_temp(fahrenheit=True))
        TEMPERATURE_CELCIUS.set_function(lambda: get_temp(fahrenheit=False))

        time.sleep(1)
