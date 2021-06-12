FROM ubuntu:20.04 AS builder
ARG COMMIT
ARG VERSION

RUN apt-get update
RUN apt-get install -y build-essential git  libleveldb-dev 
RUN apt-get install -y wget xz-utils
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y cmake

WORKDIR /build

COPY grabzigbinary.sh .
RUN chmod a+x grabzigbinary.sh
RUN ./grabzigbinary.sh $VERSION $COMMIT

RUN git clone --recursive https://github.com/mqttiotstuff/iotmonitor
WORKDIR /build/iotmonitor
RUN git checkout develop
WORKDIR /build/iotmonitor/paho.mqtt.c
RUN cmake -DPAHO_BUILD_STATIC=true .
RUN make
WORKDIR /build/iotmonitor
RUN mkdir bin

RUN ../zigbundle/zig build

FROM ubuntu:20.04

RUN apt-get update
RUN apt-get install -y libleveldb-dev
WORKDIR /iotmonitor/
COPY --from=builder /build/iotmonitor/bin/iotmonitor .
RUN chmod a+rx iotmonitor

WORKDIR /config

CMD ["../iotmonitor/iotmonitor"]
