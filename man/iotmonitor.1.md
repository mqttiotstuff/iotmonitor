% IOTMONITOR(1) iotmonitor 0.2.3
% Patrice Freydiere
% December 2021

# NAME
iotmonitor - monitor and manage execution of mqtt iot processes

# SYNOPSIS
**iotmonitor** [*OPTIONS*]

# DESCRIPTION

**iotMonitor** is an effortless and lightweight mqtt monitoring for devices (things) and agents on Linux. 

IotMonitor aims to solve the "always up" problem of large IOT devices and agents system. This project is successfully used every day for running smart home automation system.
Considering large and longlived running mqtt systems can hardly rely only on monolytics plateforms, the reality is always composite as some agents or functionnalities increase with time. Diversity also occurs in running several programming languages implementation for agents. 

This project offers a simple command line, as in \*nix system, to monitor MQTT device or agents system. MQTT based communication devices (IOT) and agents are watched, and alerts are emitted if devices or agents are not responding any more. Declared software agents are restarted by iotmonitor when crashed. 

# OPTIONS

**--help**
: Display a friendly help message

**-v**, **--version**
: Display the software version

# IOTMONITOR MESSAGE PUBLISHING

Once the mqtt topics associated to a thing or agent is declared, IotMonitor records and restore given MQTT "states topics" as they go and recover. It helps reinstalling IOT things state, to avoid lots of administration tasks.

## "EXPIRED" SUBTOPIC

IotMonitor use a TOML config file. Each device has an independent configured communication message time out. When the device stop communication on this topic, the iotmonitor publish a specific monitoring failure topic for the lots device, with the latest contact timestamp. This topic is labelled :

	[BASE_IOTMONITOR_TOPIC]/expire/[device_name]
for example :

	home/monitoring/expire/[device_name]

This topic can then be displayed or alerted to inform that the device or agent is not working properly.

## "UP" SUBTOPIC

When running, iotmonitor also published an *up* subtopic this topic is published every seconds and provide the startup seconds of the iotmonitor process. This topic can be also used to monitor the iotmonitor process.

## "HELLOTOPICCOUNT" SUBTOPIC

helloTopicCount count, for each device, the number of hello topic published by the device or agent. This counter inform the count of restart or reboot of each device or agent.

	[BASE_IOTMONITOR_TOPIC]/helloTopicCount



# CONFIG FILE REFERENCE

The configuration is defined in the  `config.toml` TOML file, (see an example in the root directory)
the global _Mqtt broker configuration section_ is defined using a heading `[mqtt]` 
the following parameters are found :

```toml
[mqtt]
serverAddress="tcp://localhost:1883"
baseTopic="home/monitoring"
user=""
password=""
```

## GLOBAL SECTION

global section of the mqtt configuration file contains the following possible elements :

serverAddress
: mqtt broker address, this include tcp:// communication and the port as shown in the previous example

user
: mqtt broker authentication, left empty if no authentication is necessary. The password parameter is then used if the user parameter is filled.

password
: account associated password

baseTopic
: root of all iotmonitor publications. This defines the *BASE_IOTMONITOR_TOPIC*

clientid
: An optional clientid can also be specified to change the mqtt clientid, a default "iotmonitor" value is used when not specified

## DEVICE DECLARATION SECTION

Each monitored device is declared in a section using a "device_" prefix in this section : the following elements can be found :

```toml
[device_esp04]
watchTimeOut=60
helloTopic="home/esp04"
watchTopics="home/esp04/sensors/#"
stateTopics="home/esp04/actuators/#"
```

watchTimeOut
: watch dog for alive state, when the timeout is reached without and interactions on watchTopics, then iotmonitor trigger an expire message for the device

helloTopic
: the topic to observe to welcome the device. This topic trigger the state recovering for the device and agents. IotMonitor, resend the previous stored `stateTopics`

watchTopics
: the topic pattern to observe to know the device is alive

stateTopics
: list of topics for recording the states and reset them as they are welcomed

## AGENT DECLARATION SECTION

Agents are declared using an "agent_" prefix in the section. Agents are devices with an associated command line (`exec` config key) that trigger the start of the software agent. IotMonitor checks periodically if the process is running, and relaunch it if needed.

```toml
[agent_ledboxdaemon]
exec="source ~/mqttagents/p3/bin/activate;cd ~/mqttagents/mqtt-agent-ledbox;python3 ledboxdaemon.py"
watchTopics="home/agents/ledbox/#"
```

When IotMonitor run the processes, it identify the process by searching a specific  command line parameter, containing an IOTMONITOR tag. When executing the agents processes, the processes are detached from the main iotmonitor process, avoiding to relaunch the whole system in the case of restarting the `iotmonitor` process.

Agents declaration inherit all DEVICE SECTION parameters, with an additional *exec* parameter.
Agents may also have `helloTopic`, `stateTopics` and `watchTimeOut` as previously described in DEVICE DECLARATION SECTION.


# STATE RECOVERY

At startup OR when the `helloTopic` is fired, iotmonitor fire the previousely recorded states on mqtt, this permit the device (things), to take it's previoulsy state, as if it has not been stopped.. All mqtt recorded states (`stateTopics`) are backuped by iotmonitor in a leveldb database.
For practical reasons, this permit to centralize the state, and restore them when an iot device has rebooted. If used this functionnality, reduce the need to implement a cold state storage for each agent or device.  Starting or stopping iotmonitor, redefine the state for all elements.


