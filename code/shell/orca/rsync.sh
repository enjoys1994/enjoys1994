#!/usr/bash

#  sh /Users/stt/Desktop/wgy/workspace/go/wangguoyan/code/shell/orca/rsync.sh

set -x
set -e

if [ ! $1 ]; then
  echo "没有带参数" && exit
fi

ip=$1

cd /Users/stt/Desktop/wgy/workspace/go/orca-installation-yamls
git pull

rsync -ar /Users/stt/Desktop/wgy/workspace/go/orca-installation-yamls root@${ip}:/home/wgy/

expect -c "
  set timeout 10

  spawn ssh root@${ip}

  expect {
    \"continue\" {send \"yes\r\";exp_continue}
    \"password\" {send \"Test@orca\r\";exp_continue}
    \"login\"    {send \"cd  /home/wgy/orca-installation-yamls && sh update-helm.sh > log.log 2>&1 &  \r exit \r  \";}
  }

  expect eof
  "
