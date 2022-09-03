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


### 3. kube-proxy 安装配置


