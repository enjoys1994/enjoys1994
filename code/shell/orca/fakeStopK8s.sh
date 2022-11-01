

for ip in "10.20.144.165"   "10.20.144.172"     "10.20.144.180"   "10.20.45.175"
do
  expect -c "
  set timeout 10

  spawn ssh root@${ip}

  expect {
    \"continue\" {send \"yes\r\";exp_continue}
    \"password\" {send \"Test@orca\r\";exp_continue}
    \"login\"    {send \"systemctl stop docker && systemctl stop kubelet && systemctl stop etcd && exit \r\";}
  }

  expect eof
  "
done

