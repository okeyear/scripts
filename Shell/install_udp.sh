#!/usr/bin/env bash
# tinyPortMapper + udpspeeder + udp2raw
# version 20190424
#


mkdir /etc/udp # store config file of tinymapper,udpspeeder,udp2raw
cd /usr/local/src
PublicIP=$(curl -s ifconfig.me)

function Get_port(){
while :
do
  read -p "Please input the ServiePort(1-65535) you need speedup: " SelPort
  if [ $SelPort -gt 0 -a $SelPort -le 65535 ] ; then
    ServicePort=${SelPort}
    break
  else
    echo 'Wrong TCP/UDP port , please input it again.'
  fi
done
}

function Remove_soft(){
  pkill udp2raw
  pkill udpspeeder
  pkill tinymapper
  rm -rf /etc/udp /usr/lib/systemd/system/{tinymapper,udpspeeder,udp2raw}@.service
}

function Remove_port(){
  Get_port
  if [ $(ss -lan | awk "\$5 ~ /:${ServicePort}$/ {print \$1}"|grep -c udp) -eq 0 ] ; then
    tinymapperPort=$(($ServicePort+1))
    udpspeederPort=$(($tinymapperPort+1))
    #udp2rawPort=$(($udpspeederPort+1))
  else
    tinymapperPort="$ServicePort"
    udpspeederPort=$(($tinymapperPort+1))
    #udp2rawPort=$(($udpspeederPort+1))
  fi
  
  systemctl stop udp2raw@$udpspeederPort
  systemctl stop udpspeeder\@$tinymapperPort
  systemctl stop tinymapper\@$ServicePort
  rm -f /etc/udp/{tinyPortMapper$ServicePort,udpspeeder$tinymapperPort,udp2raw$udpspeederPort}
}


function Install_soft(){
  #https://github.com/wangyu-/tinyPortMapper
  Url=$(curl -sk https://github.com/wangyu-/tinyPortMapper/releases/latest | grep -o 'https:[a-zA-Z0-9./-]*')
  winTinymapperUrl=$(echo $Url | sed 's@tag@download@;s@$@/tinymapper_windows.zip@')
  tinymapperUrl='https://github.com/wangyu-/tinyPortMapper/releases/download/20180224.0/tinymapper_binaries.tar.gz'
  # https://github.com/wangyu-/UDPspeeder/releases
  Url=$(curl -sk https://github.com/wangyu-/UDPspeeder/releases/latest | grep -o 'https:[a-zA-Z0-9./-]*')
  winUDPspeederUrl=$(echo $Url | sed 's@tag@download@;s@$@/speederv2_windows.zip@')
  UDPspeederUrl=$(echo $Url | sed 's@tag@download@;s@$@/speederv2_binaries.tar.gz@')
  #https://github.com/wangyu-/udp2raw-tunnel/releases
  Url=$(curl -sk https://github.com/wangyu-/udp2raw-tunnel/releases/latest | grep -o 'https:[a-zA-Z0-9./-]*')
  udp2rawUrl=$(echo $Url | sed 's@tag@download@;s@$@/udp2raw_binaries.tar.gz@')

  if [ -s /usr/bin/tinymapper_amd64 -a -s /usr/bin/speederv2_amd64 -a -s /usr/bin/udp2raw_amd64 ] ; then
    return
  else
    wget $tinymapperUrl
    wget $UDPspeederUrl
    wget $udp2rawUrl
    tar -zxvf tinymapper_binaries.tar.gz -C /usr/bin/
    tar -zxvf speederv2_binaries.tar.gz -C /usr/bin/
    tar -zxvf udp2raw_binaries.tar.gz -C /usr/bin/
  fi
  #############################
  ls -l /usr/bin/{udp2raw,tinymapper,speederv2}_amd64
}


function Config_soft(){
####################
### config tinymapper
if [ ! -s /usr/lib/systemd/system/tinymapper@.service ] ; then
#systemd service script
cat > /usr/lib/systemd/system/tinymapper@.service <<-EOF
[Unit]
Description=A Lightweight High-Performance Port Mapping/Forwarding Utility using epoll, Supports both TCP and UDP
Documentation=https://github.com/wangyu-/tinyPortMapper
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
EnvironmentFile=-/etc/udp/tinyPortMapper%i
ExecStart=/usr/bin/tinymapper_amd64 -l127.0.0.1:\$tinymapperPort -r 127.0.0.1:%i -u #-t 
#PrivateTmp=true
Restart=always
RestartSec=5
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
fi

if [ $(ss -lan | awk "\$5 ~ /:${ServicePort}$/ {print \$1}"|grep -c udp) -eq 0 ] ; then
  tinymapperPort=$(($ServicePort+1))
cat > /etc/udp/tinyPortMapper$ServicePort <<EOF
tinymapperPort=$(($ServicePort+1))
EOF
  systemctl start tinymapper\@$ServicePort
  systemctl enable tinymapper\@$ServicePort
  systemctl status tinymapper\@$ServicePort
else
  tinymapperPort=$ServicePort
fi
####################
### config udpspeeder 
udpspeederPort=$(($tinymapperPort+1))
udpspeederPassword=$(openssl rand -base64 15)
#systemd service script
if [ ! -s /usr/lib/systemd/system/udpspeeder@.service ] ; then
cat > /usr/lib/systemd/system/udpspeeder@.service <<-EOF
[Unit]
Description=A Tunnel which Improves your Network Quality on a High-latency Lossy Link by using Forward Error Correction.
Documentation=https://github.com/wangyu-/UDPspeeder/blob/branch_libev/doc/README.zh-cn.md
After=network-online.target tinymapper.service
Wants=network-online.target

[Service]
Type=simple
EnvironmentFile=-/etc/udp/udpspeeder%i
ExecStart=/usr/bin/speederv2_amd64 -s -l127.0.0.1:\$udpspeederPort -r127.0.0.1:%i -k "\$udpspeederPassword" -f10:6 --timeout 3
#PrivateTmp=true
Restart=always
RestartSec=5
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
EOF
fi

cat > /etc/udp/udpspeeder$tinymapperPort <<EOF
udpspeederPort=$(($tinymapperPort+1))
udpspeederPassword=$udpspeederPassword
EOF

systemctl daemon-reload
systemctl start udpspeeder\@$tinymapperPort
systemctl enable udpspeeder\@$tinymapperPort
systemctl status udpspeeder\@$tinymapperPort
####################
### config udp2raw 
source /etc/udp/udpspeeder$tinymapperPort
udp2rawPort=$(($udpspeederPort+1))
udp2rawPassword="$udpspeederPassword"

#systemd service script
if [ ! -s /usr/lib/systemd/system/udp2raw@.service ] ; then
cat > /usr/lib/systemd/system/udp2raw@.service <<-EOF
[Unit]
Description=udp2raw - A Tunnel which turns UDP Traffic into Encrypted FakeTCP/UDP/ICMP Traffic by using Raw Socket, helps you Bypass UDP FireWalls(or Unstable UDP Environment). 
Documentation=https://github.com/wangyu-/udp2raw-tunnel/blob/master/README.md
After=network-online.target udpspeeder.service
Wants=network-online.target

[Service]
Type=simple
#EnvironmentFile=-/etc/udp/udp2raw%i
ExecStart=/usr/bin/udp2raw_amd64 --conf-file /etc/udp/udp2raw%i
#PrivateTmp=true
Restart=always
RestartSec=5
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
EOF
fi

systemctl daemon-reload


cat > /etc/udp/udp2raw$udpspeederPort <<EOF
-s
-l 0.0.0.0:$udp2rawPort
-r 127.0.0.1:$udpspeederPort
-a
-k $udp2rawPassword
--raw-mode faketcp
EOF


systemctl start udp2raw@$udpspeederPort
systemctl enable udp2raw@$udpspeederPort
systemctl status udp2raw@$udpspeederPort

# all info about server
cat /usr/lib/systemd/system/{tinymapper,udpspeeder,udp2raw}\@.service
}

####Client Config begin:

function Config_client(){
#https://nmap.org/npcap/
yum install -y zip unzip
npcapUrl="https://nmap.org/npcap/$(curl -sk https://nmap.org/npcap/ | grep -o 'dist/npcap-[0-9.]*exe')"
#https://github.com/wangyu-/udp2raw-multiplatform/releases
udp2rawUrl=$(curl -sk https://github.com/wangyu-/udp2raw-multiplatform/releases/latest | grep -o 'https://github.com/wangyu-/udp2raw-multiplatform/releases/tag/[0-9.]*' | sed 's@tag@download@;s@$@/udp2raw_windows+mac.zip@')

DownloadDir='/tmp/udp'
rm -rf $DownloadDir
mkdir $DownloadDir
cd $DownloadDir
wget $npcapUrl
wget $udp2rawUrl
wget $winUDPspeederUrl
unzip udp2raw_windows+mac.zip
unzip speederv2_windows.zip
mv windows/* .
rm -rf windows mac *.zip

cat > start.bat <<EOF
start /b udp2raw_mp_nolibnet.exe -c -l127.0.0.1:$udpspeederPort -r$PublicIP:$udp2rawPort -k "$udp2rawPassword" --raw-mode easy-faketcp 
start /b speederv2 -c -l0.0.0.0:$ServicePort -r127.0.0.1:$udpspeederPort -k "$udpspeederPassword" -f10:6 --timeout 3 
EOF

cat > stop.bat <<EOF
@ECHO OFF 

taskkill /im speederv2.exe /f
taskkill /im client_windows_amd64.exe /f

ping -n 2 127.1 >nul
EOF

zip -r udp.zip ./*
unzip -v udp.zip

cat <<EOF
#Server Info:
##########################################
Destination Service : $ServicePort
tinyPortMapper config : Port $ServicePort to $tinymapperPort (TCP & UDP)
UDPspeeder config : Port $tinymapperPort to $udpspeederPort 
udp2raw config : /etc/udp2raw_server.conf , Port $udpspeederPort to $udp2rawPort
##########################################

#Client Info:
##########################################
Manual download & install :
1. udp2raw :  
  - winpcap: https://www.winpcap.org/install/default.htm
  - npcap: $npcapUrl (better than winpcap)
  - udp2raw Windows Client: $udp2rawUrl
  ./udp2raw_mp_nolibnet.exe -c -l127.0.0.1:$udpspeederPort -r$PublicIP:$udp2rawPort -k "$udp2rawPassword" --raw-mode easy-faketcp  
  
2. UDPspeeder : $winUDPspeederUrl
  ./speederv2 -c -l0.0.0.0:$ServicePort -r127.0.0.1:$udpspeederPort -k "$udpspeederPassword" -f10:6 --timeout 3

3. linux & openwrt/lede :
  argvs like the above info
  
Auto download & install :
1. Please download $DownloadDir/udp.zip to your windows
2. unzip udp.zip
3. install npcap-VERSION.exe
4. run start.bat or stop.bat
##########################################
EOF
}

cat <<EOF
########################
Only support CentOS 7 and later.
1. install/add a udp port (to speedup)
( auto install udpspeeder + udp2raw , and add port)
(if tcp port , will install tinyPortMapper convert to udp port )
2. remove a port (which speedup)
3. remove software commplately (tinyPortMapper + udpspeeder + udp2raw) 
########################
EOF

read -p "Please input your selection:" Sel
case "$Sel" in
  1)
  Get_port
  Install_soft
  Config_soft
  Config_client
  ;;
  2)
  Remove_port
  ;;
  3)
  Remove_soft
  ;;
  *)
  echo 'Wrong Selction , please run it agian.'
  ;;
esac


