<# Start Pre-req section#>
add-azurermaccount

<# Start Constants #>
#yoursubid where the storage account will be placed. 
$subid = "c0e356c9-2cd9-4257-8aa8-63d8ea04ce6f"
<# Availabile locations #>
<#'eastus,eastus2,eastus2stage,westus,westeurope,eastasia,southeastasia,japaneast,japanwest,northcentralus,southcentralus,centralus,northeurope,brazilsouth,aus
traliaeast,australiasoutheast,southindia,centralindia,westindia,canadaeast,canadacentral'#>
#the storage location of the account. 
$storlocation = "eastus"
#the resource group in which you place the storage account. 
$resourcegrp = "abbsc-vsorgp-03"
#the name of the storage account. 
$storagename = "abbscvsostor01"
#the name of the container
$containername = "assets"
#the asset folder path location
$assetpath = "C:\Users\boklyn\Documents\GitHub\epm-devops\Velocity\assets"
<# End Constants   #>
Get-AzureRmSubscription -SubscriptionId $subid | Set-AzureRmContext

#create a new resource group to house the storage account. 
New-AzureRmResourceGroup -Name $resourcegrp -Location $storlocation


#create storage account
New-AzureRmStorageAccount -ResourceGroupName $resourcegrp -Name $storagename -Type Standard_LRS -Location $storlocation
$storkey = Get-AzureRmStorageAccountKey -Name $storagename -ResourceGroupName $resourcegrp
$storcontext = New-AzureStorageContext -StorageAccountName$storlocation $storagename -StorageAccountKey $storkey.Key1
#create container struture. 
New-AzureStorageContainer -Name $containername -Permission Container -Context $storcontext
$assets = Get-ChildItem $assetpath

#copy the assets into the newly created container folder. 
foreach ($asset in $assets){
    Set-AzureStorageBlobContent -File $asset.FullName -Container $containername -Blob $asset.Name -Context $storcontext
}
 
