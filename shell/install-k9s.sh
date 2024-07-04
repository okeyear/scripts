#!/bin/bash
export PATH=/snap/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:~/.local/bin:$PATH
export LANG=en_US.UTF8

function get_github_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}
k9s_ver=$(get_github_latest_release derailed/k9s) # v0.31.4
# wget https://mirror.ghproxy.com/https://github.com/derailed/k9s/releases/download/${k9s_ver}/k9s_Linux_amd64.tar.gz
wget https://files.m.daocloud.io/github.com/derailed/k9s/releases/download/${k9s_ver}/k9s_Linux_amd64.tar.gz
tar -xvf k9s_Linux_amd64.tar.gz
sudo install -m 755 k9s /bin/k9s
