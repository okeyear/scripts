#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en

### 1. install cfssl
# cfssl required
: <<EOF
sudo wget -c "https://pkg.cfssl.org/R1.2/cfssl_linux-amd64"
sudo wget -c "https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64"
sudo wget -c "https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64"
sudo install -m 755 cfssl_linux-amd64 /bin/cfssl
sudo install -m 755 cfssljson_linux-amd64 /bin/cfssljson
sudo install -m 755 cfssl-certinfo_linux-amd64 /bin/cfssl-certinfo
cfssl version
EOF


### 2. CA Cert
# 设置一个环境变量，用于后续处理证书， 完全搭建好集群之后，可选取消这个变量
export SUBJ='/C=CN/ST=Beijing/L=Beijing/O=kubernetes/OU=CN/CN=www.devsecops.com.cn'
eval $(echo "${SUBJ}" |sed 's@^/@@' | sed 's@/@;eval @g')
# -subj 用于设置 Subject Name
# 其中 C 表示 Country or Region
# ST 表示 State/Province
# L 表示 Locality
# O 表示 Organization
# OU 表示 Organization Unit
# CN 表示 Common Name

# CA CSR
# cfssl print-defaults csr > csr.json # 这个可以参考,可以在这个基础上进行修改
sudo tee ca-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "$C",
      "ST": "$ST",
      "L": "$L",
      "O": "$O",
      "OU": "$OU"
    }
  ],
  "CA": {
    "expiry": "87600h"
  }
}
EOF

# 生成CA证书
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
# 会生成以下三个文件
# ca-key.pem  私钥PKEY
# ca.csr  CSR文件
# ca.pem  证书CERT

# 配置ca证书策略
# cfssl print-defaults config | sudo tee ca-config.json # 这个可以参考,可以在这个基础上进行修改
sudo tee ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
        "expiry": "87600h",
        "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ]
      }
    }
  }
}
EOF

# server auth 表示client可以对,使用该CA的server提供的证书,进行验证
# client auth 表示server可以对,使用该CA的client提供的证书,进行验证


### 3. etcd cert

# 配置etcd csr请求文件
sudo tee etcd-csr.json <<EOF
{
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
    "$(grep "etcd01" /etc/hosts | grep -v ^127 | awk '{print $1}')",
    "$(grep "etcd02" /etc/hosts | grep -v ^127 | awk '{print $1}')",
    "$(grep "etcd03" /etc/hosts | grep -v ^127 | awk '{print $1}')",
    "etcd01",
    "etcd02",
    "etcd03"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "$C",
      "ST": "$ST",
      "L": "$L",
      "O": "$O",
      "OU": "$OU"
    }
  ]
}
EOF

# 签发生成etcd证书
cfssl gencert -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=kubernetes etcd-csr.json | cfssljson -bare etcd


### 4. kube-apiserver CSR
# 当前IP地址, 预留一些以后用
sudo tee kube-apiserver-csr.json <<EOF
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "10.10.10.101",
    "10.10.10.102",
    "10.10.10.103",
    "10.10.10.111",
    "10.10.10.112",
    "10.10.10.113",
    "10.10.10.114",
    "10.10.10.115",
    "10.10.10.200",
    "10.96.0.1",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "$C",
      "ST": "$ST",
      "L": "$L",
      "O": "$O",
      "OU": "$OU"
    }
  ]
}
EOF

# 签发证书
cfssl gencert -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=kubernetes kube-apiserver-csr.json | cfssljson -bare kube-apiserver
# kube-apiserver-key.pem  kube-apiserver.csr  kube-apiserver.pem

# 生成token
sudo tee token.csv <<EOF
$(head -c 16 /dev/urandom | od -An -t x | tr -d ' '),kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF


### 5. kubectl CSR
# 当前IP地址, 预留一些以后用
sudo tee admin-csr.json <<EOF
{
  "CN": "admin",
  "hosts": [
    "127.0.0.1",
    "10.10.10.101",
    "10.10.10.102",
    "10.10.10.103",
    "10.10.10.105",
    "10.10.10.106",
    "10.10.10.107"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "$C",
      "ST": "$ST",
      "L": "$L",
      "O": "$O",
      "OU": "$OU"
    }
  ]
}
EOF

# 签发证书
cfssl gencert -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=kubernetes admin-csr.json | cfssljson -bare admin


### 6. kube-controller-manager cert
sudo tee kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "hosts": [
    "127.0.0.1",
    "$(grep "k8s-master01" /etc/hosts | grep -v ^127 | awk '{print $1}')",
    "$(grep "k8s-master02" /etc/hosts | grep -v ^127 | awk '{print $1}')",
    "$(grep "k8s-master03" /etc/hosts | grep -v ^127 | awk '{print $1}')"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "$C",
      "ST": "$ST",
      "L": "$L",
      "O": "$O",
      "OU": "$OU"
    }
  ]
}
EOF

# 签发证书
cfssl gencert -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=kubernetes kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager


### 7. kube-scheduler cert
sudo tee kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "hosts": [
    "127.0.0.1",
    "$(grep "k8s-master01" /etc/hosts | grep -v ^127 | awk '{print $1}')",
    "$(grep "k8s-master02" /etc/hosts | grep -v ^127 | awk '{print $1}')",
    "$(grep "k8s-master03" /etc/hosts | grep -v ^127 | awk '{print $1}')"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "$C",
      "ST": "$ST",
      "L": "$L",
      "O": "$O",
      "OU": "$OU"
    }
  ]
}
EOF

# 签发证书
cfssl gencert -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=kubernetes kube-scheduler-csr.json | cfssljson -bare kube-scheduler


### 8. kube-proxy cert

sudo tee kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "$C",
      "ST": "$ST",
      "L": "$L",
      "O": "$O",
      "OU": "$OU"
    }
  ]
}
EOF

# 签发证书
cfssl gencert -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy
