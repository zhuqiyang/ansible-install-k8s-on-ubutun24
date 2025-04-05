#!/bin/bash

source ssl_vars.sh


#--------------------------create_csr----------------------------
export ETCD_HOSTNAME=${COMMON_WILDCARD_DOMAIN_NAME:=*.k8s.local}
export K8S_HOSTNAME=${COMMON_WILDCARD_DOMAIN_NAME=:*.k8s.local}
export K8S_IPS=${COMMON_K8S_IPS:=}
export SERVER_URL=https://${COMMON_LOAD_BALANCE_HOSTNAME:=master.k8s.local}:${COMMON_LOAD_BALANCE_PORT:=8443}

# generate certs directory
export COMMON_PREFIX=generate
export CSR_DIR=${COMMON_PREFIX}/csr
export ETCD_CERT_DIR=${COMMON_PREFIX}/etcd
export K8S_CERT_DIR=${COMMON_PREFIX}/k8s
export KUBECONFIG_DIR=${COMMON_PREFIX}/kubeconfigs

# for bootstrap-kubelet.kubeconfig
export KUBECONFIG=${KUBECONFIG_DIR}/bootstrap-kubelet.kubeconfig
export TOKEN=c8ad9c.2e4d610cf3e7426e



command -v cfssl >/dev/null 2>&1 || { echo >&2 "cfssl is not installed.  Aborting."; exit 1; }
command -v cfssljson >/dev/null 2>&1 || { echo >&2 "cfssljson is not installed.  Aborting."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo >&2 "kubectl is not installed.  Aborting."; exit 1; }


if [ -d ${COMMON_PREFIX} ]; then
    mv ${COMMON_PREFIX} ${COMMON_PREFIX}-$(date +%F-%H%M%S)
fi

if [ -d ${CSR_DIR} ]; then
    rm ${CSR_DIR} -rf
fi
mkdir -pv ${CSR_DIR}


cat > ${CSR_DIR}/admin-csr.json << EOF 
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "system:masters",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cat > ${CSR_DIR}/ca-config.json << EOF 
{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "876000h"
      }
    }
  }
}
EOF

cat > ${CSR_DIR}/etcd-ca-csr.json  << EOF 
{
  "CN": "etcd",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "etcd",
      "OU": "Etcd Security"
    }
  ],
  "ca": {
    "expiry": "876000h"
  }
}
EOF

cat > ${CSR_DIR}/front-proxy-ca-csr.json  << EOF 
{
  "CN": "kubernetes",
  "key": {
     "algo": "rsa",
     "size": 2048
  },
  "ca": {
    "expiry": "876000h"
  }
}
EOF

cat > ${CSR_DIR}/kubelet-csr.json  << EOF 
{
  "CN": "system:node:\$NODE",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "Shanghai",
      "ST": "Shanghai",
      "O": "system:nodes",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cat > ${CSR_DIR}/manager-csr.json << EOF 
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cat > ${CSR_DIR}/apiserver-csr.json << EOF 
{
  "CN": "kube-apiserver",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "Kubernetes",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF


cat > ${CSR_DIR}/ca-csr.json   << EOF 
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "Kubernetes",
      "OU": "Kubernetes-manual"
    }
  ],
  "ca": {
    "expiry": "876000h"
  }
}
EOF

cat > ${CSR_DIR}/etcd-csr.json << EOF 
{
  "CN": "etcd",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "etcd",
      "OU": "Etcd Security"
    }
  ]
}
EOF


cat > ${CSR_DIR}/front-proxy-client-csr.json  << EOF 
{
  "CN": "front-proxy-client",
  "key": {
     "algo": "rsa",
     "size": 2048
  }
}
EOF


cat > ${CSR_DIR}/kube-proxy-csr.json  << EOF 
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "system:kube-proxy",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF


cat > ${CSR_DIR}/scheduler-csr.json << EOF 
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

#--------------------------make_certs------------------------------


if [ -d ${ETCD_CERT_DIR} ]; then
    rm ${ETCD_CERT_DIR} -rf
fi
mkdir ${ETCD_CERT_DIR} -pv


if [ -d ${K8S_CERT_DIR} ]; then
    rm ${K8S_CERT_DIR} -rf
fi
mkdir ${K8S_CERT_DIR} -pv



echo -e "\nGenerate etcd certificate:"
cfssl gencert -initca ${CSR_DIR}/etcd-ca-csr.json | cfssljson -bare ${ETCD_CERT_DIR}/etcd-ca
cfssl gencert \
   -ca=${ETCD_CERT_DIR}/etcd-ca.pem \
   -ca-key=${ETCD_CERT_DIR}/etcd-ca-key.pem \
   -config=${CSR_DIR}/ca-config.json \
   -hostname=127.0.0.1,10.96.0.1,172.16.0.1,192.168.0.1,${K8S_IPS}localhost,$ETCD_HOSTNAME \
   -profile=kubernetes \
   ${CSR_DIR}/etcd-csr.json | cfssljson -bare ${ETCD_CERT_DIR}/etcd


echo -e "\nGenerate k8s ca certificate:"
cfssl gencert -initca ${CSR_DIR}/ca-csr.json | cfssljson -bare ${K8S_CERT_DIR}/ca
echo -e "\nGenerate apiserver certificate:"
cfssl gencert \
    -ca=${K8S_CERT_DIR}/ca.pem \
    -ca-key=${K8S_CERT_DIR}/ca-key.pem \
    -config=${CSR_DIR}/ca-config.json \
    -hostname=10.96.0.1,172.16.0.1,192.168.0.1,127.0.0.1,${K8S_IPS}localhost,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.default.svc.cluster.local,${K8S_HOSTNAME} \
    -profile=kubernetes ${CSR_DIR}/apiserver-csr.json | cfssljson -bare ${K8S_CERT_DIR}/apiserver


echo -e "\nGenerate front-proxy-ca certificate:"
cfssl gencert -initca ${CSR_DIR}/front-proxy-ca-csr.json | cfssljson -bare ${K8S_CERT_DIR}/front-proxy-ca 
echo -e "\nGenerate front-proxy-client certificate:"
cfssl gencert \
    -ca=${K8S_CERT_DIR}/front-proxy-ca.pem   \
    -ca-key=${K8S_CERT_DIR}/front-proxy-ca-key.pem   \
    -config=${CSR_DIR}/ca-config.json   \
    -profile=kubernetes ${CSR_DIR}/front-proxy-client-csr.json | cfssljson -bare ${K8S_CERT_DIR}/front-proxy-client

echo -e "\nGenerate controller-manager certificate:"
cfssl gencert \
   -ca=${K8S_CERT_DIR}/ca.pem \
   -ca-key=${K8S_CERT_DIR}/ca-key.pem \
   -config=${CSR_DIR}/ca-config.json \
   -profile=kubernetes \
   ${CSR_DIR}/manager-csr.json | cfssljson -bare ${K8S_CERT_DIR}/controller-manager

echo -e "\nGenerate scheduler certificate:"
cfssl gencert \
   -ca=${K8S_CERT_DIR}/ca.pem \
   -ca-key=${K8S_CERT_DIR}/ca-key.pem \
   -config=${CSR_DIR}/ca-config.json \
   -profile=kubernetes \
   ${CSR_DIR}/scheduler-csr.json | cfssljson -bare ${K8S_CERT_DIR}/scheduler

echo -e "\nGenerate admin certificate:"
cfssl gencert \
   -ca=${K8S_CERT_DIR}/ca.pem \
   -ca-key=${K8S_CERT_DIR}/ca-key.pem \
   -config=${CSR_DIR}/ca-config.json \
   -profile=kubernetes \
   ${CSR_DIR}/admin-csr.json | cfssljson -bare ${K8S_CERT_DIR}/admin

echo -e "\nGenerate kube-proxy certificate:"
cfssl gencert \
   -ca=${K8S_CERT_DIR}/ca.pem \
   -ca-key=${K8S_CERT_DIR}/ca-key.pem \
   -config=${CSR_DIR}/ca-config.json \
   -profile=kubernetes \
   ${CSR_DIR}/kube-proxy-csr.json | cfssljson -bare ${K8S_CERT_DIR}/kube-proxy

echo -e "\nGenerate sa.key sa.pub:"
openssl genrsa -out ${K8S_CERT_DIR}/sa.key 2048
openssl rsa -in ${K8S_CERT_DIR}/sa.key -pubout -out ${K8S_CERT_DIR}/sa.pub


#----------------------create_kubeconfig----------------------------


if [ -d ${KUBECONFIG_DIR} ]; then
    rm ${KUBECONFIG_DIR} -rf
fi
mkdir ${KUBECONFIG_DIR} -pv


echo -e "\nCreate controller-manager.kubeconfig"
kubectl --kubeconfig=${KUBECONFIG_DIR}/controller-manager.kubeconfig config set-cluster kubernetes --certificate-authority=${K8S_CERT_DIR}/ca.pem --embed-certs=true --server=${SERVER_URL}
kubectl --kubeconfig=${KUBECONFIG_DIR}/controller-manager.kubeconfig config set-context system:kube-controller-manager@kubernetes --cluster=kubernetes --user=system:kube-controller-manager
kubectl --kubeconfig=${KUBECONFIG_DIR}/controller-manager.kubeconfig config set-credentials system:kube-controller-manager --client-certificate=${K8S_CERT_DIR}/controller-manager.pem --client-key=${K8S_CERT_DIR}/controller-manager-key.pem --embed-certs=true
kubectl --kubeconfig=${KUBECONFIG_DIR}/controller-manager.kubeconfig config use-context system:kube-controller-manager@kubernetes


echo -e "\nCreate scheduler.kubeconfig"
kubectl --kubeconfig=${KUBECONFIG_DIR}/scheduler.kubeconfig config set-cluster kubernetes --certificate-authority=${K8S_CERT_DIR}/ca.pem --embed-certs=true --server=${SERVER_URL}
kubectl --kubeconfig=${KUBECONFIG_DIR}/scheduler.kubeconfig config set-credentials system:kube-scheduler --client-certificate=${K8S_CERT_DIR}/scheduler.pem --client-key=${K8S_CERT_DIR}/scheduler-key.pem --embed-certs=true
kubectl --kubeconfig=${KUBECONFIG_DIR}/scheduler.kubeconfig config set-context system:kube-scheduler@kubernetes --cluster=kubernetes --user=system:kube-scheduler
kubectl --kubeconfig=${KUBECONFIG_DIR}/scheduler.kubeconfig config use-context system:kube-scheduler@kubernetes


echo -e "\nCreate admin.kubeconfig"
kubectl --kubeconfig=${KUBECONFIG_DIR}/admin.kubeconfig config set-cluster kubernetes --certificate-authority=${K8S_CERT_DIR}/ca.pem --embed-certs=true --server=${SERVER_URL}
kubectl --kubeconfig=${KUBECONFIG_DIR}/admin.kubeconfig config set-credentials kubernetes-admin --client-certificate=${K8S_CERT_DIR}/admin.pem --client-key=${K8S_CERT_DIR}/admin-key.pem --embed-certs=true
kubectl --kubeconfig=${KUBECONFIG_DIR}/admin.kubeconfig config set-context kubernetes-admin@kubernetes --cluster=kubernetes --user=kubernetes-admin
kubectl --kubeconfig=${KUBECONFIG_DIR}/admin.kubeconfig config use-context kubernetes-admin@kubernetes


echo -e "\nCreate kube-proxy.kubeconfig"
kubectl --kubeconfig=${KUBECONFIG_DIR}/kube-proxy.kubeconfig config set-cluster kubernetes --certificate-authority=${K8S_CERT_DIR}/ca.pem --embed-certs=true --server=${SERVER_URL}
kubectl --kubeconfig=${KUBECONFIG_DIR}/kube-proxy.kubeconfig config set-credentials kube-proxy --client-certificate=${K8S_CERT_DIR}/kube-proxy.pem --client-key=${K8S_CERT_DIR}/kube-proxy-key.pem --embed-certs=true
kubectl --kubeconfig=${KUBECONFIG_DIR}/kube-proxy.kubeconfig config set-context kube-proxy@kubernetes --cluster=kubernetes --user=kube-proxy
kubectl --kubeconfig=${KUBECONFIG_DIR}/kube-proxy.kubeconfig config use-context kube-proxy@kubernetes


echo -e "\nCreate bootstrap-kubelet.kubeconfig"
kubectl --kubeconfig=${KUBECONFIG} config set-cluster kubernetes --certificate-authority=${K8S_CERT_DIR}/ca.pem --embed-certs=true --server=${SERVER_URL}
kubectl --kubeconfig=${KUBECONFIG} config set-credentials tls-bootstrap-token-user --token=${TOKEN}
kubectl --kubeconfig=${KUBECONFIG} config set-context tls-bootstrap-token-user@kubernetes --cluster=kubernetes --user=tls-bootstrap-token-user
kubectl --kubeconfig=${KUBECONFIG} config use-context tls-bootstrap-token-user@kubernetes


