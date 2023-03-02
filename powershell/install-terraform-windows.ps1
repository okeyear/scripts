# current version of terrraform
$terraform_ver='1.3.9'
$terraform_url='http://'
$terraform_provide_ver='1.16.2'
$terraform_provide_url='http://'

# download
Invoke-WebRequest -Uri "${terraform_url}/terraform_${terraform_ver}_windows_amd64.zip" `
    -OutFile "terraform_${terraform_ver}_windows_amd64.zip"
Invoke-WebRequest -Uri  "${terraform_provide_url}/terraform-provider-bigip_${terraform_provide_ver}_windows_amd64.zip" `
    -OutFile "terraform-provider-bigip_${terraform_provide_ver}_windows_amd64.zip"

# unzip
mkdir $HOME/bin
Expand-Archive -Path terraform_${terraform_ver}_windows_amd64.zip -DestinationPath $HOME/bin/
mkdir $HOME/.terraform.d/plugins/hashicorp/bigip/${terraform_provide_ver}/windows_amd64
Expand-Archive -Path terraform-provider-bigip_${terraform_provide_ver}_windows_amd64.zip -DestinationPath $HOME/.terraform.d/plugins/hashicorp/bigip/${terraform_provide_ver}/windows_amd64/

# config
echo 'plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"' | Tee-Object $HOME/.terraformrc

# cleanup
rm "terraform_${terraform_ver}_windows_amd64.zip"
rm "terraform-provider-bigip_${terraform_provide_ver}_windows_amd64.zip"