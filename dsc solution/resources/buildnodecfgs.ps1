	<### Constants Start ###>
	$connectionName  = "AzureRunAsConnection"
	$SubId = "c0e356c9-2cd9-4257-8aa8-63d8ea04ce6f"
	$AutomationAccountName = "abbsc-vsoaa-01"
	$AutomationAccountResourceGroup = "abbsc-vsorgp-01"	
    $rgdscgrps =  Get-AutomationVariable -Name "rgdscgrps"
    $freq =  Get-AutomationVariable -Name "dsccfg_frequency"
    $refreq =  Get-AutomationVariable -Name "dsccfg_refreshfreq"
    $subids =  Get-AutomationVariable -Name "subscriptionids"
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
	   Set-AzureRmContext -SubscriptionId $subids             
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
			        $ConfigData =  @{
			            AllNodes = @(
			                @{
			                    Nodename = "*"
			                    PSDscAllowPlainTextPassword = $true
			                }
			            )
			        }
		            $curvmnode =  @{
		                    NodeName           = $vmnamemod
		                    Role               = $vm.Tags['vmtype']
		            }
	        	    $ConfigData.AllNodes += $curvmnode	 
				    switch(($vm.Tags['vmtype'])){
					    "analyst" {$configname = "ABB_vso_analyst"}
					    "gisanalyst" {$configname = "ABB_vso_gisanalyst"}
					    "dataserv" {$configname = "ABB_vso_dataserv"}
					    default {$configname = $null}
				    }
            	    $CompilationJob =Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $AutomationAccountResourceGroup -AutomationAccountName $AutomationAccountName -ConfigurationName $configname -ConfigurationData $ConfigData -Parameters $params
	                Start-Sleep -s 60
                    while($CompilationJob.EndTime –eq $null -and $CompilationJob.Exception –eq $null)           
	                {
	                    #$CompilationJob.Status
	                    $CompilationJob = $CompilationJob | Get-AzureRmAutomationDscCompilationJob
	                    Start-Sleep -Seconds 6
	                }
	                if($CompilationJob.Status -eq "Completed"){
	                    "Registering Phase"
	                    Register-AzureRmAutomationDscNode -ActionAfterReboot ContinueConfiguration -AllowModuleOverwrite $true `
	                    -ResourceGroupName $AutomationAccountResourceGroup `
	                    -AutomationAccountName $AutomationAccountName -AzureVMName $vm.Name -AzureVMResourceGroup $vm.ResourceGroupName `
	                    -ConfigurationMode ApplyAndAutocorrect -ConfigurationModeFrequencyMins $freq `
	                    -NodeConfigurationName ($configname+"."+$vmnamemod) -RefreshFrequencyMins $refreq `
	                    -RebootNodeIfNeeded $true -AzureVMLocation $vm.Location
	                }		
	                else{                
		               $ErrorMessage = "Compilation of DSC configuration failed."
		               throw $ErrorMessage
	                }
	        }
        }
	}