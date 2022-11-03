#!/usr/bin

host1="10.20.144.165:root/Test@orca"
host2="10.20.144.166:root/Test@orca"

node1=$(echo $host1 | awk -F ":" '{print $1}')
node2=$(echo $host2 | awk -F ":" '{print $1}')

pwd1=$(echo $host1 | awk -F "/" '{print $2}')
pwd2=$(echo $host2 | awk -F "/" '{print $2}')

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


#生成主备cluster
awk  '{ sub(/host=/,"host='${host1}'");print $0 }' generateCluster.sh  | awk '{ sub(/cluster-c/,"cluster-a");print $0 }' > generateCluster-${node1}.sh
awk  '{ sub(/host=/,"host='${host2}'");print $0 }' generateCluster.sh  | awk '{ sub(/cluster-c/,"cluster-b");print $0 }' > generateCluster-${node2}.sh

for host in  ${host1} ${host2}
  do
    node=$(echo $host | awk -F ":" '{print $1}')
    pwd=$(echo $host | awk -F "/" '{print $2}')
    uploadFile ${node} "root" "${pwd}"  "generateCluster-${node}.sh"  "/root"
    execCmd    ${node} "root" "${pwd}"  "sh generateCluster-${node}.sh && rm -fr generateCluster-${node}.sh &&  exit "
    downFile   ${node} "root" "${pwd}"  "/root/cluster.yaml" cluster.yaml
    execCmd    ${node} "root" "${pwd}"  "rm -fr cluster.yaml &&  exit "
    mv cluster.yaml  cluster-${node}.yaml
    rm -fr generateCluster-${node}.sh
done

echo "

kubectl apply -f cluster.yaml
# 集群打标签
# 给cluster-a打标签
kubectl label cluster -n orca-system   cluster-a orcastack.io/role=controller  --overwrite=true
kubectl label cluster -n orca-system   cluster-a orcastack.io/replication-role=primary --overwrite=true
kubectl label cluster -n orca-system   cluster-a topology.kubernetes.io/zone=A --overwrite=true
kubectl label clustercredentials -n orca-system   cluster-a orcastack.io/controller-cluster=true --overwrite=true
kubectl label cluster -n orca-system   cluster-a orcastack.io/replication-primary=cluster-b --overwrite=true
# 给cluster-b打标签
kubectl label clustercredential -n orca-system   cluster-b orcastack.io/controller-cluster=true --overwrite=true
kubectl label cluster -n orca-system   cluster-b orcastack.io/role=controller --overwrite=true
kubectl label cluster -n orca-system   cluster-b orcastack.io/replication-role=secondary --overwrite=true
kubectl label cluster -n orca-system   cluster-b orcastack.io/replication-primary=cluster-a --overwrite=true
kubectl label cluster -n orca-system   cluster-b topology.kubernetes.io/zone=B --overwrite=true

" > set_orca_cluster.sh

mv cluster-${node1}.yaml cluster.yaml
uploadFile ${node2} "root" "${pwd2}"  "cluster.yaml set_orca_cluster.sh"  "/root"
execCmd    ${node2} "root" "${pwd2}"  "sh set_orca_cluster.sh && rm -fr set_orca_cluster.sh && rm -fr cluster.yaml   &&  exit "
rm -fr cluster.yaml

mv cluster-${node2}.yaml cluster.yaml
uploadFile ${node1} "root" "${pwd1}"  "cluster.yaml set_orca_cluster.sh"  "/root"
execCmd    ${node1} "root" "${pwd1}"  "sh set_orca_cluster.sh && rm -fr set_orca_cluster.sh && rm -fr cluster.yaml  &&  exit "
rm -fr cluster.yaml
rm -fr set_orca_cluster.sh





## 配置etcd
cp ./etcd-mirror/values.yaml values.yaml

awk '{ sub(/master: ~/,"master: '$node2':2379");print $0 }' values.yaml | awk '{ sub(/slave: ~/,"slave: '$node1':2379");print $0 }' >values.yaml-${node2}
awk '{ sub(/master: ~/,"master: '$node1':2379");print $0 }' values.yaml | awk '{ sub(/slave: ~/,"slave: '$node2':2379");print $0 }' >values.yaml-${node1}

for host in $host1 $host2; do
  node=$(echo $host | awk -F ":" '{print $1}')
  pwd=$(echo $host | awk -F "/" '{print $2}')
  nodefile=values.yaml-${node}
  for etcdfile in "ca.crt" "server.crt" "server.key"; do
    downFile ${node} "root" "${pwd}" "/etc/kubernetes/pki/etcd/${etcdfile}" ${etcdfile}
    sed -ig 's/^/      /' ${etcdfile}
  done

  row=$(sed -n "/master_etcd_key:/=" ${nodefile})
  sed -ig ''${row}' r server.key' ${nodefile}
  row=$(sed -n "/master_etcd_cert:/=" ${nodefile})
  sed -ig ''${row}' r server.crt' ${nodefile}
  row=$(sed -n "/master_etcd_cacert:/=" ${nodefile})
  sed -ig ''${row}' r ca.crt' ${nodefile}

  for etcdfile in "ca.crt" "server.crt" "server.key"; do
    rm -fr ${etcdfile}g
    rm -fr ${etcdfile}
  done
  rm -fr ${nodefile}g
done
  mv values.yaml-${node2} tmp
  mv values.yaml-${node1} values.yaml-${node2}
  mv tmp values.yaml-${node1}

for host in $host1 $host2; do
  node=$(echo $host | awk -F ":" '{print $1}')
  pwd=$(echo $host | awk -F "/" '{print $2}')
  mv values.yaml-${node} ./etcd-mirror/values.yaml
  uploadFile ${node} "root" "${pwd}" "etcd-mirror" "/root"
  execCmd ${node} "root" "${pwd}" "helm upgrade --install etcd-mirror ./etcd-mirror -n orca-system && rm -fr etcd-mirror && exit "
done

mv values.yaml ./etcd-mirror/values.yaml

# 主备集群开始同步
for host in $host1 $host2; do
  echo "
  apiVersion: failover.orcastack.io/v1alpha1
  kind: ControllerFailOver
  metadata:
    namespace: orca-system
    generateName: controller-failover-
  spec:
    # 对应Cluster对象上的topology.kubernetes.io/zone标签 A就代表切换到A机房
    primaryZone: A " > orca_text.yaml
  node=$(echo $host | awk -F ":" '{print $1}')
  pwd=$(echo $host | awk -F "/" '{print $2}')
  uploadFile ${node} "root" "${pwd}" "orca_text.yaml" "/root"
  execCmd ${node} "root" "${pwd}" "kubectl create -f orca_text.yaml && rm -fr orca_text.yaml && exit "
  rm -fr orca_text.yaml
done

