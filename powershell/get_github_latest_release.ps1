# powershell version
function get_github_latest_release([string]$repo) {
    $res = Invoke-WebRequest -SkipCertificateCheck -Uri "https://api.github.com/repos/$repo/releases/latest" 
    return (ConvertFrom-Json -InputObject $res.Content).tag_name
}

get_github_latest_release -repo "hashicorp/terraform"
