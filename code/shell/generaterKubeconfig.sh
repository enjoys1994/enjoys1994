#生成k8s kubeconfig的
# ./generaterKubeconfig.sh  10.20.144.28:8443

CN=kubernetes
role=apiserver-kubelet-client
context=newcontext
kubeconfig=kubeconfig



#1. 设置集群集群信息到指定kubeconfig文件中
kubectl config set-cluster $CN --certificate-authority=/etc/kubernetes/pki/ca.crt --server=https://$1 --kubeconfig=$kubeconfig.conf --embed-certs=true

#2.为某个账号生成credential到该文件中
kubectl config set-credentials $kubeconfig --client-certificate=/etc/kubernetes/pki/$role.crt --client-key=/etc/kubernetes/pki/$role.key --kubeconfig=$kubeconfig.conf --embed-certs=true

#3.添加集群的上下文信息到该文件中 ，这个上下文名叫kubernetes，对应的集群是kubernetes，用户是apiserver
kubectl config set-context $context --cluster=$CN --user=$kubeconfig --kubeconfig=$kubeconfig.conf

#4. 设置 kubeconfig 文件中的当前上下文为新的上下文
kubectl config use-context $context --kubeconfig=$kubeconfig.conf

cat $kubeconfig.conf

rm -fr $kubeconfig.conf