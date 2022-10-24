#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e


# binary download & install
function get_github_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

# 1. install terraform

terraform_ver="$(get_github_latest_release hashicorp/terraform)"
# https://releases.hashicorp.com/terraform/1.3.3/terraform_1.3.3_linux_amd64.zip
curl -kLO https://releases.hashicorp.com/terraform/${terraform_ver/v/}/terraform_${terraform_ver/v/}_linux_amd64.zip
unzip terraform_${terraform_ver/v/}_linux_amd64.zip
sudo install -m 755 terraform /bin/
rm -f terraform_${terraform_ver/v/}_linux_amd64.zip # terraform


# 2. install huaweicloud provide & plugin 

# https://support.huaweicloud.com/terraform_faq/index.html
# https://github.com/huaweicloud/terraform-provider-huaweicloud
huaweicloud_provider_ver="$(get_github_latest_release huaweicloud/terraform-provider-huaweicloud)"
mkdir -pv ~/.terraform.d/plugins/registry.terraform.io/huaweicloud/huaweicloud/${huaweicloud_provider_ver/v/}/linux_amd64
cd ~/.terraform.d/plugins/registry.terraform.io/huaweicloud/huaweicloud/${huaweicloud_provider_ver/v/}/linux_amd64
curl -kLO "https://github.com/huaweicloud/terraform-provider-huaweicloud/releases/download/${huaweicloud_provider_ver}/terraform-provider-huaweicloud_${huaweicloud_provider_ver/v/}_linux_amd64.zip"
unzip "terraform-provider-huaweicloud_${huaweicloud_provider_ver/v/}_linux_amd64.zip"
rm -f "terraform-provider-huaweicloud_${huaweicloud_provider_ver/v/}_linux_amd64.zip"


# 3. install vsphere provide & plugin  

# https://github.com/hashicorp/terraform-provider-vsphere
: <EOF
vsphere_provider_ver="$(get_github_latest_release hashicorp/terraform-provider-vsphere)"
mkdir -pv ~/.terraform.d/plugins/hashicorp/vsphere/${vsphere_provider_ver/v/}/linux_amd64
cd ~/.terraform.d/plugins/hashicorp/vsphere/${vsphere_provider_ver/v/}/linux_amd64
curl -kLO https://releases.hashicorp.com/terraform-provider-vsphere/${vsphere_provider_ver/v/}/terraform-provider-vsphere_${vsphere_provider_ver/v/}_linux_amd64.zip
unzip "terraform-provider-vsphere_${vsphere_provider_ver/v/}_linux_amd64.zip"
rm -f "terraform-provider-vsphere_${vsphere_provider_ver/v/}_linux_amd64.zip"
EOF

 
 
