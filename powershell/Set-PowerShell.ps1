# Linux or Windows
If ( [environment]::OSVersion.Platform -eq "Win32NT"){
    # ExecutionPolicy
    Set-ExecutionPolicy RemoteSigned -Force -Confirm:$false -ErrorAction SilentlyContinue
    # step 1: set powershell ise
    # User's powershell ISE profile (color setting)
    new-item -path 	"$HOME\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1" -itemtype file -force
    $tmpProfile = @"
    Function Set-PowerShellISE {   
        #`$psISE.Options.FontName = 'JetBrains Mono'
        `$psISE.Options.FontName = 'JetBrains Mono'
        `$psISE.Options.FontSize = 10 
        `$psISE.Options.ScriptPaneBackgroundColor = '#FF272822'
        `$psISE.Options.TokenColors['Command'] = '#FFA6E22E'
        `$psISE.Options.TokenColors['Unknown'] = '#FFF8F8F2'
        `$psISE.Options.TokenColors['Member'] = '#FF8B4513'
        `$psISE.Options.TokenColors['Position'] = '#FFF8F8F2'
        `$psISE.Options.TokenColors['GroupEnd'] = '#FFF8F8F2'
        `$psISE.Options.TokenColors['GroupStart'] = '#FFF8F8F2'
        `$psISE.Options.TokenColors['LineContinuation'] = '#FFF8F8F2'
        `$psISE.Options.TokenColors['NewLine'] = '#FFF8F8F2'
        `$psISE.Options.TokenColors['StatementSeparator'] = '#FFF8F8F2'
        `$psISE.Options.TokenColors['Comment'] = '#FF75715E'
        `$psISE.Options.TokenColors['String'] = '#FFE6DB74'
        `$psISE.Options.TokenColors['Keyword'] = '#FF66D9EF'
        `$psISE.Options.TokenColors['Attribute'] = '#FFF8F8F2'
        `$psISE.Options.TokenColors['Type'] = '#FFA6E22E'
        `$psISE.Options.TokenColors['Variable'] = '#FFF8F8F2'
        `$psISE.Options.TokenColors['CommandParameter'] = '#FFFD971F'
        `$psISE.Options.TokenColors['CommandArgument'] = '#FFA6E22E'
        `$psISE.Options.TokenColors['Number'] = '#FFAE81FF'
        `$psISE.Options.TokenColors['Operator'] = '#FFF92672'
    } 
    Set-PowerShellISE 
"@
    $tmpProfile | Out-File -Encoding utf8 -FilePath "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1" 

    # step 2: set powershell PSModulePath (pwershell 5 and pwsh 7 share the same folder)
    # windows split by ;
    # powershell5 create hard link to powershell7
    if (($PSVersionTable).PSVersion.Major -eq 5){
        $PSModulePath = ($Env:PSModulePath -split ';')[0]
        $PSModulePath7 = $PSModulePath -replace "WindowsPowerShell","PowerShell"
        if (-Not (Test-Path $PSModulePath)) { New-Item -Path $PSModulePath  -ItemType directory -Force } 
        if (-Not (Test-Path $PSModulePath7)) { New-Item -Path $PSModulePath7  -ItemType SymbolicLink -Value $PSModulePath -Force } 
    }

    # powershell7 create hard link to powershell5
    if (($PSVersionTable).PSVersion.Major -eq 7){
        $PSModulePath = ($Env:PSModulePath -split ';')[0]
        $PSModulePath5 = $PSModulePath -replace "PowerShell","WindowsPowerShell"
        if (-Not (Test-Path $PSModulePath5)) { New-Item -Path $PSModulePath5  -ItemType directory -Force } 
        if ((Test-Path $PSModulePath5) -And  -Not $(Test-Path $PSModulePath)) { New-Item -Path $PSModulePath -ItemType SymbolicLink -Value $PSModulePath5 -Force} 
    }

    #  step 3: set profile
    $profilePath5="C:\Users\$Env:USERNAME\Documents\WindowsPowerShell\profile.ps1"
    $profilePath7="C:\Users\$Env:USERNAME\Documents\PowerShell\profile.ps1"
    if (-Not (Test-Path $profilePath5)) { New-Item -Path $profilePath5  -ItemType File -Force } 
    if (-Not (Test-Path $profilePath7)) { New-Item -Path $profilePath7  -ItemType SymbolicLink -Value $profilePath5 -Force } 


} elseif ([environment]::OSVersion.Platform -eq "Unix") {
    # step 1: create PSModulePath folder , linux split by :
    $PSModulePath = ($Env:PSModulePath -split ':')[-1]
    if (-Not (Test-Path $PSModulePath)) { New-Item -Path $PSModulePath  -ItemType directory -Force }
    # step 2: set profile, $PROFILE.CurrentUserAllHosts
    # $profilePath=''
    # $PROFILE.CurrentUserAllHosts
}


# set profile to $PROFILE.CurrentUserAllHosts on windows/linux:
if (-Not (Get-Module "VMware.PowerCLI" -ErrorAction SilentlyContinue )){
@"
Import-Module "VMware.PowerCLI"
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:`$false -Confirm:`$false
"@ | Out-File -Encoding utf8 -FilePath $PROFILE.CurrentUserAllHosts 
}
