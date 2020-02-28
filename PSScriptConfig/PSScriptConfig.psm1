

function Register-PSScriptConfig() {

    $PSProfile = Get-Content $profile -ErrorAction SilentlyContinue
    if ($PSProfile | Select-String -Pattern 'Import-Module PSScriptConfig #PSScriptConfig Module' -CaseSensitive -SimpleMatch -Quiet) {
        Write-Warning 'Module already initialized.'
    }
    else {
        $PSProfile += "`n Import-Module PSScriptConfig #PSScriptConfig Module `n"
        $PSProfile | Out-File $profile
        Write-Information 'Module initialization completed.'
    }

}

function Get-PSScriptConfig() {
    $configFilePath = join-path (Split-Path $profile) -childpath '.PSScriptConfig'

    if (!(Test-Path $configFilePath)) {
        
        New-Item -ItemType File -Force -Path $configFilePath
        
        $config = @{
            lastChangeDateTime = (Get-Date -Format s)
        }
        $config | ConvertTo-Json | Out-File $configFilePath
    }

    $configFileContent = Get-Content -Path $configFilePath | ConvertFrom-Json
    return $configFileContent
}


function New-PSScriptConfig{
param(
    [String]$Key,
    [String]$Value
)

    $PSScriptConfig |Add-Member -MemberType NoteProperty -Name $Key -Value $Value
    Save-PSScriptConfig

}

function Save-PSScriptConfig{
    $PSScriptConfig.lastChangeDateTime = get-date -Format s
    $PSScriptConfig |ConvertTo-Json |Out-File $configFilePath
}
    
function Remove-PSScriptConfig($key){
    $PSScriptConfig.PSObject.Properties.Remove($key)
    Save-PSScriptConfig
}


$global:PSScriptConfig = Get-PSScriptConfig
$configFilePath = join-path (Split-Path $profile) -childpath '.PSScriptConfig'

Export-ModuleMember -Function Register-PSScriptConfig , New-PSScriptConfig, Save-PSScriptConfig,Remove-PSScriptConfig
