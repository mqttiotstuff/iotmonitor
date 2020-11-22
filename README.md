
## IOTMonitor project

IotMonitor solve the "always up" problem of large IOT devices and agents system. Considering large and longlived systems cannot rely only on some specific software, using raw system's processes permit to compose a system with several processes or devices, implemented with different langages and coming from multiple implementers or third party.

This project is simple command line, as in *nix system, to monitor MQTT device or agents system. MQTT based communication devices (IOT) and agents are monitored, and alerts are emitted if devices or agents are not responding. Software agents are also restarted when crashed. 

IotMonitor records and restore MQTT states topics as they go and recover. It helps to maintain IOT things working, and avoid lots of administration tasks.

Using a config file, each device has an independent configured communication message time out. When the device stop communication on this topic, the iotmonitor publish a specific monitoring failure topic for the lots device, with the latest contact timestamp

	home/monitoring/expire/[device_name]

This topic can then be displayed or alerted to alert that the device or agent is not working properly.

This project is based on C Paho MQTT client library, use leveldb as state database.


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
- zig : 0.7

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

A global Mqtt broker configuration section is defined using a heading `[mqtt]` 
the following parameters are found :

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

- `watchTimeOut` : watch dog for alive state, when the timeout is reached without and interactions on watchTopics, then iotmonitor trigger an expire message for the device
- `helloTopic` : the topic to observe to welcome the device. This topic trigger the state recovering for the device and agents. IotMonitor, resend the previous stored `stateTopics`
- `watchTopics` : the topic pattern to observe to know the device is alive
- `stateTopics` : list of topics for recording the states and reset them as they are welcomed

Agents are declared using an "agent_" prefix in the section. Agents are devices with an associated command line (`exec` config key) that trigger the start of the software agent. IotMonitor checks periodically if the process is running, and relaunch it if needed.

	[agent_ledboxdaemon]
	exec="source ~/mqttagents/p3/bin/activate;cd ~/mqttagents/mqtt-agent-ledbox;python3 ledboxdaemon.py"
	watchTopics="home/agents/ledbox/#"

IotMonitor running the processes identify the process using a specific bash command line containing an IOTMONITOR tag, which is recognized to detect if the process is running. Monitored processes are detached from the iotmonitor process, avoiding to relaunch the whole system in the case of restarting the `iotmonitor` process.



### State restore

At iotmonitor launch the recorded states for devices are reposted to the topics once IotMonitor start or when the `helloTopic` if sent.
this permit to centralize the state, and restore them when an iot device has rebooted. The device keep then the previous state. There is then, no need in the device to handle a state storage.

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

