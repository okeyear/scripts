#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e

##############################
# curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# https://github.com/helm/helm/releases
function get_github_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}
helm_ver=$(get_github_latest_release helm/helm)
curl -SLO https://get.helm.sh/helm-${helm_ver}-linux-amd64.tar.gz
tar -zxvf helm-${helm_ver}-linux-amd64.tar.gz
sudo install linux-amd64/helm /usr/local/bin/helm

# git clone https://github.com/helm/helm.git
