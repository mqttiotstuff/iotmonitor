# Docker for iotmonitor

this docker create the iotmonitor image, for x64 platefoms
note that if you run the iotmonitor as a container, processes must be also hosted in the container.

# Building the image using the zig master

The COMMIT variable indicated the master 0.6 commit to use, (check http://ziglang.org/downloads for the current value)

	docker build --build-arg COMMIT=9fe4c8923 -t iotmonitor .

# Running the container

The current folder must have the config.toml configuration file, and write access to the executing USER, to create the leveldb database associated to device states

	docker run --rm -d -u $(id --user) -v `pwd`:/config iotmonitor


# RPI compilation (to be tested)


	docker run -it -v $HOME/.dockerpi:/sdcard lukechilds/dockerpi


