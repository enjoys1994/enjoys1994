#!/usr/bin

# uploadFile  ip username password sourcePath targetPath
function uploadFile() {
  ip=$1
  username=$2
  password=$3
  source=$4
  target=$5
  expect -c "
    set timeout 10
    spawn rsync -ar ${source} ${username}@$1:${target}
    expect {
       \"*continue*\" {send \"yes\r\";exp_continue}
       \"*password*\" {send \"${password}\r\";exp_continue}
       expect eof
    }
    "
}
# downFile  ip username password sourcePath targetPath
function downFile() {
  ip=$1
  username=$2
  password=$3
  source=$4
  target=$5
  expect -c "
  set timeout 10
  spawn scp ${username}@${ip}:${source} ${target}
  expect {
     \"*continue*\" {send \"yes\r\";exp_continue}
     \"*password*\" {send \"${password}\r\";exp_continue}
      expect eof
  }
      "
}
#ip username password command
function execCmd() {
  ip=$1
  username=$2
  password=$3
  command=$4
  expect -c "
    set timeout 10
    spawn ssh ${username}@${ip}
    expect {
       \"*continue*\" {send \"yes\r\";exp_continue}
       \"*password*\" {send \"${password}\r\";exp_continue}
       \"login\"      {send \"${command} \r\";exp_continue}
       expect eof
    }
    "
}