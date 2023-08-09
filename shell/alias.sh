#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en


# el5
sudo rpm -ivh https://mirrors.aliyun.com/epel-archive/5/x86_64/highlight-2.6.14-1.el5.x86_64.rpm
# el6
sudo rpm -ivh https://mirrors.aliyun.com/epel-archive/6/x86_64/Packages/h/highlight-3.8-1.el6.x86_64.rpm
# el7
# sudo rpm -ivh https://mirrors.aliyun.com/centos/7/os/x86_64/Packages/highlight-3.13-3.el7.x86_64.rpm
# el7 # el8 # el9 + 内置源中
sudo yum install -y highlight
alias cats='highlight -O ansi --syntax=bash'
echo "alias cats='highlight -O ansi --syntax=bash'"  | sudo tee /etc/profile.d/alias.sh

# clear cache
alias ccache='/bin/sync && echo 3 >/proc/sys/vm/drop_caches && sleep 2 && echo 0>/proc/sys/vm/drop_caches >/dev/null 2>&1' 
# # sync命令来清理文件系统缓存，还会清理僵尸(zombie)对象和它们占用的内存
# sync 
# # 清理pagecache（页面缓存）
# echo 1 > /proc/sys/vm/drop_caches     或者 # sysctl -w vm.drop_caches=1
# # 清理dentries（目录缓存）和inodes
# echo 2 > /proc/sys/vm/drop_caches     或者 # sysctl -w vm.drop_caches=2
# # 清理pagecache、dentries和inodes
# echo 3 > /proc/sys/vm/drop_caches     或者 # sysctl -w vm.drop_caches=3
# # 清理后,恢复默认值
# echo 0 > /proc/sys/vm/drop_caches  或者 # sysctl -w vm.drop_caches=0
