#删除所有webhook

kubectl get validatingwebhookconfiguration | awk '{print $1}' | xargs kubectl delete validatingwebhookconfiguration
kubectl get mutatingwebhookconfiguration | awk '{print $1}' | xargs kubectl delete mutatingwebhookconfiguration




#快速删除所有资源
kubectl api-resources --verbs=list --namespaced -o name | grep -v events | xargs -n 1 kubectl get --show-kind --ignore-not-found --no-headers -n $1 | awk '{print $1}' | xargs -n 1 kubectl patch -p '{"metadata":{"finalizers":[]}}' --type='merge' -n $1