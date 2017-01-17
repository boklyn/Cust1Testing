<# Start Pre-req section#>
add-azurermaccount

<# Start Constants #>
#yoursubid
$subid = "c0e356c9-2cd9-4257-8aa8-63d8ea04ce6f"
#production subscription
$workingdir = "C:\Users\boklyn\OneDrive - Microsoft\Engagements\ABB\ABBMultiDeploySolution\Velocity"
#This is the resource group in which the script will create the keyvault
$rgtodeploy = "abbsc-vsorgp-01"
#This is the keyvault name that the script will use. 
$kvaultname = "abbsc-vsokyvt-01"
#this is the location in which the script will place your keyvault. 
$location = "southcentralus"
<# End Constants   #>

#New-AzureRmResourceGroup -Name $rgtodeploy -Location $location
Get-AzureRmSubscription -SubscriptionId $subid | Set-AzureRmContext

New-AzureRmKeyVault -VaultName $kvaultname -ResourceGroupName $rgtodeploy -Location $location -EnabledForDeployment -EnabledForTemplateDeployment 
#need to grant each user individual access. 
#Set-AzureRmKeyVaultAccessPolicy -VaultName $kvaultname -EnabledForDiskEncryption
#Set-AzureRmKeyVaultAccessPolicy -VaultName $kvaultname -UserPrincipalName 'someoneemail@somedomain.com' -PermissionsToKeys All -PermissionsToSecrets All
#Set-AzureRmKeyVaultAccessPolicy -VaultName $kvaultname -ObjectId (Get-AzureRmADGroup -SearchString 'AzureKeyvaultAdmins')[0].Id -PermissionsToKeys All -PermissionsToSecrets All
<# End Pre-req section#>
