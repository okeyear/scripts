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
# get the latest version of kind
kind_ver=$(get_github_latest_release "kubernetes-sigs/kind")
# download
curl -SLO "https://github.com/kubernetes-sigs/kind/releases/download/${kind_ver}/kind-linux-amd64"
# cp/mv to PATH
sudo install kind-linux-amd64 /usr/bin/kind


## create cluster

# single node
# kind create cluster

# multi node
cat << EOF | kind create cluster --config=-
$(curl https://raw.githubusercontent.com/kubernetes-sigs/kind/main/site/content/docs/user/kind-example-config.yaml)
EOF

# delete
# kind delete cluster
