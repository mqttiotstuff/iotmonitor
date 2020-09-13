
DESTDIR=/usr/bin/iotmonitor

iotmonitor: 
	cd paho.mqtt.c && cmake -DPAHO_BUILD_STATIC=true 
	cd paho.mqtt.c && make 
	mkdir -p bin
	zig build 

install: 
	cp bin/iotmonitor $(DESTDIR)/

