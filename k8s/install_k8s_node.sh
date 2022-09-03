#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en

### 1. containerd
# download containerd & runc
containerd_ver='1.6.8'
sudo tar -xf cri-containerd-cni-${containerd_ver}-linux-amd64.tar.gz -C /
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

# create default config
sudo mkdir /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# 主要改三个地方及镜像加速
# root = "/var/lib/containerd"
#     sandbox_image = "registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6"
#       bin_dir = "/opt/cni/bin"

# 配置containerd sandbox_image 
# 问题, Error getting node" err="node not found" 
# 解决办法, containerd配置中, 修改sandbox_image = "k8s.gcr.io/pause:3.6" 为可以拉取到的地址
grep k8s.gcr.io /etc/containerd/config.toml
sudo sed -i 's@k8s.gcr.io@registry.cn-hangzhou.aliyuncs.com/google_containers@' /etc/containerd/config.toml

# above Step 4: systemd cgroup driver
sudo sed -i.bak '/SystemdCgroup/s/false/true/' /etc/containerd/config.toml
sudo grep containerd.runtimes.runc.options /etc/containerd/config.toml -A 20

# 错误处理 runc没安装，安装即可
#Unfortunately, an error has occurred:
#        timed out waiting for the condition

# 错误解决 containerd.service is masked
# systemctl unmask containerd

# 错误处理0.1
grep cri /etc/containerd/config.toml
# sed -i '/cri/s/^/#/' /etc/containerd/config.toml

#
sed -i '/conf_template/s/=.*/= "\/etc\/cni\/net.d\/10-containerd-net.conflist"/' /etc/containerd/config.toml
grep conf_template /etc/containerd/config.toml

# 设置containerd的镜像加速 # imageRepository 
grep 'registry.mirrors' -C 5 /etc/containerd/config.toml
# 待更新: python toml模块安装之后的命令行去修改这些值, 比sed更好一点
sed -i.bak '/plugins."io.containerd.grpc.v1.cri".registry.mirrors/a    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]\n        endpoint = ["https://registry.docker-cn.com", "http://hub-mirror.c.163.com", "https://xc8hlpxv.mirror.aliyuncs.com", "https://docker.mirrors.ustc.edu.cn" ]\n        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."gcr.io"]\n          endpoint = ["https://gcr.mirrors.ustc.edu.cn"]\n        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]\n          endpoint = ["https://gcr.mirrors.ustc.edu.cn/google-containers/"]\n        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."quay.io"]\n          endpoint = ["https://quay.mirrors.ustc.edu.cn"]' /etc/containerd/config.toml

sudo systemctl daemon-reload
sudo systemctl enable --now containerd.service

# 如果在内网,不能直接联网,需要设置下proxy
# /etc/systemd/system/containerd.service.d/http_proxy.conf 



### 2. kubelet 安装配置
# 在master01上操作
BOOTSTRAP_TOKEN=$(awk -F',' '{print $1}' token.csv)
# 设置集群参数, 此处lb haproxy也安装在master阶段,为了避免冲突, vip用的8443端口, 不是6443
kubectl config set-cluster kubernetes --certificate-authority=ca.pem \
    --embed-certs=true --server=https://$(grep "lb-vip" /etc/hosts | grep -v ^127 | awk '{print $1}'):8443 \
    --kubeconfig=kubelet-bootstrap.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap --token=${BOOTSTRAP_TOKEN} --kubeconfig=kubelet-bootstrap.kubeconfig
# 设置上下文参数,包含集群名称和访问集群的用户名字
kubectl config set-context default --cluster=kubernetes --user=kubelet-bootstrap --kubeconfig=kubelet-bootstrap.kubeconfig
# 使用默认上下文
kubectl config use-context default --kubeconfig=kubelet-bootstrap.kubeconfig
# 进行角色绑定
kubectl create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user kubelet-bootstrap 
# kubectl delete clusterrolebinding cluster-system-anonymous
kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper \
  --user kubelet-bootstrap \
  --kubeconfig=kubelet-bootstrap.kubeconfig
# 查看
kubectl describe clusterrolebinding cluster-system-anonymous
kubectl describe clusterrolebinding kubelet-bootstrap



### 3. kube-proxy 安装配置


