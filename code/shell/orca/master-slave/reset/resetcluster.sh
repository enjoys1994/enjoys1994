
cp ../base/base.sh base.sh
cp ../host.conf host.conf

source ./base.sh

master=$(cat host.conf | grep master | awk -F "=" '{print $2}')
slave=$(cat host.conf | grep slave | awk -F "=" '{print $2}')

echo "

kubectl label cluster -n orca-system   cluster-a orcastack.io/role-
kubectl label cluster -n orca-system   cluster-a orcastack.io/replication-role-
kubectl label cluster -n orca-system   cluster-a topology.kubernetes.io/zone-
kubectl label cluster -n orca-system   cluster-a orcastack.io/replication-primary-
kubectl label clustercredentials -n orca-system   cluster-a orcastack.io/controller-cluster-

kubectl label cluster -n orca-system   cluster-b orcastack.io/role-
kubectl label cluster -n orca-system   cluster-b orcastack.io/replication-role-
kubectl label cluster -n orca-system   cluster-b orcastack.io/replication-primary-
kubectl label cluster -n orca-system   cluster-b topology.kubernetes.io/zone-
kubectl label clustercredential -n orca-system   cluster-b orcastack.io/controller-cluster-
" >reset_cluster.sh

for host in ${master} ${slave}; do
  ip=$(echo $host | awk -F ":" '{print $1}')
  pwd=$(echo $host | awk -F "/" '{print $2}')
  name=$(echo $host  |awk -F "[:/]" '{print $2}') 
  uploadFile ${ip} ${name} "${pwd}" "reset_cluster.sh" "/root"
  execCmd ${ip} ${name} "${pwd}" "sh reset_cluster.sh && rm -fr reset_cluster.sh   &&  exit "
done
rm -fr reset_cluster.sh

rm -fr base.sh
rm -fr host.conf