#!/usr/bin

cp ../base/base.sh base.sh
cp ../host.conf host.conf

source ./base.sh

master=$(cat host.conf | grep master | awk -F "=" '{print $2}')
slave=$(cat host.conf | grep slave | awk -F "=" '{print $2}')

masterIp=$(echo $master | awk -F ":" '{print $1}')
slaveIp=$(echo $slave | awk -F ":" '{print $1}')


## 配置etcd
cp etcd-mirror/values.yaml values.yaml

awk '{ sub(/master: ~/,"master: '$slaveIp':2379");print $0 }' values.yaml | awk '{ sub(/slave: ~/,"slave: '$masterIp':2379");print $0 }' >values.yaml-${slaveIp}
awk '{ sub(/master: ~/,"master: '$masterIp':2379");print $0 }' values.yaml | awk '{ sub(/slave: ~/,"slave: '$slaveIp':2379");print $0 }' >values.yaml-${masterIp}

for host in $master $slave; do
  ip=$(echo $host | awk -F ":" '{print $1}')
  pwd=$(echo $host | awk -F "/" '{print $2}')
  ipfile=values.yaml-${ip}
  name=$(echo $host  |awk -F "[:/]" '{print $2}')
  for etcdfile in "ca.crt" "server.crt" "server.key"; do
    downFile ${ip} ${name} "${pwd}" "/etc/kubernetes/pki/etcd/${etcdfile}" ${etcdfile}
    sed -ig 's/^/      /' ${etcdfile}
  done

  row=$(sed -n "/master_etcd_key:/=" ${ipfile})
  sed -ig ''${row}' r server.key' ${ipfile}
  row=$(sed -n "/master_etcd_cert:/=" ${ipfile})
  sed -ig ''${row}' r server.crt' ${ipfile}
  row=$(sed -n "/master_etcd_cacert:/=" ${ipfile})
  sed -ig ''${row}' r ca.crt' ${ipfile}

  for etcdfile in "ca.crt" "server.crt" "server.key"; do
    rm -fr ${etcdfile}g
    rm -fr ${etcdfile}
  done
  rm -fr ${ipfile}g
done
mv values.yaml-${slaveIp} tmp
mv values.yaml-${masterIp} values.yaml-${slaveIp}
mv tmp values.yaml-${masterIp}


for host in $master $slave; do
  ip=$(echo $host | awk -F ":" '{print $1}')
  pwd=$(echo $host | awk -F "/" '{print $2}')
  name=$(echo $host  |awk -F "[:/]" '{print $2}')
  mv values.yaml-${ip} ./etcd-mirror/values.yaml
  uploadFile ${ip} ${name} "${pwd}" "etcd-mirror" "/root"
  execCmd ${ip} ${name} "${pwd}" "helm upgrade --install etcd-mirror ./etcd-mirror -n orca-system && rm -fr etcd-mirror && exit "
done

rm -fr values.yaml
rm -fr base.sh
rm -fr host.conf