  
Write-Host 'Im in'

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

$nuGetApiKey = $env:PSGALLERY_TOKEN

try{
    Publish-Module -Path $modulePath -NuGetApiKey $nuGetApiKey -ErrorAction Stop -Force
}
catch {
    throw $_
}