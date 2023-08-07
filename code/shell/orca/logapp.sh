
kubeconfig=/Users/stt/.kube/config176

kubectl get po -norca-system --kubeconfig=$kubeconfig  |grep orcaapp-operator-con | awk '{print $1}' |
xargs kubectl logs -f -norca-system --kubeconfig=$kubeconfig | grep test-orcactl-upgrade-sf8-24a17





#  kubectl get po -norca-system   |grep orcaapp-operator-con | awk '{print $1}' |xargs kubectl logs -f -norca-system -c watch





