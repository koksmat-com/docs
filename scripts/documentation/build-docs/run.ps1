

$root = [System.IO.Path]::GetFullPath((join-path $PSScriptRoot .. .. ..  )) 
$env:workdir = [System.IO.Path]::GetFullPath((join-path $root ".koksmat" "workdir" )) 
. "$root/.koksmat/pwsh/check-env.ps1" "DOC_REPO", "DOC_ORG", "GH_ORGANISATION_WIDE_READ_REPO"

try {
  Push-Location
  Set-Location $root
  write-host "Root: $root"
  write-host "Extracting from" $env:DOC_ORG $env:DOC_REPO 
  
  


  $ENV:GH_TOKEN = $ENV:GH_ORGANISATION_WIDE_READ_REPO
  $ENV:GH_TOKEN | gh auth login --with-token 

  . "$PSScriptRoot/build-documentation.ps1" $env:DOC_ORG $env:DOC_REPO 
  . "$PSScriptRoot/copy-to-docusaurus.ps1" $env:DOC_ORG $env:DOC_REPO 

  
}
catch {
  Write-Host "Error: $_" -ForegroundColor:Red
  <#Do this if a terminating exception happens#>
}
finally {
  Pop-Location
}
