Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted # removes need to approce untrusted gallery items.

Install-Module -Name Az.BootStrapper -Force
Install-AzProfile -Profile 2020-09-01-hybrid -Force # Installs basic AZ PowerShell commands 
Install-Module -Name AzureStack -RequiredVersion 2.1.1 -Force # Installs Azs PS commands including Syndication Admin

Import-Module Azs.Syndication.Admin -Force 

$artifactPath = $PWD.path + '/src/artifacts/Azs.Syndication.Admin.Linux.MLZ.zip'
$modulePath = $HOME + '/.local/share/powershell/Modules/Azs.Syndication.Admin/0.1.157'
Expand-Archive -LiteralPath $artifactPath -DestinationPath $modulePath -Force # Forcing overwrite of downloaded module files

$exportModulePath = $modulePath+'/Export.psm1'
Import-Module $exportModulePath -Force

$importModulePath = $modulePath+'/Import.psm1'
Import-Module $importModulePath -Force

chmod 777 -R $modulePath