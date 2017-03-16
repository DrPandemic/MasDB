@echo off
REM After copying the build directory, simply run recompile() to refresh the VM
cd ../..
docker cp . VM-MasDB:/build