

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
        new-item -ItemType File -Force -Path $configFilePath | Out-Null
        $config = @{
            lastChangeDateTime = (Get-Date -Format s)
        }
        $config | ConvertTo-Json | Out-File $configFilePath
    }

    $configFileContent = Get-Content -Path $configFilePath | ConvertFrom-Json
    return $configFileContent
}


function New-PSScriptConfig {
    param(
        [String]$Key,
        $Value
    )

    $PSScriptConfig | Add-Member -MemberType NoteProperty -Name $Key -Value $Value
    Save-PSScriptConfig

}

function Save-PSScriptConfig {
    $PSScriptConfig.lastChangeDateTime = get-date -Format s
    $PSScriptConfig | ConvertTo-Json | Out-File $configFilePath
    Update-PSScriptConfigSync
}
    
function Remove-PSScriptConfig($key) {
    $PSScriptConfig.PSObject.Properties.Remove($key)
    Save-PSScriptConfig
}


#Sync functions

function Start-PSScriptConfigSync {

    param(
        [String]$AccessToken,
        [String]$Id
    )

    if(!$Id) {

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Bearer $AccessToken")

        $data = @{
            files       = @{'PSScriptConfig.json' = @{content = ($PSScriptCOnfig | ConvertTo-Json) } }
            description = 'PSScriptConfig'
            public      = $false
        } | Convertto-Json

        $invokeParams = @{
            Method      = 'Post'
            Uri         = "https://api.github.com/gists" 
            Headers     = $headers
            Body        = $data 
            ContentType = 'application/json'
        }

        $response = Invoke-Restmethod @invokeParams
        New-PSScriptConfig -Key '.sync' -Value @{ enabled = $true; accessToken = ($AccessToken | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString); id = $response.id }
    }else {
        New-PSScriptConfig -Key '.sync' -Value @{ enabled = $true; accessToken = ($AccessToken | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString); id = $Id }
    }
}

function Update-PSScriptConfigSync {

    if ($PSScriptConfig.'.sync'.enabled -eq $true ) {
        $AccessToken = $PSScriptConfig.'.sync'.accessToken
        $AccessToken = (New-Object System.Management.Automation.PSCredential ('GH', ($AccessToken | convertto-securestring))).GetNetworkCredential().password
    
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Bearer $AccessToken")
    
        $data = @{
            files       = @{'PSScriptConfig.json' = @{content = ($PSScriptCOnfig | ConvertTo-Json) } }
            description = 'PSScriptConfig'
            public      = $false
        } | Convertto-Json
    
        $invokeParams = @{
            Method      = 'PATCH'
            Uri         = "https://api.github.com/gists/" + $PSScriptConfig.'.sync'.id 
            Headers     = $headers
            Body        = $data 
            ContentType = 'application/json'
        }
        $response = Invoke-Restmethod @invokeParams
    }

}

function Get-PSScriptConfigSync {

    if ($PSScriptConfig.'.sync'.enabled -eq $true ) {
        Write-Information 'PSScriptConfig: Syncing settings from github'

        $AccessTokenConfig = $PSScriptConfig.'.sync'.accessToken
        $AccessToken = (New-Object System.Management.Automation.PSCredential ('GH', ($AccessTokenConfig | convertto-securestring))).GetNetworkCredential().password

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Bearer $AccessToken")

        $data = @{
            files       = @{'PSScriptConfig.json' = @{content = ($PSScriptCOnfig | ConvertTo-Json) } }
            description = 'PSScriptConfig'
            public      = $false
        } | Convertto-Json

        $invokeParams = @{
            Method      = 'GET'
            Uri         = "https://api.github.com/gists/" + $PSScriptConfig.'.sync'.id 
            Headers     = $headers
            Body        = $data 
            ContentType = 'application/json'
        }
        $response = Invoke-Restmethod @invokeParams
        $global:PSScriptConfig = $response.files.'psscriptconfig.json'.content | ConvertFrom-Json
        $global:PSScriptConfig.'.sync'.accessToken = $AccessTokenConfig
        Save-PSScriptConfig
    }

}


$global:PSScriptConfig = Get-PSScriptConfig
$configFilePath = join-path (Split-Path $profile) -childpath '.PSScriptConfig'

Get-PSScriptConfigSync



Export-ModuleMember -Function Register-PSScriptConfig , New-PSScriptConfig, Save-PSScriptConfig, Remove-PSScriptConfig, Get-PSScriptConfig, Start-PSScriptConfigSync
