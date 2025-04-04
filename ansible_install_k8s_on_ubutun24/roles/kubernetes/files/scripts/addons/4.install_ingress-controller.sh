#!/bin/bash


# 安装 ingress-controller
tar -xf ingress-nginx-*.tgz
cd ingress-nginx/

# 创建命名空间
kubectl create ns ingress-nginx

# 为所有节点添加标签
for var in `kubectl get nodes | grep -v 'NAME' | awk '{print $1}'`; do kubectl label node $var ingress=true; done

# 替换镜像地址
sed -i "s#registry.k8s.io#k8s.m.daocloud.io#g" values.yaml

# 安装 ingress-controller
helm install ingress-nginx -n ingress-nginx .

# 删除验证 webhook
kubectl delete validatingwebhookconfigurations ingress-nginx-admission

# 扩容 ingress-controller
kubectl scale deployment -n ingress-nginx ingress-nginx-controller --replicas 2
