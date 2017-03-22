@echo off
REM Kill and delete the VM-MasDB3 machine, recreates it and start it again
cd ../
docker kill VM-MasDB3
docker rm VM-MasDB3
docker create --name "VM-MasDB3" --rm -i masdb.app
docker start VM-MasDB3
docker exec -d VM-MasDB3 epmd -daemon
docker cp . VM-MasDB3:/build/
docker exec VM-MasDB3 rm -rf _build
docker exec VM-MasDB3 rm -rf tmp
docker cp demo/vm3.env VM-MasDB3:/build/.env
docker exec VM-MasDB3 mix compile