#!/bin/bash

#start the webserver
/home/matteo/dev/simpleWebServer/startWebServer.sh &
PIDs=$!

trap "kill -s INT $PIDs; exit" SIGINT

websocketd --port=8080 --staticdir=. ./count.sh
