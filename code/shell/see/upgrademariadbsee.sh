set -e
set -x

function execCmd() {
  ip=$1
  username=$2
  password=$3
  command=$4
  expect -c "
    set timeout -1
    spawn ssh  ${username}@${ip} ${command}
    expect {
       \"*continue*\" {send \"yes\r\";exp_continue}
       \"*password*\" {send \"${password}\r\";exp_continue}
       expect eof
    }
    "
}

function uploadFile() {
  ip=$1
  username=$2
  password=$3
  source=$4
  target=$5
  expect -c "
    set timeout -1
    spawn rsync -ar ${source} ${username}@$1:${target}
    expect {
       \"*continue*\" {send \"yes\r\";exp_continue}
       \"*password*\" {send \"${password}\r\";exp_continue}
       expect eof
    }
    "
}

ip=10.20.144.166
username=root
password=Test@orca
upgradePath=$2

file=$1

file_name=$(basename "$file")

execCmd $ip  $username $password "rm -fr ${upgradePath}"

uploadFile $ip $username $password ${file}  "${upgradePath}"

execCmd $ip  $username $password "cd ${upgradePath} && unzip ${file_name}"

rm -fr $file

expect -c "
  set timeout -1
  spawn ssh  ${username}@${ip}
  expect {
     \"*continue*\" {send \"yes\r\";exp_continue}
     \"*password*\" {send \"${password}\r\";exp_continue}
     \"login\"      {send \"cd ${upgradePath}see && sh upgrade.sh \r \";exp_continue}
     \"*Back up see*\"      {send \"no\r \";exp_continue}
     \"*successfully upgraded*\"      {send \"yes\r \";exp_continue}
     expect eof
  }
  "