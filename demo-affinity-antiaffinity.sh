#!/usr/bin/env bash



PROFILE=demo
NBNODES=8
minikube start --nodes ${NBNODES} -p ${PROFILE}
kubectl taint nodes demo node-role.kubernetes.io/control-plane=:NoSchedule
#since minikube doesn't taint controlplane node.
# if you want to add a node-selector we need this on workers.
#kubectl label nodes ${nodename} node-role.kubernetes.io/worker=true  --overwrite=true

kubectl apply -f manifests/priority-class


echo "To define zones in minikube"
for i in $(eval echo {2..$NBNODES})
do
    zone=""
    nodename=$(printf 'demo-m%02d' $i) ;
    case $i in
        2|5|8) zone="zone-a";;
        3|6) zone="zone-b";;
        4|7) zone="zone-c";;
    esac
    kubectl label nodes ${nodename} topology.kubernetes.io/zone=${zone} --overwrite=true
done


# to flag some nodes as serving
for i in $(eval echo {2..$NBNODES})
do
    nodename=$(printf 'demo-m%02d' $i) ;
    case $i in
        2|3|5|6) kubectl label nodes ${nodename} hypershift.operator.io/serving-component=true
    esac
done


kubectl get nodes --show-labels=true

kubectl apply -f manifests/affinity-anti-affinity/pause
kubectl get pods -lcolor -ojsonpath='{range .items[*]}{@.metadata.name} {" is "}{@.status.phase}{" on "}{@.spec.nodeName}{"\n"}{end}'


kubectl apply -f manifests/affinity-anti-affinity/red

kubectl apply -f manifests/affinity-anti-affinity/blue



kubectl get pods -lcolor -ojsonpath='{range .items[*]}{@.metadata.name} {" is "}{@.status.phase}{" on "}{@.spec.nodeName}{"\n"}{end}'
kubectl get pods --field-selector spec.nodeName=${PROFILE}-m02


kubectl get nodes --show-labels=true


kubectl get pods -lcolor -ojsonpath='{range .items[*]}{@.metadata.name} {" is "}{@.status.phase}{" on "}{@.spec.nodeName}{"\n"}{end}'


get_next_node() {
    REX="node/${PROFILE}-m([0-9]+)"
    max=0;
    for n in $(kubectl get nodes -o name); do
         if [[ $n =~ $REX ]] then
           value=$(( 10#${BASH_REMATCH[1]} ));
           max=$(( value > max ? value : max ))
        fi
    done
    nodename=$(printf '%s-m%02d' ${PROFILE} $(( max + 1 )) ) ;
    echo ${nodename}
}


add_node_for_region() {
    zone=$1
    # if zone is empty set zone-a
    [ -z $zone ] && zone="zone-a"
    nodename=$(get_next_node)
    minikube -p ${PROFILE} node add >/dev/null 2>&1
    kubectl label nodes ${nodename} topology.kubernetes.io/zone=${zone} --overwrite=true >/dev/null 2>&1
    echo $nodename
}

add_serving_node_for_region() {
    nodename=$(add_node_for_region $1)
    kubectl label nodes ${nodename} hypershift.operator.io/serving-component=true
}
