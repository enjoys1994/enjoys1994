#!/usr/bin

cd /Users/stt/Desktop/wgy/workspace/go/orca-installation-yamls
git pull


for ip in "10.20.144.165" "10.20.144.166" "10.20.45.176"; do
  rsync -ar /Users/stt/Desktop/wgy/workspace/go/orca-installation-yamls root@${ip}:/home/wgy/
done

Hello@k8s