	<### Constants Start ###>
	$connectionName  = "AzureRunAsConnection"
	$SubId = "c0e356c9-2cd9-4257-8aa8-63d8ea04ce6f"
	$AutomationAccountName = "abbsc-vsoaa-01"
	$AutomationAccountResourceGroup = "abbsc-vsorgp-01"	
    $rgdscgrps =  Get-AutomationVariable -Name "rgdscgrps"
    $freq =  Get-AutomationVariable -Name "dsccfg_frequency"
    $refreq =  Get-AutomationVariable -Name "dsccfg_refreshfreq"

	# Configuration Data for the entire environment. 
	<### Constants End ###>	
	try
	{
	   # Get the connection "AzureRunAsConnection "
	   $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName 
	   "Logging in to Azure..."
	   Add-AzureRmAccount `
	     -ServicePrincipal `
	     -TenantId $servicePrincipalConnection.TenantId `
	     -ApplicationId $servicePrincipalConnection.ApplicationId `
	     -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
	   "Setting context to a specific subscription"  
	   Set-AzureRmContext -SubscriptionId $SubId             
	}
	catch {
	    if (!$servicePrincipalConnection)
	    {
	       $ErrorMessage = "Connection $connectionName not found."
	       throw $ErrorMessage
	     } else{
	        Write-Error -Message $_.Exception
	        throw $_.Exception
	     }
	}
    
    $rgdscgrps = $rgdscgrps.Split(",")
    foreach ($rgdscgrp in $rgdscgrps){
	    $vms = Get-AzureRmVM -ResourceGroupName $rgdscgrp
	    foreach ($vm in $vms){
		    $vmnamemod = ($vm.Name -replace '-',"")				    
            "Registering Phase for " + $vmnamemod
            Register-AzureRmAutomationDscNode -ActionAfterReboot ContinueConfiguration -AllowModuleOverwrite $true `
            -ResourceGroupName $AutomationAccountResourceGroup `
            -AutomationAccountName $AutomationAccountName -AzureVMName $vm.Name -AzureVMResourceGroup $vm.ResourceGroupName `
            -ConfigurationMode ApplyAndAutocorrect -ConfigurationModeFrequencyMins $freq `
            -NodeConfigurationName ($configname+"."+$vmnamemod) -RefreshFrequencyMins $refreq `
            -RebootNodeIfNeeded $true -AzureVMLocation $vm.Location
        }
	}