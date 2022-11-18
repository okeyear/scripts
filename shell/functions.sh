#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# export LANG=en
set -e
# stty erase ^H
###########
# load systemd default functions
[ -s /etc/rc.d/init.d/functions ] && source /etc/rc.d/init.d/functions

# /etc/sysconfig/network-scripts/network-functions

# shell动词列表参考powershell的, 链接如下:
# https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands

: <<EOF
shell / powershell verbs 常用动词:
- convert: Changes the data from one representation to another.
- disable: Configures a resource to an unavailable or inactive state
- enable: Configures a resource to an available or active state
- find: look for an object
- get: obtain information about a resource or to obtain an object with which you can access the resource in future.
- new: create a new resource
- register: Creates an entry for a resource in a repository such as a database. 
- set: modify an existing resource, optionally creating it if it does not exist
- start: Initiates an operation.
- stop: Discontinues an activity.
- submit: Presents a resource for approval.
- unregister: Removes the entry for a resource from a repository. 
EOF


# # 判断当前VPS (VM) 是在国内,国外,或者公司内部
# # 变通办法
# 1. ping 8.8.8.8 如果通, 在国外
# 2. ping 1.2.4.8 如果通, 在国内
# 3. 以上都不通, 在公司内部
# # 针对对坐:
# 1. 设置源为官网源, 国内源, 或者公司内部源
# 2. docker镜像加速

function get_location(){
    #     ping -W 3 -n 1 8.8.8.8 &>/dev/null && return 'foreign'
    #     ping -W 3 -n 1 1.2.4.8 &>/dev/null && return 'external'
    #     return 'internal'
    AppCode=$(source /data/backup/script/tokens.sh; echo $cz88_AppCode)
    curl -s -i --get --include "http://cz88.rtbasia.com/search?ip=$(curl ip.sb)" \
        -H "Authorization:APPCODE ${AppCode}"
    # jq
}

###AAAA###






###BBBB###






###CCCC###
function  create_swap() {
    usage="create_swap [sizeMB: default 512]"
    local COUNT=$1
    [  -z  ${COUNT}   ] && COUNT=512
    dd if=/dev/zero of=/swapfile count=$COUNT  bs=1M
    mkswap /swapfile
    swapon /swapfile
    chmod 600 /swapfile
    [ -z "`grep swapfile /etc/fstab`" ] && echo '/swapfile    swap    swap    defaults    0 0' >> /etc/fstab
}

# function  check_cmd() {
#     if command -v $1  &>/dev/null ; then
#         exit 0
#     else:
#         exit 1
#     fi
# }

###DDDD###
function disable_selinux() {
    [ -s /etc/selinux/config ] && sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0 
}




###EEEE###
function echo_color() {
    while [ $# -gt 1 ]; do
    # local LOWERCASE=$(echo -n "$1" | tr '[A-Z]' '[a-z]')
        case "$1" in
            none) echo -ne "\e[m${2}\e[0m " ;;
            black) echo -ne "\e[0;30m${2}\e[0m " ;;
            red) echo -ne "\e[0;91m${2}\e[0m " ;;
            dark_red) echo -ne "\e[0;31m${2}\e[0m " ;;
            green) echo -ne "\e[0;92m${2}\e[0m " ;;
            dark_green) echo -ne "\e[0;32m${2}\e[0m " ;;
            yellow) echo -ne "\e[0;93m${2}\e[0m " ;;
            dark_yellow) echo -ne "\e[0;33m${2}\e[0m " ;;
            blue) echo -ne "\e[0;94m${2}\e[0m " ;;
            dark_blue) echo -ne "\e[0;34m${2}\e[0m " ;;
            cyan) echo -ne "\e[0;96m${2}\e[0m " ;;
            dark_cyan) echo -ne "\e[0;36m${2}\e[0m " ;;
            magenta) echo -ne "\e[0;95m${2}\e[0m " ;;
            purple) echo -ne "\e[0;35m${2}\e[0m " ;;
            white) echo -ne "\e[0;97m${2}\e[0m " ;;
            gray) echo -ne "\e[0;90m${2}\e[0m " ;;
            light_gray) echo -ne "\e[0;37m${2}\e[0m " ;;
            -r)
                RES_COL=90
                MOVE_TO_COL="echo -en \\033[${RES_COL}G"
                SETCOLOR_SUCCESS="echo -en \\033[1;32m"
                SETCOLOR_FAILURE="echo -en \\033[1;31m"
                SETCOLOR_WARNING="echo -en \\033[1;93m"
                SETCOLOR_NORMAL="echo -en \\033[0;39m"
                $MOVE_TO_COL
                echo -n "["
                case $2 in
                    success)
                        $SETCOLOR_SUCCESS
                        echo -n $"  OK  "
                    ;;
                    failure)
                        $SETCOLOR_FAILURE
                        echo -n $"FAILED"
                    ;;
                    passed)
                        $SETCOLOR_WARNING
                        echo -n $"PASSED"
                    ;;
                    warning)
                        echo -n $"WARNING"
                        $SETCOLOR_NORMAL
                    ;;
                    *)
                        echo -ne "\n"
                    ;;
                esac
                $SETCOLOR_NORMAL
                echo -n "]"
                ;;
            *)
                echo -ne "Usage: echo_color [dark_]red|green|yellow|blue|cyan|white|none|black|magenta|purple|[light_]gray  somewords  -r  success|failure|passed|warning"
                shift 2
                ;;
        esac
        shift 2
    done

    echo -ne "\n"
    return 0
}


function echo_line() {
    printf "%-80s\n" "=" | sed 's/\s/=/g'
}


###FFFF###






###GGGG###

function get_network(){
    # get network from ipaddress + prefix/netmask
    # Usage:
    #   get_network Ip Netmask
    #   get_network Ip/Prefix
    # Output:
    #   CIDR (not include Prefix/Netmask)
    eval $(ipcalc -n $@) && echo $NETWORK
}

function convet_netmask2prefix(){
    # convert 255.255.255.0 to 24
    # echo "obase=2;$(echo ${1}|awk -F'.' '{print ($1*(2^24)+$2*(2^16)+$3*(2^8)+$4)}')"|bc|awk -F'0' '{print length($1)}'
    eval $(ipcalc -p 1.1.1.1 ${1}) && echo ${PREFIX}
}

function convet_prefix2netmask(){
    # convert 24 to 255.255.255.0
    eval $(ipcalc  -m 1.1.1.1/${1}) && echo ${NETMASK}
}

function get_crontab(){
    # get all user's crontab
    USER_LIST=`awk 'BEGIN {FS=":"} ($3 >= 500 && $3 != 65534) || $3 == 0   {print $1}' /etc/passwd`
    for u in $USER_LIST;do crontab -l -u $u;done 2>/dev/null
    unset USER_LIST
}

function get_disksize(){
    # total /dev/sd.. sizeGB, not include /dev/vd.. , /dev/xvd.., /dev/hd..
    echo "scale=2;$(echo $(sudo fdisk -l | awk '/^Disk \/dev\/sd/ {printf "%s+",$5}')|sed 's/+$/+0/'| bc)/1024/1024/1024" | bc
}

# get latest github release version
function get_github_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

function get_nfssize(){
    # total nfs sizeGB
    echo "scale=2;$(echo $(df -TP | awk '$2 == "nfs" {printf "%s+",$3}') |sed 's/+$/+0/'| bc)/1024/1024" | bc 2>/dev/nul
}

function get_os(){
    # get OS major version, minor version, ID , relaserver
    # rpm -q --qf %{version} $(rpm -qf /etc/issue)
    # rpm -E %{rhel} # supported on rhel 6 , 7 , 8
    # python -c 'import yum, pprint; yb = yum.YumBase(); pprint.pprint(yb.conf.yumvar["releasever"])'
    if [ -r /etc/os-release ]; then
        OS=$(. /etc/os-release && echo "$ID")
        OSver=$(. /etc/os-release && echo "$VERSION_ID")
    else
        OS=$(ls /etc/{*-release,issue}| xargs grep -Eoi 'Centos|Oracle|Debian|Ubuntu|Red\ hat' | awk -F":" 'gsub(/[[:blank:]]*/,"",$0){print $NF}' | sort -uf|tr '[:upper:]' '[:lower:]')
        OSver=$([ -f /etc/${OS}-release ] && \grep -oE "[0-9.]+" /etc/${OS}-release || \grep -oE "[0-9.]+" /etc/issue)
    fi
    OSVer=${OSver%%.*}
    OSmajor="${OSver%%.*}"
    OSminor="${OSver#$OSmajor.}"
    OSminor="${OSminor%%.*}"
    OSpatch="${OSver#$OSmajor.$OSminor.}"
    OSpatch="${OSpatch%%[-.]*}"
    # Package Manager:  yum / apt
    case $OS in 
        centos|redhat|oracle|ol|rhel) PM='yum' ;;
        debian|ubuntu) PM='apt' ;;
        *) echo -e "\e[0;31mNot supported OS\e[0m, \e[0;32m${OS}\e[0m" ;;
    esac
    echo -e "\e[0;32mOS: $OS, OSver: $OSver, OSVer: $OSVer, OSmajor: $OSmajor\e[0m"
}

function get_publicip() {
    # get public IP
    curl ip.sb
    # curl -m 10 -s http://members.3322.org/dyndns/getip
    # local IP=$(curl -m 10 -s "ipinfo.io" | awk -F"\"" 'NR==2 {print $(NF-1)}')
}

function get_sslexpire(){
    # get ssl cert expire date
    [ ${#1} -eq 0 ] && echo 'Usage: get_sslexpire $url [no need https://]'
    curl -v https://$1 -o /dev/null 2>/tmp/ssl_start_expire.txt
    echo $1,$( awk -F 'date: ' '/expire date/{print $NF}' /tmp/ssl_start_expire.txt)
}

# get_ipv4addr
# ip -4 -o -f inet addr show |  grep -v '169\.254\.'|awk '/scope global/ {print  $2,$4}'

# get_cpuprocessnumber
# grep -c processor /proc/cpuinfo
# nproc

###HHHH###






###IIII###
function install_docker() {
    # install docker on rhel/centos
    sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    sudo yum -y install docker-ce
    sudo systemctl enable --now docker
}

function install_pip(){
    curl -skSL https://bootstrap.pypa.io/get-pip.py  | python3
}





###JJJJ###






###KKKK###






###LLLL###






###MMMM###






###NNNN###






###OOOO###






###PPPP###
function ping_gw() {
    # ping all gateway
    gatewayy=`ip route show | grep "^default" | awk '{print $3}'`
    ping -c 1 $gatewayy 1>/dev/null 2>&1 && echo -e  "ping $gatewayy [sucess]" || echo   "ping $gatewayy [failure]"
}

function print_line() {
    # print a line 
    echo_line
}


###QQQQ###






###RRRR###






###SSSS###

function set_pip(){
    mkdir ~/.pip
    cat > ~/.pip/pip.conf <<-EOF 
[global]
index-url=https://mirrors.aliyun.com/pypi/simple
[install]
trusted-host=mirrors.aliyun.com
# proxy=http://server:port
EOF
}

function set_pythontab(){
cat >  ~/.pythonstartup.py << EOF
# python startup file
import sys
import readline
import rlcompleter
import atexit
import os
# tab completion
readline.parse_and_bind('tab: complete')
# history file
histfile = os.path.join(os.environ['HOME'], '.pythonhistory')
try:
    readline.read_history_file(histfile)
except IOError:
    pass
atexit.register(readline.write_history_file, histfile)
del os, histfile, readline, rlcompleter 
EOF
echo 'export PYTHONSTARTUP=~/.pythonstartup.py' >> ~/.bash_profile
}


function set_timezone(){
    rm -rf /etc/localtime
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

###TTTT###

function Tar(){  
    # 根据文件类型解压 
    [ $# -ne 1 ] && return 1
    local extension=''
    local filename=$1
    case ${filename} in  
            *.tar.bz2)   
            extension='tar.bz2'     
            tar -xjf ${filename}    
            ;;  
        *.tbz2)      
            extension='tbz2'     
            tar -xjf ${filename}         
            ;;  
        *.tar.Z)      
            extension='tar.Z'     
            tar -xZf ${filename}         
            ;;  
        *.tar.gz)    
            extension='tar.gz'     
            tar -xzf ${filename}       
            ;;  
        *.tar.xz)    
            extension='tar.xz'     
            tar -xJf ${filename}       
            ;;  
        *.tgz)       
            extension='tgz'     
            tar -xzf ${filename}       
            ;; 
        *.bz2)       
            extension='bz2'     
            bunzip2 ${filename}         
            ;;  
        *.rar)       
            extension='rar'     
            unrar e ${filename}       
            ;;  
        *.gz)        
            extension='gz'     
            gunzip ${filename}       
            ;;  
        *.tar)       
            extension='tar'     
            tar -xf ${filename}           
            ;;  
        *.zip)       
            extension='zip'     
            unzip ${filename}    
            ;;  
        *.Z)         
            extension='Z'     
            uncompress ${filename}    
            ;;  
        *.7z)        
            extension='7z'     
            7z x ${filename}      
            ;;  
        *.xz)        
            extension='xz'     
            xz -d ${filename}      
            ;;  
        *)           
            echo -e "${filename}   cannot  Uncompress by Tar()\n\e[0;31;5mUsage: Tar tarball\e[0m" 
            return 1
            ;;  
    esac  
    # 检查文件后缀名，cd目标路径
    local filename1=${filename%\.${extension}}
    # echo "$filename1   $filename "
    cd  ./${filename1}
    pwd
    [ -f ./configure ] && ./configure  || ./config
}





###UUUU###






###VVVV###






###WWWW###






###XXXX###






###YYYY###






###ZZZZ###




###Others###

function os::vm::check(){
    # 检查实体机还虚拟机，虚拟机什么架构
    # xen
    [ -e /proc/xen/capabilities ] && echo 'XEN'
    # openvz
    if [ -e /proc/vz ];then
        [ ！ -e /proc/bc ] && echo 'OPENVZ_CONTAINER' || echo 'OPENVZ_NODE'
    fi
    # Virtual or Physical
    # [ `dmidecode -s system-product-name | wc -l ` -eq 0 ] && echo 'XEN' && dmidecode -s system-product-name
    [ -e /usr/sbin/virt-what ] && /usr/sbin/virt-what || echo "Please install virt-what package."
}

# function install_virt_what(){
#     yum install -y gcc gcc-c++ gdb
#     Virt_What_Ver=$(wget -qO- https://people.redhat.com/~rjones/virt-what/files/ | grep -o 'virt-what-1\.[0-9]\{,2\}' | sort -V | uniq | tail -1)
#     Virt_What_Url="https://people.redhat.com/~rjones/virt-what/files/${Virt_What_Ver}.tar.gz" 
#     wget ${Virt_What_Url}
#     tar zxf ${Virt_What_Ver}.tar.gz
#     cd ${Virt_What_Ver}
#     ./configure
#     make && make install
#     cd ..
#     rm -rf ./${Virt_What_Ver}
#     virt-what
# }
