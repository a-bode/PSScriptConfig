

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

$modulePath = "/home/runner/work/PSScriptConfig/PSScriptConfig/main/PSScriptConfig"

$nuGetApiKey = $env:PSGALLERY_TOKEN

try{
    Publish-Module -Path $modulePath -NuGetApiKey $nuGetApiKey -ErrorAction Stop -Force
}
catch {
    throw $_
}