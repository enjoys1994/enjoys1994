
kubeconfig=/Users/stt/.kube/config165

kubectl get po -norca-system --kubeconfig=$kubeconfig  |grep orcaapp-operator-con | awk '{print $1}' |
xargs kubectl logs -f -norca-system --kubeconfig=$kubeconfig





#  kubectl get po -norca-system   |grep orcaapp-operator-con | awk '{print $1}' |xargs kubectl logs -f -norca-system





