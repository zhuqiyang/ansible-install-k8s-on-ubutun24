#!/bash

# 泛域名，用于生成证书
export COMMON_WILDCARD_DOMAIN_NAME=*.k8s.local
# keepalived 的 vip 或域名
export COMMON_LOAD_BALANCE_HOSTNAME=master.k8s.local
# 高可用ip或域名的端口
export COMMON_LOAD_BALANCE_PORT=8443
# k8s所有节点的IP，用于写入证书中，多个IP使用逗号分格
export COMMON_K8S_IPS=192.168.0.121,192.168.0.122,192.168.0.123,192.168.0.129,
