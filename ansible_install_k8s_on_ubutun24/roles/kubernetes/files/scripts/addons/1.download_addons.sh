#!/bin/bash


安装 helm
wget https://mirrors.huaweicloud.com/helm/v3.16.3/helm-v3.16.3-linux-amd64.tar.gz
tar -xf helm-*-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin/

# 下载 cilium
helm repo add cilium https://helm.cilium.io
helm pull cilium/cilium

# 下载 coredns
helm repo add coredns https://coredns.github.io/helm
helm pull coredns/coredns

# 下载 ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm pull ingress-nginx/ingress-nginx

# 下载 metrics-server
# wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml -O metrics-server.yaml
