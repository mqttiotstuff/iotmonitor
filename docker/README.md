# Docker for iotmonitor

this docker create the iotmonitor image, for x64 platefoms
note that if you run the iotmonitor as a container, processes must be also hosted in the container.

# Building the image using the zig master

The VERSION variable mention the master version
Optional, The COMMIT variable may be specified for the ZIG commit to use (zig dev repository), if not set, official RELEASE zig version IS used
(check http://ziglang.org/downloads for the current value)

for officiel release zig version:

	docker build --build-arg VERSION=0.8.0 -t iotmonitor .

	docker build --build-arg COMMIT=45212e3b3 --build-arg VERSION=0.9.0-dev.103 -t iotmonitor .

# Running the container

The current folder must have the config.toml configuration file, and write access to the executing USER, to create the leveldb database associated to device states

	docker run --rm -d -u $(id --user) -v `pwd`:/config iotmonitor


# RPI compilation (to be tested)


	docker run -it -v $HOME/.dockerpi:/sdcard lukechilds/dockerpi


