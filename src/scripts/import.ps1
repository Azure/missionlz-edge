# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

param
(
    [Parameter(Mandatory = $true)]
    [string] $hubDomain,

    [Parameter(Mandatory = $false)]
    [string]$environment = 'AzureStackAdmin', 

    [Parameter(Mandatory = $false)]
    [string] $repositoryDir = $PWD.Path + '/src/artifacts', # where download script stored artifacts

    [Parameter(Mandatory = $false)]
    [string] $journalDir,  # If previously run enter the existing journal to start from

    [Parameter(Mandatory = $false)]
    [string]$modulePath = $HOME + '/.local/share/powershell/Modules/Azs.Syndication.Admin/0.1.157',

    [Parameter(Mandatory = $false)]
    [switch]$UseDeviceAuthentication
)
$null = Disable-AzContextAutosave

$importModulePath = $modulePath+'/Import.psm1'
Import-Module $importModulePath -Force

Write-Host "Checking for Azure Stack Hub admin environment : $environment" -ForegroundColor Cyan
$azEnvironment = Get-AzEnvironment -Name $environment -ErrorAction SilentlyContinue

# Register an Azure Resource Manager environment that targets your Azure Stack Hub instance. Get your Azure Resource Manager endpoint value from your service provider.
if($azEnvironment.count -ne 1) {
    Write-Host "Didn't find admin environment, adding it now:" -ForegroundColor Cyan
    Add-AzEnvironment -Name $environment -ArmEndpoint "https://adminmanagement.$hubDomain" `
        -AzureKeyVaultDnsSuffix "adminvault.$hubDomain" `
        -AzureKeyVaultServiceEndpointResourceId "https://adminvault.$hubDomain" 
} 

# Check for current azure  and default subscription for ASH admin environment
Write-Host "Authenticating to Azure..." -ForegroundColor Cyan
try {
    $null = Get-AzSubscription -SubscriptionName 'Default Provider Subscription' -WarningAction Ignore -ea stop
} catch {
    try {
        if($UseDeviceAuthentication.ToBool()) {
            $null = Connect-AzAccount -UseDeviceAuthentication -Environment $environment -ea Stop # Add Tenant plus Environment for ASH? Also since interactive is not supported will this break for MFA?
            $subscription = Get-AzSubscription -WarningAction Ignore
            $currentContext = Get-AzContext
        } else {
            $registrationSub = Get-Credential -Message "Please enter user name and password for ASH Admin subscription."
            $null = Connect-AzAccount -Credential $registrationSub -Environment $environment -ea Stop # Add Tenant plus Environment for ASH? Also since interactive is not supported will this break for MFA?
            $subscription = Get-AzSubscription -WarningAction Ignore
            $currentContext = Get-AzContext
        }
    } catch {
        if($PSItem.Exception.InnerException.ErrorCode -eq 'invalid_grant')
        { 
            Write-Host "Your organization requires interactive login or MFA, please run script with '-UseDeviceAuthentication'" -ForegroundColor Red
        } else {
            Write-Error "Unknown error please try again.'" -Category SecurityError
        }
        break
    }
}

."./src/scripts/stig/publish-to-blob.ps1" -uploadStigReq $true

# Check if artifacts are in the repository directory.
$repositoryDir
if($null -eq (Get-ChildItem -Directory -Force $repositoryDir))
{
    Write-Host "It doesn't appear that there are artifacts in : $repositoryDir. Please change -repositoryDir or download first. Ending process." -ForegroundColor Red
    break
}

Import-AzsMarketplaceItem -RepositoryDir $repositoryDir

# Clear Azure credentials to ensure they are not cached in conjunction with above 'Disable-AzContextAutosave' command
Disconnect-AzAccount
Get-AzContext | Remove-AzContext