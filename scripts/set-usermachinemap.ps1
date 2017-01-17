param(
    #[Parameter(ParameterSetName='InputLine')]
    [string]
        $InputLine,
    #[Parameter(ParameterSetName='InputFile')]
    [string]
        $InputFile
)
#add-azurermaccount

$subid = "c0e356c9-2cd9-4257-8aa8-63d8ea04ce6f"

Get-AzureRmSubscription -SubscriptionId $subid | Set-AzureRmContext

if (!$InputLine -and !$InputFile) {
    $InputLine = Read-Host "Please specifify an inputline of the string"
}

if (!$InputLine) {    
    $objs = Get-Content -Path $InputFile
	$lines = $objs.split("`n") 
}
else {
    $lines = $InputLine
}
$lines| ForEach-Object {
    $inputs = $_.split(',') 
    
    if ($inputs[2] -notmatch '\\') {
    $inputs
        $ADResolved = (Resolve-SamAccount -SamAccount $inputs[1] -Exit:$true)
        $Trustee = 'WinNT://',"$env:userdomain",'/',$ADResolved -join ''
    } else {
        $ADResolved = ($inputs[2] -split '\\')[1]
        $DomainResolved = ($inputs[2] -split '\\')[0]
        $Trustee= 'WinNT://',$DomainResolved,'/',$ADResolved -join ''
    }
    
    try {
        $Trustee
        $server = $inputs[0]
		([ADSI]"WinNT://$server/Administrators,group").add("$Trustee")
		Write-Host -ForegroundColor Green "Successfully completed command for `'$ADResolved`' on `'$_`'"
	} 
    catch {
		Write-Warning "$_ on $server and user $Trustee"
	}
    $curvm = Get-AzureRmVM -ResourceName $inputs[0] -ResourceGroupName $inputs[3]
    New-AzureRmRoleAssignment -SignInName $inputs[1] -RoleDefinitionName "vso vm operator" -Scope $curvm.Id
}
