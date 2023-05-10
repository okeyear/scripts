#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e

# CLI to search GEOIP2

# https://maxmind.github.io/libmaxminddb/mmdblookup.html
# https://github.com/maxmind/libmaxminddb

# get latest github release version
function get_github_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}
# get the latest version
soft_ver=$(get_github_latest_release "maxmind/libmaxminddb")
# download
curl -SLO "https://github.com/maxmind/libmaxminddb/releases/download/${soft_ver}/libmaxminddb-${soft_ver}.tar.gz"
# cp/mv to PATH
tar -xvf libmaxminddb-${soft_ver}.tar.gz -C /usr/local/src
cd /usr/local/src/libmaxminddb-${soft_ver}
./configure
make
make check
sudo make install
sudo sh -c "echo /usr/local/lib  >> /etc/ld.so.conf.d/local.conf"
sudo ldconfig

# sudo yum install yum install geolite2-country geolite2-city
mmdblookup --help # --ip 后面可以接json对应的tag
mmdblookup --file /usr/share/GeoIP/GeoLite2-Country.mmdb --ip 223.5.5.5 country names en
mmdblookup --file /usr/share/GeoIP/GeoLite2-City.mmdb --ip 223.5.5.5 city names zh-CN
# /usr/share/GeoIP/GeoLite2-Country.mmdb
# /usr/share/GeoIP/GeoLite2-City.mmdb
