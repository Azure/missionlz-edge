# Azure Stack Hub STIG solution

When setting [STIG controls](https://public.cyber.mil/stigs/) is a requirement for the overall landing zone solution, there are a series of steps to ensure this can take place.

First a quick explanation of the underlying technologies. This solution is based on the work done in the [Azure ato-toolkit](https://github.com/Azure/ato-toolkit) GitHub repo. This toolkit takes advantage of a number of technologies in and out of Azure. Slight modifications have been made to the toolkit to enable it to work within an ASH stamp deployed in a disconnected environment.

1. [Azure Desired State Configuration](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-overview) - managing vm guest configurations at scale.
    >**NOTE**: currently this only supports Windows machines in Azure Stack Hub
2. [PowerSTIG](https://github.com/Microsoft/PowerStig) - Tooling based on DSC tied into DISA STIG controls to allow DSC to manage setting these controls.

Optional:

- STIG Viewer can be used along with the PowerShell script GenerateCheckList.ps1 to audit current control set in the virtual machine.

Currently the process is as follows:

Step 1: The syndication container process described in the [Deployment Container Setup README](./STIG_Guide.md) will not only allow uploading the required market place items needed by MLZ to deploy but also Marketplace items for DSC to set STIG controls as well as a set of scripts and tools needed to accomplish the setting of controls.
>**Note:**: If not deploying market place items via the syndication tooling process in the container you will be required to upload the STIG resources, which includes the F5 configuration script via the `publish-to-blob.ps1` located in the /scripts/stig/ folder.

These tools will be uploaded into a storage account in the admin portal of the Azure Stack Hub and made readable to all on the network. Not all files uploaded to the storage account are currently used as part of the base MLZ deployment but are provided for customized deployments.
Step 2: During the deployment of a landing zone instance, the `[stig](./STIG_Guide.md)` parameter can be set to `true` which then adds the 'custom script' and 'DSC' extensions to the Windows remote access hosts.

Once the syndication process has uploaded the required scripts and files for the STIG process, PowerShell commands can be run to add the extensions to existing Windows VM's deployed on the ASH stamp.
>**NOTE**: The Linux VM STIG process is still under development

Example: Optionally run after deployment

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
