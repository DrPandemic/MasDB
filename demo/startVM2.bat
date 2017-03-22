@echo off
REM Kill and delete the VM-MasDB2 machine, recreates it and start it again
cd ../
docker kill VM-MasDB2
docker rm VM-MasDB2
docker create --name "VM-MasDB2" --rm -i masdb.app
docker start VM-MasDB2
docker exec -d VM-MasDB2 epmd -daemon
docker cp . VM-MasDB2:/build/
docker exec VM-MasDB2 rm -rf _build
docker exec VM-MasDB2 rm -rf tmp
docker cp demo/vm2.env VM-MasDB2:/build/.env
docker exec VM-MasDB2 mix compile