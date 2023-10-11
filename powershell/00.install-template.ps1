# check RunAsAdministrator
if (!
    # current role
    (New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    # is admin?
    )).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
) {
    # It is better than "#Requires -RunAsAdministrator"
    # elevate script and exit current non-elevated runtime
    Start-Process -FilePath 'powershell' -Verb RunAs `
        -ArgumentList (
            # flatten to single array
            '-File', $MyInvocation.MyCommand.Source, $args `
            | %{ $_ }
        ) 
    exit
}

# functions
# get latest version via github API
function get_github_latest_release([string]$repo) {
    $res = Invoke-WebRequest -SkipCertificateCheck -Uri "https://api.github.com/repos/$repo/releases/latest" 
    return (ConvertFrom-Json -InputObject $res.Content).tag_name
}
# $version = get_github_latest_release -repo "hashicorp/terraform"


# set http proxy
$myproxy='http://6.86.3.12:3128'
# 二选一： 1
# netsh winhttp import proxy source=ie
# 二选一： 2
[system.net.webrequest]::DefaultWebProxy = new-object system.net.webproxy($myproxy)
[system.net.webrequest]::DefaultWebProxy.BypassProxyOnLocal = $true


# download latest version
$url='https://www.7-zip.org/a/7z2301-x64.msi'
$outfile="7z-x64.msi"
Invoke-WebRequest -Uri  $url -OutFile $outfile

# unzip
# mkdir $HOME/bin/
# Expand-Archive -Path 7z.zip -DestinationPath $HOME/bin/


# config


# install
msiexec /i $outfile /quiet


# startup


# windows PATH 
# [environment]::SetEnvironmentvariable("Path", [environment]::GetEnvironmentvariable("Path", "User") + ";C:\Users\MyUser\bin\PortableGit", "User")
# Set-ItemProperty -path HKCU:\Environment\ -Name Path -Value "$((Get-ItemProperty -path HKCU:\Environment\ -Name Path).Path);$HOME\bin"


# cleanup
rm $outfile
