#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

# update: https://github.com/okeyear/scripts/blob/main/shell/install_terraform.sh

# current version of terrraform
terraform_ver='1.3.9'
terraform_url='http://'
terraform_provide_ver='1.16.2'
terraform_provide_url='http://'

# download
wget -c "${terraform_url}/terraform_${terraform_ver}_linux_amd64.zip"
wget -c "${terraform_provide_url}/terraform-provider-bigip_${terraform_provide_ver}_linux_amd64.zip"

# unzip
mkdir $HOME/bin
unzip -f terraform_${terraform_ver}_linux_amd64.zip -d $HOME/bin/
mkdir $HOME/.terraform.d
mkdir -pv ~/.terraform.d/plugins/hashicorp/bigip/${terraform_provide_ver}/linux_amd64
unzip -f terraform-provider-bigip_${terraform_provide_ver}_linux_amd64.zip -d ~/.terraform.d/plugins/hashicorp/bigip/${terraform_provide_ver}/linux_amd64/

# config
echo 'plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"' | tee ~/.terraformrc

# cleanup
rm -f "terraform_${terraform_ver}_linux_amd64.zip"
rm -f "terraform-provider-bigip_${terraform_provide_ver}_linux_amd64.zip"