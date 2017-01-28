#!/bin/sh

docker build -t buildhelper.app -f Dockerfile.build --build-arg APP=masdb .
docker run -v /var/run/docker.sock:/var/run/docker.sock buildhelper.app docker build -t build.app -f Dockerfile --build-arg APP=masdb --build-arg VERSION=0.1.0 .
