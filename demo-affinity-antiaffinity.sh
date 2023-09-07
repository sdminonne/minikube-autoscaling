#!/usr/bin/env bash


PROFILE=demo
NBNODES=7
minikube start --nodes ${NBNODES} -p ${PROFILE}
kubectl taint nodes demo node-role.kubernetes.io/control-plane=:NoSchedule

#since minikube doesn't taint controlplane node.
# if you want to add a node-selector we need this on workers.
#kubectl label nodes ${nodename} node-role.kubernetes.io/worker=true  --overwrite=true

kubectl apply -f manifests/priority-class

#To define zones
for i in $(eval echo {2..$NBNODES})
do
    zone=""
    nodename=$(printf 'demo-m%02d' $i) ;
    case $i in
        2|5) zone="zone-a";;
        3|6) zone="zone-b";;
        4|7) zone="zone-c";;
    esac
    kubectl label nodes ${nodename} topology.kubernetes.io/zone=${zone} --overwrite=true
done


#To define serving nodes
for i in $(eval echo {2..$NBNODES})
do
    nodename=$(printf 'demo-m%02d' $i) ;
    case $i in
        2|3|5|6) kubectl taint nodes ${nodename} hypershift.operator.io/serving-component=true:NoSchedule
    esac
done

kubectl apply -f manifests/affinity-anti-affinity/red
kubectl apply -f manifests/affinity-anti-affinity/placeholders
kubectl get pods -lcolor -ojsonpath='{range .items[*]}{@.metadata.name} {" is "}{@.status.phase}{" on "}{@.spec.nodeName}{"\n"}{end}'




kubectl get pods -lcolor -ojsonpath='{range .items[*]}{@.metadata.name} {" is "}{@.status.phase}{" on "}{@.spec.nodeName}{"\n"}{end}'

minikube -p demo node add
kubectl label nodes demo-m08 hypershift.operator.io/serving-component=true


add_node() {
    zone=$1
    # if zone is empty set zone-a
    [ -z $zone ] && zone="zone-a"
    REX="node/${PROFILE}-m([0-9]+)"
    for n in $(kubectl get nodes -o name); do
        max=0;
        if [[ $n =~ $REX ]] then
           value=$(( 10#${BASH_REMATCH[1]} ));
           max=$(( value > max ? value : max ))
        fi
    done
    nodename=$(printf '%s-m%02d' ${PROFILE} $((max + 1 )) ) ;
    minikube -p ${PROFILE} node add
    kubectl label nodes ${nodename} topology.kubernetes.io/zone=${zone} --overwrite=true
    echo $nodename
}

add_serving_node() {
    nodename=$(add_node $1)
    kubectl taint nodes ${nodename} hypershift.operator.io/serving-component=true:NoSchedule
}

nodename=$(printf '%s-m%02d' ${PROFILE} $((max + 1 )) ) ;
