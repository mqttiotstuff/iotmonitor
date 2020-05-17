
## IOTMonitor project

This project is a simple state manager and monitoring system for MQTT based communication devices (IOT). Iotmonitor monitor the existing devices, using a config file. 

IotMonitor also record and restore their states as they go and recover. It helps to maintain IOT things working, even if they fails.

Each device has an independent communication message time out, when the device did not reponse until timeout is reached, the iotmonitor publish a specific monitoring failure topic for the device, with the latest contact timestamp

	home/monitoring/expire/[device_name]

This topic can then be displayed or alerted to signal which device is not functionnal.


This project also contains a C Paho MQTT client library, AND a `zig` leveldb client library. They can be reused, and improved independently of the projet.


### Building the project on linux


### Using docker, 

build the image :

	cd docker
	docker build -t iotmonitor .

launch the container from image :

        docker run --rm -d -u $(id --user) -v `pwd`:/config iotmonitor


#### From scratch

for building the project, the following elements are needed :

- leveldb library (used for storing stated)
- C compiler (builds essentials)
- cmake
- zig : 0.6

then launch the following commands :

	git clone --recursive https://github.com/frett27/iotmonitor
	cd iotmonitor
	cd paho.mqtt.c
	cmake -DPAHO_BUILD_STATIC=true .
	make
	cd ..

	mkdir bin
	zig build
	


### Configuration

The configuration is defined in a TOML `config.toml` file, see an example in the root directory

Mqtt brocker configuration is done, using `[mqtt]` section
in the following, the given parameters are found :

	[mqtt]
	serverAddress="tcp://localhost:1883"
	baseTopic="home/monitoring"
	user=""
	password=""



In the configuration toml file, each device is declared in a section using a "device_" prefix
in the section : the following elements can be found :

	[device_esp04]
	watchTimeOut=60
	helloTopic="home/esp04"
	watchTopics="home/esp04/sensors/#"
	stateTopics="home/esp04/actuators/#"

watchTimeOut : watch dog for alive state, when the timeout is reached without and interactions on watchTopics, then iotmonitor trigger an expire message for the device
helloTopic : the topic to observe to welcome the device
watchTopics : the topic pattern to observe to know the device is alive
stateTopics : list of topics for recording the states and reset them as they are welcomed

### State restore

At iotmonitor launch the recorded states for devices are reposted to the topics
this permit to centralize the state, and restore them when an iot device has rebooted.

### Monitoring iotmonitor :-)

To be sure all is under control, each second, IotMonitor publish a counter on the `home/monitoring/up` topic
this option permit to know if the monitor is still operational.
The counter is resetted at each startup.

### Developing on the project

when-changed is a simple python command ligne that auto recompile the project, when files changes

	when-changed *.zig zig build
		 when-changed leveldb.zig ../zig/zig test leveldb.zig  -l leveldb -l c -l c++

### Possible Improvments

- Use a full parser

seems a target port for zig in antlr4, is a good idea
https://github.com/antlr/antlr4/blob/master/doc/creating-a-language-target.md


### Credits

- zig-toml : for zig toml parser
- paho eclipse mqtt c library
- levedb database

