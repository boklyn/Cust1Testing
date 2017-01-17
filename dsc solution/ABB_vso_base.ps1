Configuration ABB_vso_base {
    param(
    [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
    [string]$nodename
    ) 
    #$jreurl =  Get-AutomationVariable -Name "url_jre"   
    function Format-DscScriptBlock()
    {
        param(
            [parameter(Mandatory=$true)]
            [System.Collections.Hashtable] $node,
            [parameter(Mandatory=$true)]
            [System.Management.Automation.ScriptBlock] $scriptBlock,
            [parameter(Mandatory=$true)]
            [String] $appname,                     
            [Int]$RefreshFrequencyMins = 180,            
            [Int]$ConfigurationModeFrequencyMins = 60,            
            [String]$ConfigurationMode = "ApplyAndAutocorrect",    
            [Boolean]$RebootNodeIfNeeded= $True,
            [String]$ActionAfterReboot = "ContinueConfiguration",
            [Boolean]$AllowModuleOverwrite = $True
        )
        $result = $scriptBlock.ToString();
        switch($appname){
            "appurlpath" {
                $appurlpath = Get-AutomationVariable -Name "url_apppath"
                $result = $result.Replace("`$appurl", $apspurlpath)
                    }              
        }
        return $result;
    } 
    Import-DSCResource -Module xSystemSecurity -Name xIEEsc
    #get storage one time access token.  to provision solution.     
    node $nodename {    
        #togetproductid you need to execute Get-WmiObject -Class Win32_Product | fl Name,Version,InstallDate,InstallSource,PackageName,IdentifyingNumber           
        xIEEsc DisableIEEscAdmin
        {
            IsEnabled = $False
            UserRole  = "Administrators"
        }
        xIEEsc DisableIEEsc 
        { 
            IsEnabled = $False 
            UserRole = "Users" 
        }
    }
}