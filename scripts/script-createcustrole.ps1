add-azurermaccount
$subid = "c0e356c9-2cd9-4257-8aa8-63d8ea04ce6f"
Get-AzureRmSubscription -SubscriptionId $subid | Set-AzureRmContext
#code to modify custom role. 
#tocreate a new role you need to first based it on an existing role. 
$role = Get-AzureRmRoleDefinition "Virtual Machine Contributor"
$role.Id = $null
#is the name of the role. 
$role.Name = "vso vm operator"
$role.Description = "Can monitor and restart virtual machines."
#wipes out the existing actions to provie a clean slate. 
$role.Actions.Clear()
#grants the ability to read the storage and network compute resources that are attached the VM. 
$role.Actions.Add("Microsoft.Storage/*/read")
$role.Actions.Add("Microsoft.Network/*/read")
$role.Actions.Add("Microsoft.Compute/*/read")
#grants the ability to restart, start, and deallocate the vm. 
$role.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/restart/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/deallocate/action")
$role.Actions.Add("Microsoft.Authorization/*/read")
$role.Actions.Add("Microsoft.Insights/alertRules/*")
$role.Actions.Add("Microsoft.Support/*")
#clear the available scopes out. 
$role.AssignableScopes.Clear()
#locked down the role to only the velocity subscriptiuon. 
$role.AssignableScopes.Add("/subscriptions/c0e356c9-2cd9-4257-8aa8-63d8ea04ce6f")
#creates the new role. 
New-AzureRmRoleDefinition -Role $role
#$role = Get-AzureRmRoleDefinition "vso vm operator"
#$role.Actions.Add("Microsoft.Compute/virtualMachines/deallocate/action")
#Set-AzureRmRoleDefinition -Role $role