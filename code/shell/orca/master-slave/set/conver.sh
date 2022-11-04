#!/usr/bin

cp ../base/base.sh base.sh
cp ../host.conf host.conf

source ./base.sh

master=$(cat host.conf | grep master | awk -F "=" '{print $2}')
slave=$(cat host.conf | grep slave | awk -F "=" '{print $2}')

# 主备集群开始同步
for host in $master $slave; do
  echo "
  apiVersion: failover.orcastack.io/v1alpha1
  kind: ControllerFailOver
  metadata:
    namespace: orca-system
    generateName: controller-failover-
  spec:
    # 对应Cluster对象上的topology.kubernetes.io/zone标签 A就代表切换到A机房
    primaryZone: A " >create_failover.yaml
  ip=$(echo $host | awk -F ":" '{print $1}')
  pwd=$(echo $host | awk -F "/" '{print $2}')
  name=$(echo $host  |awk -F "[:/]" '{print $2}')
  uploadFile ${ip} ${name} "${pwd}" "create_failover.yaml" "/root"
  execCmd ${ip} ${name} "${pwd}" "kubectl create -f create_failover.yaml && rm -fr create_failover.yaml && exit "
  rm -fr create_failover.yaml
done

rm -fr base.sh
rm -fr host.conf