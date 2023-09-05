


#rosa edit machinepool --cluster=<cluster_name> <machinepool_ID> --enable-autoscaling --min-replicas=<number> --max-replicas=<number>


https://redhat-scholars.github.io/kubernetes-tutorial/kubernetes-tutorial/taints-affinity.html

https://aws.amazon.com/blogs/containers/eliminate-kubernetes-node-scaling-lag-with-pod-priority-and-over-provisioning/
https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-can-i-configure-overprovisioning-with-cluster-autoscaler


minikube start --nodes 8



kubectl label nodes minikube-m02 hypershift.operator.io/serving-component=true
#kubectl taint nodes minikube-m02 key1=value1:NoSchedule
kubectl label nodes minikube-m02 topolog.kubernetes.io/zone=zone-a

kubectl label nodes minikube-m03 hypershift.operator.io/serving-component=true
kubectl label nodes minikube-m03 topolog.kubernetes.io/zone=zone-b

kubectl label nodes minikube-m04 topolog.kubernetes.io/zone=zone-c

kubectl label nodes minikube-m05 hypershift.operator.io/serving-component=true
kubectl label nodes minikube-m05 topolog.kubernetes.io/zone=zone-a

kubectl label nodes minikube-m06 hypershift.operator.io/serving-component=true
kubectl label nodes minikube-m06 topolog.kubernetes.io/zone=zone-b

kubectl label node minikube-m07 topolog.kubernetes.io/zone=zone-c



#Possibilita' di aggiungere delle label al volo :)
# minikube node add

# minikube node delete <node name>


https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
