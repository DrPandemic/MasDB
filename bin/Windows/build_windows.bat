@echo off
REM Kill and delete the VM-MasDB machine, recreates it and start it again
cd ../../
docker kill VM-MasDB
docker rm VM-MasDB
docker build -t masdb.app -f Dockerfile.build --build-arg APP=masdb .
docker create --name "VM-MasDB" --rm -i masdb.app
docker start VM-MasDB
docker exec -d VM-MasDB epmd -daemon