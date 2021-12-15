
BINDIR=/usr/bin/iotmonitor
MANDIR=/usr/share/man/man1

iotmonitor: 
	cd paho.mqtt.c && cmake -DPAHO_BUILD_STATIC=true 
	cd paho.mqtt.c && make 
	mkdir -p bin
	zig build 
	pandoc man/iotmonitor.1.md -s -t man | gzip -c > bin/iotmonitor.1.gz

install: 
	cp bin/iotmonitor $(BINDIR)
	cp bin/iotmonitor.1.gz $(MANDIR)/

