$modulePath = "/home/runner/work/PSScriptConfig/PSScriptConfig/main/PSScriptConfig"
$nuGetApiKey = $env:PSGALLERY_TOKEN

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

#Install current version from PSGallery
Install-Module -Name PSScriptConfig -AllowPrerelease
[version]$version = (Get-Module -Name PSScriptConfig).Version

#Generate new version
[version]$newVersion = "{0}.{1}.{2}" -f $version.Major, $version.Minor, ($version.Build +1)
$manifest = Import-PowerShellDataFile (Join-Path $modulePath -ChildPath "PSScriptConfig.psd1")
Update-ModuleManifest -Path (Join-Path $modulePath -ChildPath "PSScriptConfig.psd1") -ModuleVersion $newVersion


try{
   Publish-Module -Path $modulePath -NuGetApiKey $nuGetApiKey -ErrorAction Stop -Force
}
catch {
    throw $_
}