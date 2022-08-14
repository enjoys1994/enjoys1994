echo "
apiVersion: failover.orcastack.io/v1alpha1
kind: ControllerFailOver
metadata:
  namespace: orca-system
  generateName: controller-failover-
spec:
  # 对应Cluster对象上的topology.kubernetes.io/zone标签 A就代表切换到A机房
  primaryZone: $1 " > orca_text.yaml

kubectl create -f orca_text.yaml
rm -fr orca_text.yaml