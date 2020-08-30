# RFC adding process monitoring



August 2020

### Summary

IOTMonitor currently monitor MQTT devices or agents, by watching mqtt topics and associated states.

in case of non response, iotmonitor send a MQTT alert in a specific MQTT topic linked to monitoring. 



### Process monitoring goal

This evolution it to also manage the external agents process management. Knowing if a process is healthy imply to know the functional behaviour and this is a hard trick to define externally (failure detection problem). 

Nonetheless, if the process periodically published its health, or having and external process than monitor it's health.  In Using periodic MQTT healthchecks, this is then possible to handle the (kill/exec) command on the process to make the system work. 

This ability also simplify the managing of such system, this mean, when a process managing devices and providing MQTT watchdog health check, then an entry in IOTMonitor can be added to manage the process.



### Implementation Ideas

As IOTMonitor launch the process, it can setup a unique identifier that can be used to track the process. process can be wrapped into bash exec , (using the command lines) with additional parameters, and especially the IOTMonitor id, to track it down. 

If the process does not respond periodically to mqtt topic, then the iot monitor can kill and restart the process, setting up a specific stdout log file and stderr log linked to the process. Process is detached from IOTMonitor session to be able to stop the IOTMonitor without to kill all process and stop all system's functionnalities.

In this manner, there are no complex IPC to setup or invasive

### Additional concerns

<u>MQTT authentication on the behave of the process</u> : this can be added in defining environment variable in the process launch. The command line can then take them to do the necessary transmission.  



