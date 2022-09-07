#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e

# 3 Ways to create self_signed_cert:
# 1. easyrsa
# 2. cfssl
# 3. openssl
#   3.1 openssl v1 (current shell script)
#   3.2 openssl v3


# if arg number is 0, print the help info
if [ "$#" -eq 0 ] ; then
	echo "Usage: sudo bash $0 '/C=CN/ST=Beijing/L=Beijing/O=devops/OU=devops/CN=www.devops.com.cn'"
	exit 1
fi

# check OpenSSL version
if [ $(openssl version | grep -c 'OpenSSL 3') -eq 1 ]; then
	echo "Only support OpenSSL version 1.X, not support OpenSSL version 3.X"
	exit 2
fi

# create necessary folder
mkdir -pv /etc/pki/tls/private /etc/pki/CA/{csr,certs,crl,newcerts,private}
touch /etc/pki/CA/index.txt
echo 01 > /etc/pki/CA/serial

# get the args
SUBJ="$1"
eval $(echo "${SUBJ}" |sed 's@^/@@' | sed 's@/@;eval @g')

# 1. ca private key
(umask 077; openssl genrsa -out /etc/pki/CA/private/cakey.pem 4096) 

# 2. ca crt
openssl req -new -x509 -key /etc/pki/CA/private/cakey.pem \
   -days 7300 -out /etc/pki/CA/cacert.pem \
   -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=${CN#*.}"

# check the ca cert
# openssl x509 -in /etc/pki/CA/cacert.pem -noout -text


# 3. create client/server csr

openssl req -new -SHA256 -newkey rsa:2048 \
    -nodes -keyout /etc/pki/tls/private/${CN}.key \
    -out /etc/pki/tls/${CN}.csr \
    -subj "${SUBJ}"
    

# 4. CA sign the client/server crt
echo -e "y\ny\n" | openssl ca -in /etc/pki/tls/${CN}.csr \
       -out /etc/pki/CA/newcerts/${CN}.crt -days 365

# 5. Copy the pkey & cert to current folder
cp -f /etc/pki/CA/newcerts/${CN}.crt ./
cp -f /etc/pki/tls/private/${CN}.key ./


#### How to use 
# echo "Usage: sudo bash $0 '/C=CN/ST=Beijing/L=Beijing/O=devops/OU=devops/CN=www.devops.com.cn'"
