# 在 ubutun24 server 系统中安装 Kubernetes 集群指南

## 前言
> 这个是ansible-playbook脚本，用来在ubutun24系统中安装二进制kubernetes集群，集群版本为 1.32，集群采用3 master节点，若干个node节点。

### 集群及工具版本
    都是ubutun24的默认版本。
- kubernetes version 1.32
- ansible version 2.16.3
- python 3.12.3


## 1. 下载安装包
```bash
cd download/
bash -x download-kubernetes-binary.sh
```

## 2. 安装 master 节点
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



## 3. 安装 node 节点
> 注意：安装过程中会重启节点，等两分钟节点启动后再次运行下面这条命令即可。

```bash
ansible-playbook -v -i inventory/kubernetes-master playbooks/kubernetes-master.yml
```



