<### Constants Start ###>
$connectionName  = "AzureRunAsConnection"
$SubId = "c0e356c9-2cd9-4257-8aa8-63d8ea04ce6f"
$AutomationAccountName = "abbsc-vsoaa-01"
$AutomationAccountResourceGroup = "abbsc-vsorgp-01"	
	
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
$rgdscgrps =  Get-AutomationVariable -Name "rgdscgrps"
$rgdscgrps = $rgdscgrps.Split(",")
foreach ($rgdscgrp in $rgdscgrps){
	$vms = Get-AzureRmVM -ResourceGroupName $rgdscgrp
	foreach ($vm in $vms){
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
	}
}