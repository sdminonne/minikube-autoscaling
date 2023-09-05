#!/usr/bin/env bash


minikube start --nodes 11 -p demo
#kubectl apply -f manifests/priority-class/priority-class.yaml



for i in {2..10}
do
    nodename=$(printf 'demo-m%02d' $i)
    zone="zone-a"
    if  [ "$i" -gt "4" ] && [ $i -le "7" ]
    then
        zone="zone-b";
    else if  [ "$i" -gt "7" ]
             then
                 zone="zone-c";
         fi
    fi
    kubectl label nodes ${nodename} topology.kubernetes.io/zone=${zone} --overwrite=true
done


kubectl label nodes demo-m02 hypershift.operator.io/serving-component=true
kubectl label nodes demo-m03 hypershift.operator.io/serving-component=true

kubectl label nodes demo-m05 hypershift.operator.io/serving-component=true
kubectl label nodes demo-m06 hypershift.operator.io/serving-component=true


kubectl apply -f manifests/affinity-anti-affinity/


kubectl get pods -lcolor -ojsonpath='{range .items[*]}{@.metadata.name} {" is "}{@.status.phase}{" on "}{@.spec.nodeName}{"\n"}{end}'
