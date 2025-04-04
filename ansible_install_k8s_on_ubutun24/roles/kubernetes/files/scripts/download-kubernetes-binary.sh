#!/bin/bash

# 下载kubernetes二进制文件
wget https://dl.k8s.io/v1.32.2/kubernetes-server-linux-amd64.tar.gz

tar -xzvf kubernetes-server-linux-amd64.tar.gz

mv kubernetes/server/bin/{kube-apiserver,kube-controller-manager,kubectl,kubelet,kube-proxy,kube-scheduler} ./bin/

rm -rf kubernetes-server-linux-amd64.tar.gz kubernetes



if ! command -v cfssl >/dev/null 2>&1; then
    wget -O /usr/local/bin/cfssl https://mirrors.chenby.cn/https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssl_1.6.4_linux_amd64
    chmod +x /usr/local/bin/cfssl
fi

if ! command -v cfssljson >/dev/null 2>&1; then
    wget -O /usr/local/bin/cfssljson https://mirrors.chenby.cn/https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssljson_1.6.4_linux_amd64
    chmod +x /usr/local/bin/cfssljson
fi

if ! command -v kubectl >/dev/null 2>&1; then
    cp ./bin/kubectl /usr/local/bin/
fi


if [ ! -f ./bin/cri-dockerd ]; then
    wget  https://mirrors.chenby.cn/https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.16/cri-dockerd-0.3.16.amd64.tgz
    # 解压cri-docker
    tar -xf cri-dockerd-*.amd64.tgz
    mv cri-dockerd ./bin/
    rm -rf cri-dockerd-*.amd64.tgz
fi
