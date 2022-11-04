

cp ../host.conf host.conf


master=$(cat host.conf | grep master | awk -F "=" '{print $2}')
slave=$(cat host.conf | grep slave | awk -F "=" '{print $2}')

masterIp=$(echo $master | awk -F ":" '{print $1}')
slaveIp=$(echo $slave | awk -F ":" '{print $1}')

ssh-keygen -R masterIp
ssh-keygen -R slaveIp

rm -fr host.conf