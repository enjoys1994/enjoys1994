#!/usr/bin
rm -fr /Users/stt/Desktop/wgy/workspace/go/orca-installation-yamls.tar.gz

cd /Users/stt/Desktop/wgy/workspace/go/ && tar -zcvf /Users/stt/Desktop/wgy/workspace/go/orca-installation-yamls.tar.gz orca-installation-yamls

#回到当前执行目录
cd -

for ip in "10.20.144.165" "10.20.144.166"
do
  expect -c "
  set timeout 10

  spawn scp /Users/stt/Desktop/wgy/workspace/go/orca-installation-yamls.tar.gz root@${ip}:/home/wgy/
  
  expect \"password\"
  send \"Test@orca\r\"
  
  expect \"orca-installation-yamls.tar.gz\"
  spawn ssh root@${ip}
  
  expect \"password\"
  send \"Test@orca\r\"
  
  expect \"login\"
  send \"cd /home/wgy && rm -fr orca-installation-yamls && tar -zvxf orca-installation-yamls.tar.gz && rm -fr orca-installation-yamls.tar.gz  && exit \r\"
  
  
  expect eof
  "
done






