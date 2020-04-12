
## IOTManager project

This project is a simple monitoring system for MQTT based communication, 
iotmanager let you monitor the existing devices, using a config file.

Each device has a communication time out, when the timeout is reached, the iotmonitor publish a 
specific monitoring topic failure for the device, with the latest contact timestamp

	home/monitoring/expire/[device_name]


### Building the project



	git clone --recursive https://github.com/frett27/iotmonitor
	cd iotmonitor
	cd paho.mqtt.c
	cmake -DPAHO_BUILD_STATIC=true .
	make
	cd ..

	mkdir bin
	zig build
	


### Configuration

in the configuration,each device is declared in a section using a "device_" prefix
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

### monitoring the monitor

each second, a counter is published on home/monitoring/up topic
this option permit to know if the monitor is still alive, 
the counter is resetted each launch time

### Developing on the project

when-changed is a simple python command ligne that auto recompile the project, when files changes

	when-changed *.zig zig build
		 when-changed leveldb.zig ../zig/zig test leveldb.zig  -l leveldb -l c -l c++

### Possible Improvments

- Use a full parser

seems a target port for zig in antlr4, is a good idea
https://github.com/antlr/antlr4/blob/master/doc/creating-a-language-target.md


