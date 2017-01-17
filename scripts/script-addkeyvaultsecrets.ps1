<# Start Pre-req section#>
add-azurermaccount

<# Start Constants #>
#yoursubid
$subid = "c0e356c9-2cd9-4257-8aa8-63d8ea04ce6f"
$workingdir = "C:\Users\boklyn\OneDrive - Microsoft\Engagements\ABB\ABBMultiDeploySolution\Velocity"
#Name of the keyvault to add the secrets. 
$kvaultname = "abbsc-vsokyvt-01"
#name of the storage account in which your deployment assets are stored. 
$storacctname = "abbscvsostor01"
#the name of the container in which your deployment assets are stored. 
$containername = "assets"
<# End Constants   #>

Get-AzureRmSubscription -SubscriptionId $subid | Set-AzureRmContext

#add domain admin password
$dadminpass = ConvertTo-SecureString 'Dbc57d27c07844b0a55a6acc' -AsPlainText -Force
$key = Add-AzureKeyVaultKey -VaultName $kvaultname -Name 'dadminpass' -Destination 'Software'
$secret = Set-AzureKeyVaultSecret -VaultName $kvaultname -Name 'dadminpass' -SecretValue $dadminpass

#add local admin password
$ladminpass = ConvertTo-SecureString 'U+&1sGziz0Aqex&cSup=' -AsPlainText -Force
$key = Add-AzureKeyVaultKey -VaultName $kvaultname -Name 'ladminpass' -Destination 'Software'
$secret = Set-AzureKeyVaultSecret -VaultName $kvaultname -Name 'ladminpass' -SecretValue $ladminpass

#add option-select url
$optionselcturl = "https://"+$storacctname+".blob.core.windows.net/"+$containername+"/template-optionsselec.json"
$optionselcturl = ConvertTo-SecureString $optionselcturl -AsPlainText -Force
$key = Add-AzureKeyVaultKey -VaultName $kvaultname -Name 'optionselcturl' -Destination 'Software'
$secret = Set-AzureKeyVaultSecret -VaultName $kvaultname -Name 'optionselcturl' -SecretValue $optionselcturl

#add initdisk-select url
$initdiskurl = "https://"+$storacctname+".blob.core.windows.net/"+$containername+"/"
$initdiskurl = ConvertTo-SecureString $initdiskurl -AsPlainText -Force
$key = Add-AzureKeyVaultKey -VaultName $kvaultname -Name 'initdiskurl' -Destination 'Software'
$secret = Set-AzureKeyVaultSecret -VaultName $kvaultname -Name 'initdiskurl' -SecretValue $initdiskurl

#the location of the nic url. 
$nicurl = "https://"+$storacctname+".blob.core.windows.net/"+$containername+"/template-nic.json"
$nicurl = ConvertTo-SecureString $nicurl -AsPlainText -Force
$key = Add-AzureKeyVaultKey -VaultName $kvaultname -Name 'nicurl' -Destination 'Software'
$secret = Set-AzureKeyVaultSecret -VaultName $kvaultname -Name 'nicurl' -SecretValue $nicurl
