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

ip=10.20.144.166
username=root
password=Test@orca


execCmd $ip  $username $password "rm -fr /home/wgy/see/tomcat/.sql_md5.properties"
execCmd $ip  $username $password "cd /home/wgy/see && sh shutDownWithoutDb.sh && sh startUpWithoutDb.sh "