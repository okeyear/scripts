
#!/usr/bin/env bash
# version: 20190427
source /etc/os-release
[ $ID=="centos" -a $VERSION_ID -eq 7 ] && echo 'Your OS is CentOS7 , continue...' || exit
PublicIP=$(curl -s ifconfig.me)
function Update_wireguard(){ 
  yum update -y wireguard-dkms wireguard-tools 
}
function Install_bbr(){ 
  curl -skL https://github.com/teddysun/across/raw/master/bbr.sh | sudo bash - 
  yum install -y kernel-ml-{headers,tools,tools-libs}
}
function Install_wireguard(){
sudo yum install -y epel-release wget qrencode 
sudo yum install -y kernel-{headers,tools,tools-libs}
sudo curl -sLo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
sudo yum install -y wireguard-dkms wireguard-tools
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf && echo "net.ipv4.ip_forward = 1" | tee -a /etc/sysctl.conf
\cp -f /usr/share/doc/wireguard-tools/examples/json/wg-json /usr/bin/
#wg --help
#wg-quick --help
ServicePort=50000
NetworkAdapter=$(ls -l /sys/class/net | awk '$9 ~ /^e/{print$9}')
mkdir /etc/wireguard
cd /etc/wireguard
umask 077
wg genkey | tee serverPrivateKey | wg pubkey > serverPublicKey # for Server
wg genkey | tee clientPrivateKey | wg pubkey > clientPublicKey # for Client

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
ListenPort =$ServicePort
PrivateKey = $(cat /etc/wireguard/serverPrivateKey)
PostUp = echo 1 > /proc/sys/net/ipv4/ip_forward; iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $NetworkAdapter -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $NetworkAdapter -j MASQUERADE
DNS = 8.8.8.8
MTU = 1420

[Peer]
PublicKey = $(cat /etc/wireguard/clientPublicKey)
AllowedIPs = 172.16.16.2/32
PersistentKeepalive = 25
EOF


wg-quick up wg0
systemctl enable wg-quick@wg0


## client config
sh -c 'umask 077; cat > /etc/wireguard/client.conf' <<-EOF
[Interface]
PrivateKey = $(cat /etc/wireguard/clientPrivateKey)
Address = 172.16.16.2/24 
DNS = 8.8.8.8
MTU = 1420

[Peer]
PublicKey = $(cat /etc/wireguard/serverPublicKey)
Endpoint = $PublicIP:$ServicePort
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25

EOF


echo "Client conf download from /etc/wireguard/client.conf , or scan /tmp/client.png "
qrencode -t ANSIUTF8 < /etc/wireguard/client.conf
qrencode -t png -o /tmp/client.png < /etc/wireguard/client.conf
}

function Remove_wireguard(){
  wg-quick down wg0
  ip link del wg0
  rm -rf /etc/wireguard
}

function Add_wgUser(){
cd /etc/wireguard/
UserNumber=$(wg show wg0 "allowed-ips"|wc -l)
LastIP="172.16.16.$(($UserNumber+2))"
wg genkey | tee clientPrivateKey.$UserNumber | wg pubkey > clientPublicKey.$UserNumber # for Client $UserNumber
\cp -f client{,$UserNumber}.conf
sed -i "/^PrivateKey/cPrivateKey = $(cat clientPrivateKey.$UserNumber)" /etc/wireguard/client${UserNumber}.conf
sed -i "/^Address/cAddress = $LastIP\/24" /etc/wireguard/client${UserNumber}.conf

cat >> /etc/wireguard/wg0.conf <<-EOF

[Peer]
PublicKey = $(cat /etc/wireguard/clientPublicKey.$UserNumber)
AllowedIPs = $LastIP/32
PersistentKeepalive = 25
EOF

systemctl restart wg-quick@wg0
echo "Client conf download from /etc/wireguard/client${UserNumber}.conf , or scan /tmp/client${UserNumber}.png"
qrencode -t ANSIUTF8 < /etc/wireguard/client${UserNumber}.conf
qrencode -t png -o /tmp/client${UserNumber}.png < /etc/wireguard/client${UserNumber}.conf
}


### client
#echo "${content}" | qrencode -o - -t UTF8
#qrencode -t ANSIUTF8 < /etc/wireguard/client.conf
function Get_client(){

cat <<EOF
1. Android: https://play.google.com/store/apps/details?id=com.wireguard.android
2. Windows:
   a. install TunSafe-TAP
   https://tunsafe.com/$(curl -sk https://tunsafe.com/download | grep -o '/downloads/TunSafe-TAP-[0-9.]*exe')
   b. install TunSafe
   https://tunsafe.com/$(curl -sk https://tunsafe.com/download | grep -o '/downloads/TunSafe-[0-9.]*-x64.zip')
3. Linux: https://tunsafe.com/user-guide/linux  
4. Download /etc/wireguard/client*.conf , and then move to your TunSafe/Config Folder (or scan /tmp/client.conf )
EOF

}
#######
# Main
#######

cat <<EOF
########################
Only support CentOS 7 and later.
1. update kernel , support bbr
2. install wireguard
3. add wireguard user
4. update wireguard
5. remove/uninstall wireguard
########################
EOF

read -p "Please input your selection:" Sel
case "$Sel" in
  1)
  Install_bbr
  ;;
  2)
  Install_wireguard
  Get_client
  ;;
  3)
  Add_wgUser
  Get_client
  ;;
  4)
  Update-wireguard
  ;;
  5)
  Remove_wireguard
  ;;
  *)
  echo 'Wrong Selction , please run it agian.'
  ;;
esac


