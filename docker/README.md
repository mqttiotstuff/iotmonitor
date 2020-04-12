# Docker for iotmonitor

this docker create the iotmonitor image, for x64 platefoms

# Building the image

	docker build -t iotmonitor .


# Running the container

the current folder must have the config.toml configuration file


	docker run --rm -d -v `pwd`:/config iotmonitor
