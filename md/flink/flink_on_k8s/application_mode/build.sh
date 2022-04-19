#!/bin/bash

docker build -t 192.168.120.160:5000/flink_app_topspeedwindowing:0.1_1.14.4_2.11 .
docker push 192.168.120.160:5000/flink_app_topspeedwindowing:0.1_1.14.4_2.11