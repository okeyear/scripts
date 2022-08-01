# apt proxy
# echo 'Acquire::http::Proxy "http://http_proxy:3128";' | sudo tee /etc/apt/apt.conf.d/10proxy

sudo cp /etc/apt/sources.list{,.bak}

# 如果lsb_release命令存在，发行版是 lsb_release -cs
# 如果lsb_release命令不存在，是如下
source /etc/os-release
# echo ${VERSION_CODENAME} ${UBUNTU_CODENAME}

sudo tee /etc/apt/sources.list <<EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME}-backports main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME}-backports main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME}-proposed main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME}-proposed main restricted universe multiverse
EOF
