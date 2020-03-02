![Build Status](https://github.com/abodePS/PSScriptConfig/workflows/PublishToPSGallery/badge.svg)

# PSScriptConfig

Save recurring script configurations in your PowerShell profile and have them always available via the $PSSCriptConfig variable.

# Installation

```powershell
Install-Module PSScriptConfig
Import-Module PSScriptConfig
Register-PSScriptConfig
```

# Configuration 
## Add Configuration

```powershell
New-PSScriptConfig -Key mailRelay -Value mail.contoso.com
```

```powershell
New-PSScriptConfig -Key mailRelayPort -Value 25
```
Add a hash table
```powershell
New-PSScriptConfig -Key prod -Value @{mailServer = 'mail.contoso.com';mailServerPort = 25}
```

## Get Configurations
```powershell
$PSScriptConfig
```

```powershell
$PSScriptConfig.mailRelay
```
Values from hash table
```
$PSScriptConfig.prod.mailServer
```

## Change Configuration
For the current session only.
```powershell
$PSScriptConfig.mailRelay = "smtp.contoso.com"
```
Save permanently.
```powershell
Save-PSScriptConfig
```

## Remove Configuration

```powershell
Remove-PSScriptConfig -Key mailRelay
```

# Usage Example

```powershell
Send-MailMessage -From $PSScriptConfig.mailFrom -SmtpServer $PSScriptConfig.mailRelay -Port $PSScriptConfig.mailRelayPort -To me@contoso.com -Subject test
```