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

```powershell
New-PSScriptConfig -Key mailFrom -Value admin@contoso.com
```

## Get Configurations
```powershell
$PSScriptConfig
```

```powershell
$PSScriptConfig.mailRelay
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