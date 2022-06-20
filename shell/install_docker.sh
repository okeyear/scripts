
# install
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh --mirror Aliyun

# rootless user 
sudo usermod -aG docker $USER
# 如果已经sudo到root,请执行如下
sudo usermod -aG docker $SUDO_USER
systemctl start docker
systemctl enable docker
systemctl is-enabled docker
docker version


# speed up ,  docker register
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "http://hub-mirror.c.163.com",
    "https://xc8hlpxv.mirror.aliyuncs.com",
    "http://f1361db2.m.daocloud.io",
    "https://registry.docker-cn.com"
  ],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  }
}
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now docker
sudo systemctl restart docker
