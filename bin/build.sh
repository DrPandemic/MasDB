#!/bin/sh

docker build -t builder.app -f Dockerfile.build --build-arg APP=app .
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock builder.app docker build -t masdb.app -f Dockerfile --build-arg APP=masdb --build-arg MODE=foreground .
