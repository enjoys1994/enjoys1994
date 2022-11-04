#!/usr/bin

cp ../base/base.sh base.sh
cp ../host.conf host.conf

source ./base.sh

master=$(cat host.conf | grep master | awk -F "=" '{print $2}')
slave=$(cat host.conf | grep slave | awk -F "=" '{print $2}')

masterIp=$(echo $master | awk -F ":" '{print $1}')
slaveIp=$(echo $slave | awk -F ":" '{print $1}')

masterName=$(echo $master  |awk -F "[:/]" '{print $2}')
slaveName=$(echo $slave  |awk -F "[:/]" '{print $2}')

masterPwd=$(echo $master | awk -F "/" '{print $2}')
slavePwd=$(echo $slave | awk -F "/" '{print $2}')

#生成主备cluster
awk '{ sub(/host=/,"host='${master}'");print $0 }' generateCluster | awk '{ sub(/cluster-c/,"cluster-a");print $0 }' >generateCluster-${masterIp}.sh
awk '{ sub(/host=/,"host='${slave}'");print $0 }' generateCluster | awk '{ sub(/cluster-c/,"cluster-b");print $0 }' >generateCluster-${slaveIp}.sh

for host in ${master} ${slave}; do
  ip=$(echo $host | awk -F ":" '{print $1}')
  pwd=$(echo $host | awk -F "/" '{print $2}')
  name=$(echo $host  |awk -F "[:/]" '{print $2}')
  uploadFile ${ip} ${name} "${pwd}" "generateCluster-${ip}.sh" "/root"
  execCmd ${ip} ${name} "${pwd}" "sh generateCluster-${ip}.sh && rm -fr generateCluster-${ip}.sh &&  exit "
  downFile ${ip} ${name} "${pwd}" "/root/cluster.yaml" cluster.yaml
  execCmd ${ip} ${name} "${pwd}" "rm -fr cluster.yaml &&  exit "
  mv cluster.yaml cluster-${ip}.yaml
  rm -fr generateCluster-${ip}.sh
done

echo "

kubectl apply -f cluster.yaml
# 集群打标签
# 给cluster-a打标签
kubectl label cluster -n orca-system   cluster-a orcastack.io/role=controller  --overwrite=true
kubectl label cluster -n orca-system   cluster-a orcastack.io/replication-role=primary --overwrite=true
kubectl label cluster -n orca-system   cluster-a topology.kubernetes.io/zone=A --overwrite=true
kubectl label cluster -n orca-system   cluster-a orcastack.io/replication-primary=cluster-b --overwrite=true
kubectl label clustercredentials -n orca-system   cluster-a orcastack.io/controller-cluster=true --overwrite=true
# 给cluster-b打标签
kubectl label cluster -n orca-system   cluster-b orcastack.io/role=controller --overwrite=true
kubectl label cluster -n orca-system   cluster-b orcastack.io/replication-role=secondary --overwrite=true
kubectl label cluster -n orca-system   cluster-b orcastack.io/replication-primary=cluster-a --overwrite=true
kubectl label cluster -n orca-system   cluster-b topology.kubernetes.io/zone=B --overwrite=true
kubectl label clustercredential -n orca-system   cluster-b orcastack.io/controller-cluster=true --overwrite=true

" >set_orca_cluster.sh

mv cluster-${masterIp}.yaml cluster.yaml
uploadFile ${slaveIp} ${slaveName} "${slavePwd}" "cluster.yaml set_orca_cluster.sh" "/root"
execCmd ${slaveIp} ${slaveName} "${slavePwd}" "sh set_orca_cluster.sh && rm -fr set_orca_cluster.sh && rm -fr cluster.yaml   &&  exit "
rm -fr cluster.yaml

mv cluster-${slaveIp}.yaml cluster.yaml
uploadFile ${masterIp} ${masterName} "${masterPwd}" "cluster.yaml set_orca_cluster.sh" "/root"
execCmd ${masterIp} ${masterName} "${masterPwd}" "sh set_orca_cluster.sh && rm -fr set_orca_cluster.sh && rm -fr cluster.yaml  &&  exit "
rm -fr cluster.yaml
rm -fr set_orca_cluster.sh

rm -fr base.sh
rm -fr host.conf