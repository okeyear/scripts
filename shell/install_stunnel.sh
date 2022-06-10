#!/bin/bash


# https://www.stunnel.org/downloads.html
yum install -y stunnel
cat > /etc/stunnel/stunnel.conf<<EOF
cert = /etc/stunnel/stunnel.pem
;;;# 认证文件
CAfile = /etc/stunnel/stunnel.pem
;;;# 认证文件
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
;;;chroot = /var/run/stunnel
pid = /tmp/stunnel_server.pid
verify = 3
;;; CApath = certs
;;; CRLpath = crls
;;; CRLfile = crls.pem
;;;setuid = web
;;;setgid = web
compression = zlib
;;; taskbar = no
delay = no
;;; failover = rr
;;; failover = prio
sslVersion = TLSv1.2
;;; fips=no
;;; sslVersion = all
;;; options = NO_SSLv2
;;; options = NO_SSLv3
debug = 7
syslog = no
output = /var/log/stunnel_server.log
client = no
;;;# 服务端
[squid_proxy]
accept = 58080
;;;# 监听端口
connect = 127.0.0.1:3128
;;;# squid服务连接端口
[socks5_proxy]
accept = 51080
connect = 127.0.0.1:1080
EOF

cat > /usr/lib/systemd/system/stunnel.service <<-EOF
[Unit]
Description=TLS tunnel for network daemons
After=syslog.target network.target

[Service]
ExecStart=/usr/bin/stunnel
Type=forking
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
# 手动放入/etc/stunnel/stunnel.pem
# systemctl start stunnel.service
systemctl enable --now stunnel.service
# systemctl status stunnel.service


# squid proxy
yum install -y squid
sed -i '/^http_port/s/3128/127.0.0.1:3128/' /etc/squid/squid.conf
systemctl enable --now squid

# socks5 proxy
danteVer=$(curl -sSLk  https://www.inet.no/dante/download.html | grep -o 'dante-[0-9.]\{,8\}tar.gz' | sort -u | tail -n 1)
danteUrl="https://www.inet.no/dante/files/${danteVer}"
cd /usr/local/src/
wget -c ${danteUrl}
tar -zxf ${danteVer}
rm -f ${danteVer}
cd dante-1.*
./configure #--sysconfdir=/etc/dante # --with-sockd-conf=/etc/danted.conf
make && make install

cat > /etc/sockd.conf <<-EOF 
internal: lo port = 1080 
external: eth0  
socksmethod: username none 
user.notprivileged: nobody 
errorlog: /var/log/sockd.err   
logoutput: /var/log/sockd.log

client pass {
        from: 0.0.0.0/0 to: lo
        log: error connect disconnect 
}

# block connections to localhost, or they will appear to come from the proxy.
socks block { from: 0/0 to: lo log: connect }

# allow the rest
socks pass {
        from: 0/0 to: 0/0
        log: connect disconnect error
}
EOF

cat > /usr/lib/systemd/system/sockd.service <<-EOF
[Unit]
Description=SOCKS v4 and v5 compatible proxy server and client
Documentation=http://www.inet.no/dante/
After=network.target

[Service]
Type=forking
PIDFile=/var/run/sockd.pid
ExecStart=/usr/local/sbin/sockd  -D  -p  /var/run/sockd.pid

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start sockd.service
systemctl enable sockd.service
# systemctl status sockd.service

