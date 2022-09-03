#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en


############# k8s-master01上操作
### 解压出需要的组件
# 解压出二进制文件
sudo tar -xf kubernetes-server-linux-amd64.tar.gz --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{adm,let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}
# sudo cp -axf kubernetes/server/bin/* /usr/local/bin/
# sudo rm -rf kubernetes
kubelet --version

# 证书拷贝到本机
sudo mkdir -p /etc/kubernetes/pki /var/log/kubernetes
sudo cp token.csv ca.pem ca-key.pem kube-apiserver-key.pem kube-apiserver.pem /etc/kubernetes/pki

# 发送组件到其他节点
MasterNodes='k8s-master02 k8s-master03'
for NODE in $MasterNodes
do 
    echo scp on $NODE; 
    ssh $SUDO_USER@$NODE 'sudo mkdir -p /etc/kubernetes/pki /var/log/kubernetes';     
    # 用rsync替代scp,解决目标机器 需要sudu权限的问题.master几点如果不跑负载, 不需要拷贝kubelet, kube-proxy过去;
    rsync -av --progress --rsync-path="sudo rsync" /usr/local/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy} $SUDO_USER@$NODE:/usr/local/bin/; 
    rsync -av --progress  --rsync-path="sudo rsync" token.csv ca.pem ca-key.pem kube-apiserver-key.pem kube-apiserver.pem $SUDO_USER@$NODE:/etc/kubernetes/pki; 
done


############# 所有 k8s-master01/02/03 上操作
# 只需要注意apiserver的监听地址, 其他两个组件都是连接本地的8080端口

### 1. kube-apiserver 配置文件和启动脚本
# apiserver 服务配置文件
sudo tee /etc/kubernetes/kube-apiserver.conf <<EOF
KUBE_APISERVER_OPTS=" --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,ResourceQuota \
    --anonymous-auth=false \
    --bind-address=$(grep "$(hostname)" /etc/hosts| grep -v ^127 | awk '{print $1}')  \
    --secure-port=6443  \
    --allow-privileged=true \
    --advertise-address=$(grep "$(hostname)" /etc/hosts| grep -v ^127 | awk '{print $1}') \
    --authorization-mode=Node,RBAC  \
    --runtime-config=api/all=true \
    --enable-bootstrap-token-auth=true  \
    --service-cluster-ip-range=10.96.0.0/12  \
    --service-node-port-range=30000-32767  \
    --token-auth-file=/etc/kubernetes/pki/token.csv \
    --client-ca-file=/etc/kubernetes/pki/ca.pem  \
    --tls-cert-file=/etc/kubernetes/pki/kube-apiserver.pem  \
    --tls-private-key-file=/etc/kubernetes/pki/kube-apiserver-key.pem  \
    --kubelet-client-certificate=/etc/kubernetes/pki/kube-apiserver.pem  \
    --kubelet-client-key=/etc/kubernetes/pki/kube-apiserver-key.pem  \
    --service-account-key-file=/etc/kubernetes/pki/ca-key.pem \
    --service-account-signing-key-file=/etc/kubernetes/pki/ca-key.pem \
    --service-account-issuer=https://kubernetes.default.svc.cluster.local \
    --etcd-servers="$(awk '/etcd/{printf "https://"$1":2379,"}' /etc/hosts | sed 's/,$//')" \
    --etcd-cafile=/etc/etcd/ssl/ca.pem  \
    --etcd-certfile=/etc/etcd/ssl/etcd.pem  \
    --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem  \
    --allow-privileged=true \
    --enable-swagger-ui=true \
    --apiserver-count=3 \
    --audit-log-maxage=30 \
    --audit-log-maxbackup=3 \
    --audit-log-maxsize=100 \
    --audit-log-path=/var/log/kubernetes/kube-apiserver-audit.log \
    --event-ttl=1h \
    --alsologtostderr=true \
    --logtostderr=false \
    --log-dir=/var/log/kubernetes \
    --v=2 "
EOF



# apiserver 服务脚本
# service script
sudo tee /usr/lib/systemd/system/kube-apiserver.service << EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=etcd.service
wants=etcd.service

[Service]
EnvironmentFile=-/etc/kubernetes/kube-apiserver.conf
ExecStart=/usr/local/bin/kube-apiserver \$KUBE_APISERVER_OPTS
Restart=on-failure
RestartSec=10s
Type=notify
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now kube-apiserver


# test
curl --noproxy "*" --insecure https://k8s-master01:6443/
curl --noproxy "*" --insecure https://k8s-master02:6443/
curl --noproxy "*" --insecure https://k8s-master03:6443/
curl --noproxy "*" --insecure https://lb-vip:8443/


### 2. kube-controller-manager 服务和配置
# kubectl config set-cluster kubernetes --certificate-authority=ca.pem --embed-certs=true --server=https://$(grep "lb-vip" /etc/hosts | grep -v ^127 | awk '{print $1}'):6443 --kubeconfig=kube-controller-manager.kubeconfig
# kubectl config set-credentials system:kube-controller-manager --client-certificate=kube-controller-manager.pem --client-key=kube-controller-manager-key.pem --embed-certs=true --kubeconfig=kube-controller-manager.kubeconfig
# kubectl config set-context kubernetes --cluster=kubernetes --user=system:kube-controller-manager --kubeconfig=kube-controller-manager.kubeconfig
# kubectl config use-context system:kube-controller-manager --kubeconfig=kube-controller-manager.kubeconfig
# sudo cp kube-controller-manager.kubeconfig /etc/kubernetes/

sudo tee /etc/kubernetes/kube-controller-manager.conf <<EOF
KUBE_CONTROLLER_MANAGER_OPTS="  --logtostderr=true \
    --v=2 \
    --log-dir=/var/log/kubernetes \
    --master=127.0.0.1:8080 \
    --address=127.0.0.1 \
    --root-ca-file=/etc/kubernetes/pki/ca.pem \
    --cluster-signing-cert-file=/etc/kubernetes/pki/ca.pem \
    --cluster-signing-key-file=/etc/kubernetes/pki/ca-key.pem \
    --service-account-private-key-file=/etc/kubernetes/pki/ca-key.pem \
    --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig \
    --leader-elect=true \
    --use-service-account-credentials=true \
    --node-monitor-grace-period=40s \
    --node-monitor-period=5s \
    --pod-eviction-timeout=2m0s \
    --controllers=*,bootstrapsigner,tokencleaner \
    --allocate-node-cidrs=true \
    --cluster-cidr=10.244.0.0/16 \
    --service-cluster-ip-range=10.96.0.0/12  \
    --node-cidr-mask-size=24 "
EOF
#     --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem \
sudo tee /usr/lib/systemd/system/kube-controller-manager.service <<EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
EnvironmentFile=-/etc/kubernetes/kube-controller-manager.conf
ExecStart=/usr/local/bin/kube-controller-manager \$KUBE_CONTROLLER_MANAGER_OPTS
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now kube-controller-manager


### 2. kube-scheduler 服务和配置

sudo tee /etc/kubernetes/kube-scheduler.conf <<EOF
KUBE_SCHEDULER_OPTS="  --logtostderr=true \
    --v=2 \
    --kubeconfig=/etc/kubernetes/kube-scheduler.conf \
    --log-dir=/var/log/kubernetes \
    --master=127.0.0.1:8080 \
    --address=127.0.0.1 \
    --leader-elect=true  \
    --alsologtostderr=true \
    --logtostderr=false "
EOF

sudo tee /usr/lib/systemd/system/kube-controller-manager.service <<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
EnvironmentFile=-/etc/kubernetes/kube-scheduler.conf
ExecStart=/usr/local/bin/kube-scheduler \$KUBE_SCHEDULER_OPTS
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now kube-scheduler
