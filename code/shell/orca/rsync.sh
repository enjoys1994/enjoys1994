#!/usr/bin

cd /Users/stt/Desktop/wgy/workspace/go/orca-installation-yamls
git pull
#回到当前执行目录
cd -

for ip in "10.20.144.165" "10.20.144.166"; do
  expect -c "
  set timeout 10

  spawn rsync -ar /Users/stt/Desktop/wgy/workspace/go/orca-installation-yamls root@${ip}:/home/wgy/
  expect \"password\"
  send \"Test@orca\r\"

  expect eof
  "
done
