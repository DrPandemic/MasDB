@echo off
REM Kill and delete the VM-MasDB1 machine, recreates it and start it again
cd ../
docker kill VM-MasDB1
docker rm VM-MasDB1
docker create --name "VM-MasDB1" --rm -i masdb.app
docker start VM-MasDB1
docker exec -d VM-MasDB1 epmd -daemon
docker cp . VM-MasDB1:/build/
docker exec VM-MasDB1 rm -rf _build
docker exec VM-MasDB1 rm -rf tmp
docker cp demo/vm1.env VM-MasDB1:/build/.env
docker exec VM-MasDB1 mix compile