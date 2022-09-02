# -*- mode: ruby -*-
# vi: set ft=ruby :
boxes = [
    {
        :hostname => "k8s-master01",
        :mem => "4096",
        :cpu => 2
    },
    {
        :hostname => "k8s-master02",
        :mem => "4096",
        :cpu => 2
    },
    {
        :hostname => "k8s-master03",
        :mem => "4096",
        :cpu => 2
    },
    {
        :hostname => "k8s-node01",
        :mem => "2048",
        :cpu => 2
    },
    {
        :hostname => "ha01",
        :mem => "2048",
        :cpu => 1
    },
    {
        :hostname => "ha02",
        :mem => "2048",
        :cpu => 1
    }
]

# ENV
ENV["LC_ALL"] = "en_US.UTF-8"
# All Vagrant configuration is done below.
Vagrant.configure("2") do |config|
  # OS版本选择
  # config.vm.box = "CentOS-7"
  config.vm.box = "AlmaLinux-9.VMwareFusion"
  # config.vm.disk :dvd, name: "Tools", file: "D:/Program Files/Oracle/VirtualBox/VBoxGuestAdditions.iso"
  # box proxy setting
  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = "http://x.x.x.x:3128/"
    config.proxy.https    = "http://x.x.x.x:3128/"
    config.proxy.no_proxy = "localhost,127.0.0.1"
  end
  boxes.each do |opts|
    config.vm.define opts[:hostname] do |config|
      # 配置hostname
      config.vm.hostname = opts[:hostname]
      # 配置网卡和IP, 在shell部分配置
      # share folder
      config.vm.synced_folder "../data", "/vagrant_data"
      # 根据不同provide配置cpu mem
      config.vm.provider "vmware_desktop" do |v|
        v.vmx["memsize"] = opts[:mem]
        v.vmx["numvcpus"] = opts[:cpu]
        v.gui = true
      end
      config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", opts[:mem]]
        v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
        v.gui = true
        if Vagrant.has_plugin?("vagrant-vbguest")
          config.vbguest.auto_update = false
        end
      end
      config.vm.provider "hyperv" do |v|
        v.cpus = opts[:cpu]
        v.maxmemory = opts[:mem]
        v.memory = opts[:mem]
        v.gui = true
      end
    end
  end
  # 额外shell脚本
  # config.vm.provision "shell", privileged: false, path: "./setup.sh"
  config.vm.provision "shell", run: "always", inline: <<-SHELL
    echo $(date +%FT%T) shell begin
    # echo 'PermitRootLogin yes' | sudo tee -a /etc/ssh/sshd_config
    # sudo service sshd restart
    # echo vagrant | sudo passwd --stdin root
    echo '10.10.10.121 k8s-master01' | sudo tee -a /etc/hosts
    echo '10.10.10.122 k8s-master02' | sudo tee -a /etc/hosts
    echo '10.10.10.123 k8s-master03' | sudo tee -a /etc/hosts
    echo '10.10.10.121 etcd01' | sudo tee -a /etc/hosts
    echo '10.10.10.122 etcd02' | sudo tee -a /etc/hosts
    echo '10.10.10.123 etcd03' | sudo tee -a /etc/hosts
    echo '10.10.10.128 ha01' | sudo tee -a /etc/hosts
    echo '10.10.10.129 ha02' | sudo tee -a /etc/hosts
    echo '10.10.10.131 k8s-node01' | sudo tee -a /etc/hosts
    echo '10.10.10.200 lb-vip' | sudo tee -a /etc/hosts
    # sudo nmcli connection add type ethernet ifname ens32 ipv4.method manual ipv4.addresses 10.10.10.101/24 ipv4.gateway 10.10.10.2 ipv4.dns 223.5.5.5
    sudo nmcli connection add type ethernet \
      ifname $(cd /sys/class/net/; echo e*) \
      ipv4.method manual \
      ipv4.addresses $(grep "$(hostname)" /etc/hosts | grep -v ^127. | awk '{print $1}')/24 \
      ipv4.gateway 10.10.10.2 \
      ipv4.dns 10.10.10.2
    # sudo nmcli connection up ethernet-$(cd /sys/class/net/; echo e*)
    echo $(date +%FT%T) shell end
    # sudo reboot
  SHELL
end

# vagrant up --provider virtualbox
# Add-Content "\n"  ~/.ssh/config
# vagrant ssh-config | Add-Content ~/.ssh/config
# vagrant ssh-config | Out-File ~/.ssh/config
