#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e

# Step 1: Installing containerd
# download latest version containerd 
function get_github_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}
containerd_ver=$(get_github_latest_release containerd/containerd)
curl -SLO https://github.com/containerd/containerd/releases/download/$containerd_ver/containerd-${containerd_ver/v/}-linux-amd64.tar.gz
# 
# unzip the containerd
sudo tar Cxzvf /usr/local -xf containerd-${containerd_ver/v/}-linux-amd64.tar.gz
# create default config
sudo mkdir /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
# imageRepository sandbox_image 
# registry.aliyuncs.com/google_containers

# systemd service script
# https://github.com/containerd/containerd/blob/main/containerd.service
sudo mkdir -pv /usr/local/lib/systemd/system
sudo curl https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /usr/local/lib/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd.service

# Step 2: Installing runc
runc_ver=$(get_github_latest_release opencontainers/runc)
curl -SLO https://github.com/opencontainers/runc/releases/download/${runc_ver}/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

# Step 3: systemd cgroup driver
sudo sed -i.bak '/SystemdCgroup/s/false/true/' /etc/containerd/config.toml

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

# Step 5: containerd proxy
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
