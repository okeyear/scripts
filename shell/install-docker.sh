#!/bin/bash

# 1. 下载
VERSION=26.1.4
wget -c https://mirrors.163.com/docker-ce/linux/static/stable/x86_64/docker-$VERSION.tgz
# VERSION=27.1.2
# wget -c https://mirrors.aliyun.com/docker-ce/linux/static/stable/x86_64/docker-$VERSION.tgz


# 2. 解压
tar -xf docker-$VERSION.tgz
mv -f docker/* /usr/bin/



# 3. 服务
sudo tee /etc/systemd/system/docker.service <<'EOF'
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
  
[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock --selinux-enabled=false --default-ulimit nofile=65536:65536
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
  
[Install]
WantedBy=multi-user.target
EOF


chmod +x /etc/systemd/system/docker.service
systemctl daemon-reload


# 4. config
mkdir /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
     "https://docker.m.daocloud.io",
    "https://dockerhub.timeweb.cloud",
    "https://huecker.io",
    "http://hub-mirror.c.163.com"
  ],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 5,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "300m",
    "max-file": "2"
  },
  "live-restore": true
}
EOF

systemctl enable --now docker
