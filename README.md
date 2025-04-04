# 在 ubutun24 server 系统中安装 Kubernetes 集群指南

## 前言
> 这个是ansible-playbook脚本，用来在ubutun24系统中安装二进制kubernetes集群，集群版本为 1.32，集群采用3 master节点，若干个node节点。

### 集群及工具版本
> 都是ubutun24的默认版本。
- kubernetes version 1.32
- ansible version 2.16.3
- python 3.12.3


## 1. 配置
> 安装 master 需要配置的变量，与ansible和节点信息有关
```bash
# cat ansible_install_k8s_on_ubutun24/inventory/kubernetes-master 
[all]
ansible_python_interpreter=/usr/bin/python3

[kubernetes-master]
master01.k8s.local ansible_host=192.168.0.121 etcd_hostname=etcd01.k8s.local sn=1
master02.k8s.local ansible_host=192.168.0.122 etcd_hostname=etcd02.k8s.local sn=2
master03.k8s.local ansible_host=192.168.0.123 etcd_hostname=etcd03.k8s.local sn=3

[kubernetes-master:vars]
etcd01_hostname=etcd01.k8s.local
etcd02_hostname=etcd02.k8s.local
etcd03_hostname=etcd03.k8s.local
master01_hostname=master01.k8s.local
master02_hostname=master02.k8s.local
master03_hostname=master03.k8s.local
```

> 安装 kubernetes 集群需要的变量
```bash
# cat ansible_install_k8s_on_ubutun24/inventory/group_vars/kubernetes-master.yml 
---
# SSL 证书相关变量
COMMON_WILDCARD_DOMAIN_NAME: '*.k8s.local'
COMMON_LOAD_BALANCE_HOSTNAME: 'master.k8s.local'
COMMON_LOAD_BALANCE_PORT: '8443'
COMMON_K8S_IPS: '192.168.0.121,192.168.0.122,192.168.0.123,192.168.0.129,' # 前面3个ip分别是master的节点ip,最后一个是keepalived_vip 不分前后顺序

# Keepalived 配置
keepalived_master: 'master01.k8s.local'
keepalived_vip: '192.168.0.129'
keepalived_vip_netmask: '24'
keepalived_router_id: '108'

# etcd 配置
etcd_version: '3.5.17'
```


> 公共变量，安装 master 和 node 都需要用到
```bash
# cat ansible_install_k8s_on_ubutun24/inventory/group_vars/all.yml 
---
# Kubernetes 网络配置
pod_network: '10.244.0.0/16'
service_network: '172.16.0.0/16'
dns_clusterip: '172.16.0.10'

# 时间同步配置
time_server_address: 'ntp.aliyun.com'

# 容器运行时配置
container_runtime: 'docker'
docker_data_root: '/var/lib/docker'

# Harbor 配置
harbor_hostname: 'harbor.k8s.local'

# CNI 配置
cni_version: '1.6.2'

# 各个节点的DNS解析
hosts:
- { ip_address: '192.168.0.121', name: 'master01.k8s.local', alias: 'etcd01.k8s.local' }
- { ip_address: '192.168.0.122', name: 'master02.k8s.local', alias: 'etcd02.k8s.local' }
- { ip_address: '192.168.0.123', name: 'master03.k8s.local', alias: 'etcd03.k8s.local' }
- { ip_address: '192.168.0.129', name: 'master.k8s.local', alias: '' }
- { ip_address: '192.168.0.61', name: 'harbor.k8s.local', alias: '' }

```


> 安装 node 需要配置的变量
```bash
# cat ansible_install_k8s_on_ubutun24/inventory/kubernetes-node 
[all]
ansible_python_interpreter=/usr/bin/python3

[kubernetes-node]
node01.k8s.local ansible_host=192.168.0.124
# node02.k8s.local ansible_host=192.168.0.125
```

## 2. 下载安装包
```bash
cd download/
bash -x download-kubernetes-binary.sh
```

## 3. 安装 master 节点
> 注意：安装过程中会重启节点，等两分钟节点启动后再次运行下面这条命令即可。

```bash
ansible-playbook -v -i inventory/kubernetes-node playbooks/kubernetes-node.yml
```

> master节点安装完成之后，可进入到master01节点的 /root/addons 目录，目录列表如下：

```bash
root@master01:~/addons# ls
1.download_addons.sh
2.install_cilium.sh
3.install_coredns.sh
4.install_ingress-controller.sh
5.install_metrics-server.sh
addon_vars.sh
```

> 对这些脚本按顺序逐个运行即可：

下载插件的脚本：
```bash
bash 1.download_addons.sh
```

安装网络插件 cilium 的脚本：
```bash
bash 2.install_cilium.sh
```

安装 coredns 的脚本：
```bash
bash 3.install_coredns.sh
```

安装 ingress-controller 的脚本：
```bash
bash 4.install_ingress-controller.sh
```

安装 metrics-server 的脚本：
```bash
bash 5.install_metrics-server.sh
```

> addon_vars.sh 是被引入的变量文件，不用运行。



## 4. 安装 node 节点
> 注意：安装过程中会重启节点，等两分钟节点启动后再次运行下面这条命令即可。

```bash
ansible-playbook -v -i inventory/kubernetes-master playbooks/kubernetes-master.yml
```



