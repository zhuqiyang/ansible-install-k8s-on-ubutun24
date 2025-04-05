#!/bin/bash


dir=../ansible_install_k8s_on_ubutun24/roles/kubernetes/files


wget https://dl.k8s.io/v1.32.2/kubernetes-server-linux-amd64.tar.gz
tar -xf kubernetes-server-linux-amd64.tar.gz
cp kubernetes/server/bin/{kube-apiserver,kube-controller-manager,kubectl,kubelet,kube-proxy,kube-scheduler} ${dir}/bin/
cp kubernetes/server/bin/kubectl /usr/local/bin/
rm -rf kubernetes-server-linux-amd64.tar.gz kubernetes



if ! command -v cfssl >/dev/null 2>&1; then
    wget -O /usr/local/bin/cfssl https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssl_1.6.4_linux_amd64
    chmod +x /usr/local/bin/cfssl
fi

if ! command -v cfssljson >/dev/null 2>&1; then
    wget -O /usr/local/bin/cfssljson https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssljson_1.6.4_linux_amd64
    chmod +x /usr/local/bin/cfssljson
fi


wget  https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.16/cri-dockerd-0.3.16.amd64.tgz
tar -xf cri-dockerd-*.amd64.tgz
mv cri-dockerd/cri-dockerd ${dir}/bin/
rm -rf cri-dockerd-*.amd64.tgz cri-dockerd/


wget https://github.com/etcd-io/etcd/releases/download/v3.5.17/etcd-v3.5.17-linux-amd64.tar.gz
tar -xf etcd-v3.5.17-linux-amd64.tar.gz -C ${dir}/packages/
rm etcd-v3.5.17-linux-amd64.tar.gz


wget https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz
mv cni-plugins-linux-amd64-v1.6.2.tgz ${dir}/packages/
