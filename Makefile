
BINDIR=/usr/bin/iotmonitor
MANDIR=/usr/share/man/man1

iotmonitor: 
	cd paho.mqtt.c && cmake -DPAHO_BUILD_STATIC=true 
	cd paho.mqtt.c && make 
	mkdir -p bin
	zig build 

install: 
	cp bin/iotmonitor $(BINDIR)
	pandoc man/iotmonitor.1.md -s -t man | gzip -c > $(MANDIR)/iotmonitor.1.gz

