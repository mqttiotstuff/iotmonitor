

## IOTMonitor project

IotMonitor is an effortless and lightweight mqtt monitoring for devices (things) and agents on Linux. 

IotMonitor aims to solve the "always up" problem of large IOT devices and agents system. This project is successfully used every day for running smart home automation system.
Considering large and longlived running mqtt systems can hardly rely only on monolytics plateforms, the reality is always composite as some agents or functionnalities increase with time. Diversity also occurs in running several programming languages implementation for agents. 

This project offers a simple command line, as in *nix system, to monitor MQTT device or agents system. MQTT based communication devices (IOT) and agents are watched, and alerts are emitted if devices or agents are not responding any more. Declared software agents are restarted by iotmonitor when crashed. 

In the behaviour, once the mqtt topics associated to a thing or agent is declared, IotMonitor records and restore given MQTT "states topics" as they go and recover. It helps reinstalling IOT things state, to avoid lots of administration tasks.

IotMonitor use a TOML config file. Each device has an independent configured communication message time out. When the device stop communication on this topic, the iotmonitor publish a specific monitoring failure topic for the lots device, with the latest contact timestamp. This topic is labelled :

	home/monitoring/expire/[device_name]

This topic can then be displayed or alerted to inform that the device or agent is not working properly.

This project is based on C Paho MQTT client library, use leveldb as state database.


### Configuration File

The configuration is defined in the  `config.toml` TOML file, (see an example in the root directory)

A global Mqtt broker configuration section is defined using a heading `[mqtt]` 
the following parameters are found :

```toml
[mqtt]
serverAddress="tcp://localhost:1883"
baseTopic="home/monitoring"
user=""
password=""
```


#### Device declaration

In the configuration toml file, each device is declared in a section using a "device_" prefix
in the section : the following elements can be found :

```toml
[device_esp04]
watchTimeOut=60
helloTopic="home/esp04"
watchTopics="home/esp04/sensors/#"
stateTopics="home/esp04/actuators/#"
```

- `watchTimeOut` : watch dog for alive state, when the timeout is reached without and interactions on watchTopics, then iotmonitor trigger an expire message for the device
- `helloTopic` : the topic to observe to welcome the device. This topic trigger the state recovering for the device and agents. IotMonitor, resend the previous stored `stateTopics`
- `watchTopics` : the topic pattern to observe to know the device is alive
- `stateTopics` : list of topics for recording the states and reset them as they are welcomed

#### Agents declarations

Agents are declared using an "agent_" prefix in the section. Agents are devices with an associated command line (`exec` config key) that trigger the start of the software agent. IotMonitor checks periodically if the process is running, and relaunch it if needed.

```toml
[agent_ledboxdaemon]
exec="source ~/mqttagents/p3/bin/activate;cd ~/mqttagents/mqtt-agent-ledbox;python3 ledboxdaemon.py"
watchTopics="home/agents/ledbox/#"
```

IotMonitor running the processes identify the process using a specific bash command line containing an IOTMONITOR tag, which is recognized to detect if the process is running. Monitored processes are detached from the iotmonitor process, avoiding to relaunch the whole system in the case of restarting the `iotmonitor` process.

Agents may also have `helloTopic`, `stateTopics` and `watchTimeOut` as previously described.

#### State restoration for things and agents

At startup OR when the `helloTopic` is fired, iotmonitor fire the previousely recorded states on mqtt, this permit the device (things), to take it's previoulsy state, as if it has not been stopped.. All mqtt recorded states (`stateTopics`) are backuped by iotmonitor in a leveldb database.
For practical reasons, this permit to centralize the state, and restore them when an iot device has rebooted. If used this functionnality, reduce the need to implement a cold state storage for each agent or device.  Starting or stopping iotmonitor, redefine the state for all elements.

#### Monitoring iotmonitor :-)

IotMonitor publish a counter on the `home/monitoring/up` topic every seconds. One can then monitor the iotmonitor externally.
The counter is resetted at each startup.



### Building the project on linux


### Using docker, 

[see README in docker subfolder, for details and construct the image](docker/README.md)


launch the container from image :

```bash
docker run --rm -d -u $(id --user) -v `pwd`:/config iotmonitor
```

#### From scratch

for building the project, the following elements are needed :

- leveldb library (used for storing stated)
- C compiler (builds essentials)
- cmake
- zig : 0.8

then launch the following commands :

```bash
git clone --recursive https://github.com/frett27/iotmonitor
cd iotmonitor
cd paho.mqtt.c
cmake -DPAHO_BUILD_STATIC=true .
make
cd ..

mkdir bin
zig build
```
	
### Credits

- zig-toml : for zig toml parser
- paho eclipse mqtt c library
- levedb database

