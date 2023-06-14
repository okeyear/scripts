#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
# export LANG=en
# set -e
# stty erase ^H
###########

sudo yum install -yq gcc glibc make autoconf openssl-devel expat-devel

# 1. get the latest git version
git_ver=$(curl --silent "https://api.github.com/repos/git/git/tags"  |
    grep '"name"' |  
    sed -E 's/.*"([^"]+)".*/\1/'  | 
    head -n 1)

# 2. download tarball
# https://github.com/git/git/archive/refs/tags/v2.35.1.tar.gz
[ -s "${git_ver}.tar.gz" ] || curl -sSLO https://github.com//git/git/archive/refs/tags/${git_ver}.tar.gz

# 3. unarchive
tar -zxf ${git_ver}.tar.gz -C /usr/local/src/
cd /usr/local/src/git-${git_ver/v/}

# 4. install
make -j $(nproc) configure
# mkdir /usr/local/git/
# ./configure --help
./configure prefix=/usr/local/git/git-${git_ver/v/}
make -j $(nproc)
make install

# 5. PATH env, 下次升级更新版本, 把最后的200, 改成更高优先级即可
alternatives --install /usr/local/git/latest git /usr/local/git/git-${git_ver/v/} 300

# chech the git version
git --version

### 回滚版本
# sudo update-alternatives --remove git /usr/local/git/git-${git_ver/v/}
# git --version
