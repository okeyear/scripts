#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e

# get latest github release version
function get_github_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

# curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt
# curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# get the latest version of minikube
minikube_ver=$(get_github_latest_release "kubernetes/minikube")
# download
curl -LO https://github.com/kubernetes/minikube/releases/download/${minikube_ver}/minikube-linux-amd64
# cp/mv to PATH
sudo install minikube-linux-amd64 /usr/local/bin/minikube

###

# minikube start  \
#     --image-mirror-country=cn `# in china` \
#     --registry-mirror=https://registry.docker-cn.com \
#     --addons=ingress \
#     --cni=flannel \
#     --install-addons=true  \
#     --alsologtostderr  -v=7 \
#     --kubernetes-version=stable \
#     --driver=docker  `# docker,kvm2,vmware,podman,virtualbox`
#     # --cpus=2 --memory=4g 
    
