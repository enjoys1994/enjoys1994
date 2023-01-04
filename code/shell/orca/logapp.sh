
kubeconfig=/Users/stt/.kube/config176

kubectl get po -norca-system --kubeconfig=$kubeconfig  |grep orcaapp-operator-con | awk '{print $1}' |
xargs kubectl logs -f -norca-system --kubeconfig=$kubeconfig











