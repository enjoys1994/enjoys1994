#!/usr/bin
host=

node=$(echo $host | awk -F ":" '{print $1}')

token=$(kubectl describe  secret  -n kube-system $(kubectl get secret -n kube-system |grep ko-admin-token | awk '{print $1}')  |grep token: |awk -F " " '{print $2}')

#生成cluster对下
echo "
apiVersion: core.orcastack.io/v1alpha1
kind: ClusterCredential
metadata:
  name: cluster-c
  namespace: orca-system
spec:
  apiserver:
    - https://$node:8443
  clusterName: cluster-c
  token: $token
" > cluster.yaml
