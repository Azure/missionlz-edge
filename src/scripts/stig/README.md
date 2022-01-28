# Azure Stack Hub STIG solution 
When setting [STIG controls](https://public.cyber.mil/stigs/) is a requirement for the overall landing zone solution there are a series of steps to ensure this can take place. 

First a quick explanation of the underlying technologies. This solution is based on the work down in the [Azure ato-toolkit](https://github.com/Azure/ato-toolkit) Git?Hub repo. This toolkit takes advantage of a number of technologies in and out of Azure. There are slight modifications to the toolkit to work within a hub disconnected environment.

1. [Azure Desired State Configuration](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-overview) - managing vm guest configurations at scale. *Note: currently this only supports Windows machines in Azure Stack Hub*
2. [PowerSTIG](https://github.com/Microsoft/PowerStig) - Tooling based on DSC tied into DISA STIG controls to allow DSC to manage setting these controls.

Optional:
- STIG Viewer can be used along with the PowerShell script GenerateCheckList.ps1 to audit current control set in the virtual machine.

Currently the process is as follows:

Step 1: The syndication container process described [here](../../../setup.md) will not only allow uploading the required market place items needed by MLZ to deploy but also market place items for DSC to set STIG controls as well as a set of scripts and tools needed to accomplish the setting of controls. 
These tools will be uploaded into a storage account in the admin portal of the Azure Stack Hub and made to e readable to all on the network. Even though there a number of files and tools uploaded, for example. the scripts to STIG Linux, they are not all currently used.
Step 2: During the deployment of a landing zone the `stig` parameter can be set to true which then adds the 'custom script' extension and the 'DSC' extension to the Windows remote access host.

Once the syndication process have uploaded the required scripts and files for the STIG process you can also run PowerShell commands to add the extensions to Windows VM's deployed after the fact. *Note: The Linux VM STIG process is still a work in progress*

Example:
```powershell
$storageEndpointSuffix = "<set to storage account suffix>"
$vmName = "<name of VM to STIG>"
$location = (Get-AzLocation).Location
$vm = Get-AzVM -Name $vmName
$storageAccountName = "stigtools$location"

# Custom script extension files
$requiredModulesFile = "RequiredModules.ps1"
$installPSModulesFile = "InstallModules.ps1"
$generateStigChecklist = "GenerateStigChecklist.ps1"

$requiredModulesFileUrl = "https://$storageAccountName.blob.$storageEndpointSuffix/artifacts/windows/$requiredModulesFile"
$installPSModulesFileUrl = "https://$storageAccountName.blob.$storageEndpointSuffix/artifacts/windows/$installPSModulesFile"
$generateStigChecklistUrl = "https://$storageAccountName.blob.$storageEndpointSuffix/artifacts/windows/$generateStigChecklist"

$fileUriGroup = @($requiredModulesFileUrl,$installPSModulesFileUrl,$generateStigChecklistUrl)

# CustomScript Extension install modules
$fileUriGroup = @($requiredModulesFileUrl,$installPSModulesFileUrl,$generateStigChecklistUrl)
Set-AzVMCustomScriptExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name "install-powershell-modules" -FileUri $fileUriGroup -Run "$installPSModulesFile -autoInstallDependencies $true" -Location $vm.Location

# DSC extension Apply configuration
Set-AzVMDscExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -ArchiveBlobName "Windows.ps1.zip" -ArchiveStorageAccountName $storageAccountName -ArchiveContainerName $containerName -ConfigurationName "Windows" -Version "2.77" -Location $vm.Location

# DSC extension Apply configuration
Set-AzVMDscExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -ArchiveBlobName "Windows.ps1.zip" -ArchiveStorageAccountName $storageAccountName -ArchiveContainerName "artifacts" -ConfigurationName "Windows" -Version "2.77" -Location $vm.Location