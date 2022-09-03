#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e

##############################
# Step 1: Installing containerd

# methond 1: install via yum
#sudo yum install -y yum-utils device-mapper-persistent-data lvm2
#sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
#sudo yum install -y containerd.io

# methond 2: install github release
# download latest version containerd 
sudo yum install -y glibc
# download latest version containerd 
function get_github_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

export containerd_ver=$(get_github_latest_release containerd/containerd)
# curl -SLO https://github.com/containerd/containerd/releases/download/$containerd_ver/containerd-${containerd_ver/v/}-linux-amd64.tar.gz
containerd_ver=${containerd_ver/v/}

wget -c "https://github.com/containerd/containerd/releases/download/v${containerd_ver}/cri-containerd-cni-${containerd_ver}-linux-amd64.tar.gz"

# unzip the containerd
# sudo tar -C /usr/local -xf containerd-${containerd_ver/v/}-linux-amd64.tar.gz
sudo tar -xf cri-containerd-cni-${containerd_ver}-linux-amd64.tar.gz -C /

# 包含的runc不好用, 还是需要下一步下载安装的runc; 已包含服务脚本
# ls /opt/cni/bin
runc_ver=$(get_github_latest_release opencontainers/runc)
curl -SLO https://github.com/opencontainers/runc/releases/download/${runc_ver}/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

# systemd服务脚本
# https://github.com/containerd/containerd/blob/main/containerd.service
# sudo mkdir -pv /usr/local/lib/systemd/system
# sudo curl https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /usr/local/lib/systemd/system/containerd.service

# systemd service script
# https://github.com/containerd/containerd/blob/main/containerd.service
# sudo mkdir -pv /usr/local/lib/systemd/system
# sudo curl https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /usr/local/lib/systemd/system/containerd.service
# sudo systemctl daemon-reload
# sudo systemctl enable --now containerd.service

##############################
# Step 2: Installing runc
runc_ver=$(get_github_latest_release opencontainers/runc)
curl -SLO https://github.com/opencontainers/runc/releases/download/${runc_ver}/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

##############################
# Step 3: systemd cgroup driver
sudo sed -i.bak '/SystemdCgroup/s/false/true/' /etc/containerd/config.toml

##############################
# Step 4: k8s containerd settings
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
# 设置必需的 sysctl 参数，这些参数在重新启动后仍然存在。
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
# 应用 sysctl 参数而无需重新启动
sudo sysctl --system

##############################
# Step 5: genaral config settings
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


# [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
# [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
#  endpoint = ["https://registry.docker-cn.com", "http://hub-mirror.c.163.com", "https://xc8hlpxv.mirror.aliyuncs.com"]


sudo systemctl daemon-reload
sudo systemctl enable --now containerd.service
# sudo systemctl status containerd.service
# sudo systemd-run -p Delegate=yes -p KillMode=process /usr/local/bin/containerd


##############################
# Step 6: containerd proxy
# # set proxy for containerd
# sudo mkdir -pv /etc/systemd/system/containerd.service.d
# sudo tee /etc/systemd/system/containerd.service.d/http_proxy.conf << EOF
# [Service]
# Environment="HTTP_PROXY=http://6.86.3.12:3128/"
# EOF
# #  "HTTPS_PROXY=http://6.86.3.12:3128/" 
# sudo tee /etc/systemd/system/containerd.service.d/no_proxy.conf << EOF
# [Service]
# Environment="NO_PROXY=$master01"
# EOF
