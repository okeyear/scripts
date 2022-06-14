# 1. install necessary pkgs
yum install -y autoconf curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker

# 2. uninstall git in os repo
yum remove -y git

# 3. get the latest git version
git_ver=$(curl --silent "https://api.github.com/repos/git/git/tags"  |
    grep '"name"' |  
    sed -E 's/.*"([^"]+)".*/\1/'  | 
    head -n 1)

# 4. download tarball
# https://github.com/git/git/archive/refs/tags/v2.35.1.tar.gz
curl -sSLO https://github.com//git/git/archive/refs/tags/${git_ver}.tar.gz

# 5. unarchive
tar -xf ${git_ver}.tar.gz -C /usr/local/src/
cd /usr/local/src/git-${git_ver/v/}

# 6. install
make -j $(nproc) configure
mkdir /usr/local/git/
# ./configure --help
./configure prefix=/usr/local/git/git-${git_ver/v/}
make -j $(nproc)
make install

# 7. PATH env, 下次升级更新版本, 把最后的200, 改成更高优先级即可
alternatives --install /usr/local/git/latest git /usr/local/git/git-${git_ver/v/} 200
# alternatives 
echo 'export PATH=/usr/local/git/latest/bin:$PATH' | sudo tee /etc/profile.d/git.sh
source /etc/profile.d/git.sh

# chech the git version
git --version



###########
# config
# 保存用户名和密码
# git config --global credential.helper store
# 默认缓存15分钟
git config --global credential.helper cache
# 可以更改默认的密码缓存时限， 单位秒
git config --global credential.helper 'cache --timeout=86400'

# 加速github
# git config --global url."https://hub.fastgit.org".insteadOf https://github.com

# 中文乱码
# https://www.cnblogs.com/perseus/archive/2012/11/21/2781074.html
git config --global core.quotepath false
git config --global gui.encoding utf-8
git config --global i18n.commitencoding utf-8
git config --global i18n.logoutputencoding gbk
# 查看配置
git config --global --list