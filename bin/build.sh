#!/bin/sh
docker build -t masdb.buildapp -f Dockerfile.build --build-arg APP=masdb .
docker create --name "VM-MasDB-Build" --rm -i masdb.buildapp
docker start VM-MasDB-Build
docker cp VM-MasDB-Build:/build/_build ./_build
docker stop VM-MasDB-Build