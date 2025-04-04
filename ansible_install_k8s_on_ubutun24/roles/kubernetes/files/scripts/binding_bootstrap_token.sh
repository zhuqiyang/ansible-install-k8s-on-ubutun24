#!/bin/bash

NUM=$(($RANDOM % 6)).$(($RANDOM % 10))
sleep $NUM;

kubectl get secret -n kube-system bootstrap-token-c8ad9c

if [ $? -gt 0 ]; then
    kubectl apply -f /root/bootstrap.secret.yaml
fi
