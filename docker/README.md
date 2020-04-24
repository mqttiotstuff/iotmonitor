# Docker for iotmonitor

this docker create the iotmonitor image, for x64 platefoms

# Building the image

	docker build -t iotmonitor .


# Running the container

The current folder must have the config.toml configuration file, and write access to the executing USER, to create the leveldb database associated to device states

	docker run --rm -d -u $(id --user) -v `pwd`:/config iotmonitor





# RPI compilation (to be tested)


	docker run -it -v $HOME/.dockerpi:/sdcard lukechilds/dockerpi


