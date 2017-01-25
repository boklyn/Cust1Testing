	<### Constants Start ###>
	$connectionName  = "AzureRunAsConnection"
	$SubId = "4ff56ee1-f567-4548-9bf0-bea3525e4d61"
	$AutomationAccountName = "demoaccount"
	$AutomationAccountResourceGroup = "boklyndemo"	
    $rgdscgrps =  Get-AutomationVariable -Name "rgdscgrps"
    #$subids =  Get-AutomationVariable -Name "subscriptionids"
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
            $isdsc = Get-AzureRmAutomationDscNode `
            -ResourceGroupName $AutomationAccountResourceGroup `
            -AutomationAccountName $AutomationAccountName -Name $vm.Name
	        if(-not $isdsc){
				    $vmnamemod = ($vm.Name -replace '-',"")
				    $vmnamemod
		            $params = @{"nodename"=$vmnamemod}
	        	    $ConfigData.AllNodes += $curvmnode	 
				    switch(($vm.Tags['vmtype'])){
					    "role1" {$configname = "demo_role1.role1node"}
					    default {$configname = $null}
				    }
	                "Registering Phase"
	                Register-AzureRmAutomationDscNode -NodeConfigurationName $configname -ActionAfterReboot ContinueConfiguration -AllowModuleOverwrite $true `
	                -ResourceGroupName $AutomationAccountResourceGroup `
	                -AutomationAccountName $AutomationAccountName -AzureVMName $vm.Name -AzureVMResourceGroup $vm.ResourceGroupName `
	                -ConfigurationMode ApplyAndAutocorrect `
	                -RebootNodeIfNeeded $true -AzureVMLocation $vm.Location -AllowModuleOverwrite $true
	        }
        }
	}