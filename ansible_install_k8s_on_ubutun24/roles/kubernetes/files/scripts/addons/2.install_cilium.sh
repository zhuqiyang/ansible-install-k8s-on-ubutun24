#!/bin/bash

# 安装 cilium
tar -xf cilium-*.tgz
cd cilium/

# 替换镜像地址
sed -i "s#quay.io/#m.daocloud.io\/quay.io/#g" values.yaml

# 安装 cilium
helm install cilium . --namespace kube-system --set hubble.relay.enabled=true --set hubble.ui.enabled=true --set prometheus.enabled=true --set operator.prometheus.enabled=true --set hubble.enabled=true --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}"
