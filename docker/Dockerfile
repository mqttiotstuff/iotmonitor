FROM ubuntu:18.04 AS builder

RUN apt-get update
RUN apt-get install -y build-essential git  libleveldb-dev 
RUN apt-get install -y wget xz-utils
RUN apt-get install -y cmake

WORKDIR /build
RUN wget https://ziglang.org/download/0.6.0/zig-linux-x86_64-0.6.0.tar.xz 

RUN xz -d zig-linux-x86_64-0.6.0.tar.xz
RUN tar xvf zig-linux-x86_64-0.6.0.tar


RUN git clone --recursive https://github.com/frett27/iotmonitor
WORKDIR /build/iotmonitor/paho.mqtt.c
RUN cmake -DPAHO_BUILD_STATIC=true .
RUN make
WORKDIR /build/iotmonitor
RUN mkdir bin

RUN ../zig-linux-x86_64-0.6.0/zig build

FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y libleveldb-dev
WORKDIR /iotmonitor/
COPY --from=builder /build/iotmonitor/bin/iotmonitor .
RUN chmod a+rx iotmonitor

WORKDIR /config

CMD ["../iotmonitor/iotmonitor"]
