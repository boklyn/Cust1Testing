Configuration ABB_vso_analyst {
    param(
    [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
    [string]$nodename
    ) 
    $jreurl =  Get-AutomationVariable -Name "url_jre" 
    $sqlsvrmgmtstudiourl =  Get-AutomationVariable -Name "url_sqlsvrmgmtstudio"  
    $adoberdurl =  Get-AutomationVariable -Name "url_adoberd" 
    
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
            "tortoise" {
                $tortoise = Get-AutomationVariable -Name "url_tortoise"
                $result = $result.Replace("`$appurl", $tortoise)
                    } 
            "toadoracle105" {
                $toad105 = Get-AutomationVariable -Name "url_toad105"
                $result = $result.Replace("`$appurl", $toad105)
                    }
            "mapdrives" {
                $mapdriveurl = Get-AutomationVariable -Name "url_mapdrivescript"
                $result = $result.Replace("`$appurl", $mapdriveurl)
                    }
            "oracle64" {
                $oracle64url = Get-AutomationVariable -Name "url_oracle64"
                $result = $result.Replace("`$appurl", $oracle64url)
                    }
            "oracle32" {
                $oracle32url = Get-AutomationVariable -Name "url_oracle32"
                $result = $result.Replace("`$appurl", $oracle32url)
                    }
            "webroot" {
                $webrooturl = Get-AutomationVariable -Name "url_webroot"
                $result = $result.Replace("`$appurl", $webrooturl)
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
        package jrepkg
        {
            Ensure = "Present"  # You can also set Ensure to "Absent"
            Path  = $jreurl
            Name = "jrepkg"
            ProductId = "26A24AE4-039D-4CA4-87B4-2F03217075FF"
            Arguments = "/s"
        }
        package sqlserverstudiopkg
        {
            Ensure = "Present"  # You can also set Ensure to "Absent"
            Path  = $sqlsvrmgmtstudiourl
            Name = "sqlserverstudiopkg"
            ProductId = "264F5132-9818-4334-ADFC-03CA499B7394"
            Arguments = "SSMS-Setup-ENU.exe /ACTION=""Install"" /IACCEPTSQLSERVERLICENSETERMS /Q /INDICATEPROGRESS /FEATURES=""Tools"""
        }  
        package adoberdpkg
        {
            Ensure = "Present"  # You can also set Ensure to "Absent"
            Path  = $adoberdurl
            Name = "adoberdpkg"
            ProductId = "AC76BA86-7AD7-1033-7B44-AB0000000001"
            Arguments = "/msi EULA_ACCEPT=YES REMOVE_PREVIOUS=YES /qn"
        }    

        #togetproductid you need to execute Get-WmiObject -Class Win32_Product | fl Name,Version,InstallDate,InstallSource,PackageName,IdentifyingNumber         
        Script installtort
        {
            SetScript = Format-DscScriptBlock -Node $Node -appname "tortoise" -ScriptBlock { 
                if ($pshome -like "*syswow64*") {
                    #write-warning "Restarting script under 64 bit powershell" 
                    # relaunch this script under 64 bit shell
                    # if you want powershell 2.0, add -version 2 *before* -file parameter
                    & (join-path ($pshome -replace "syswow64", "sysnative") powershell.exe) -file `
                        (join-path $psscriptroot $myinvocation.mycommand) @args 
                    # exit 32 bit script
                    exit
                }
                (New-Object System.Net.WebClient).DownloadFile("$appurl", 'D:\tortoise.msi');
                $process = Start-Process -FilePath "D:\tortoise.msi" -ArgumentList '/quiet' -Wait -PassThru
            }
            TestScript = { 
                $appexist = Get-WmiObject -Class Win32_Product -filter "name='TortoiseSVN 1.9.4.27285 (64 bit)' AND version='1.9.27285'"
                -not ($appexist -eq $null)
            }
            GetScript = { @{ Result = "1.9.27285"} }          
        }            
        Script installtoad
        {
            SetScript = Format-DscScriptBlock -Node $Node -appname "toadoracle105" -ScriptBlock { 
                
                if ($pshome -like "*syswow64*") {
                    #write-warning "Restarting script under 64 bit powershell" 
                    # relaunch this script under 64 bit shell
                    # if you want powershell 2.0, add -version 2 *before* -file parameter
                    & (join-path ($pshome -replace "syswow64", "sysnative") powershell.exe) -file `
                        (join-path $psscriptroot $myinvocation.mycommand) @args 
                    # exit 32 bit script
                    exit
                }
                [Environment]::SetEnvironmentVariable("TNS_ADMIN", "\\usw-fsprd1-vm\Network", "Machine")
                (New-Object System.Net.WebClient).DownloadFile("$appurl", 'D:\ToadforOracle105SetupFull64.msi');
                $process = Start-Process -FilePath "D:\ToadforOracle105SetupFull64.msi" -ArgumentList '/q' -Wait -PassThru
            }
            TestScript = { 
                $appexist = Get-WmiObject -Class Win32_Product -filter "name='Toad for Oracle 10.5' AND version='10.5.0.41'"
                -not ($appexist -eq $null)
            }
            GetScript = { @{ Result = "10.5.0.41"} }          
        }          
        Script installoracle32
        {
            SetScript = Format-DscScriptBlock -Node $Node -appname "oracle32" -ScriptBlock { 
                $sw = New-Object System.IO.StreamWriter("C:\oracle32install.txt")
                $sw.WriteLine("oracle32 was executed")
                $sw.WriteLine("$appurl")
                $sw.Close()
                <#if ($pshome -like "*syswow64*") {
                    #write-warning "Restarting script under 64 bit powershell" 
                    # relaunch this script under 64 bit shell
                    # if you want powershell 2.0, add -version 2 *before* -file parameter
                    & (join-path ($pshome -replace "syswow64", "sysnative") powershell.exe) -file `
                        (join-path $psscriptroot $myinvocation.mycommand) @args 
                    # exit 32 bit script
                    exit
                }#>
                (New-Object System.Net.WebClient).DownloadFile("$appurl", 'D:\oracle32.zip');
                New-Item D:\oracle32 -type directory
                $shell = New-Object -com shell.application;
                $zip = $shell.NameSpace('D:\oracle32.zip');
                $dest = $shell.NameSpace('D:\oracle32\');
                $dest.CopyHere($zip.items());
                $process = Start-Process -FilePath "D:\oracle32\setup.exe" -ArgumentList '-silent -nowelcome -noconfig -noconsole -nowait -responseFile D:\oracle32\client.rsp' -Wait -PassThru
            }
            TestScript = { 
                $scriptexist = test-path "C:\oracle32install.txt"
                $scriptexist
            }
            GetScript = { @{ Result = "10.5.0.41"} }          
        }           
        Script installoracle64
        {
            SetScript = Format-DscScriptBlock -Node $Node -appname "oracle64" -ScriptBlock { 
                $sw = New-Object System.IO.StreamWriter("C:\oracle64install.txt")
                $sw.WriteLine("oracle64 was executed")
                $sw.Close()
                if ($pshome -like "*syswow64*") {
                    #write-warning "Restarting script under 64 bit powershell" 
                    # relaunch this script under 64 bit shell
                    # if you want powershell 2.0, add -version 2 *before* -file parameter
                    & (join-path ($pshome -replace "syswow64", "sysnative") powershell.exe) -file `
                        (join-path $psscriptroot $myinvocation.mycommand) @args 
                    # exit 32 bit script
                    exit
                }
                (New-Object System.Net.WebClient).DownloadFile("$appurl", 'D:\oracle64.zip');
                New-Item D:\oracle64 -type directory
                $shell = New-Object -com shell.application;
                $zip = $shell.NameSpace('D:\oracle64.zip');
                $dest = $shell.NameSpace('D:\oracle64\');
                $dest.CopyHere($zip.items());
                $process = Start-Process -FilePath "D:\oracle64\setup.exe" -ArgumentList '-silent -nowelcome -noconfig -noconsole -nowait -responseFile D:\oracle64\client.rsp' -Wait -PassThru
            }
            TestScript = { 
                $scriptexist = test-path "C:\oracle64install.txt"
                $scriptexist
            }
            GetScript = { @{ Result = "10.5.0.41"} }          
        }     
        Script installdrivebat
        {
            SetScript = Format-DscScriptBlock -Node $Node -appname "mapdrives" -ScriptBlock { 
                (New-Object System.Net.WebClient).DownloadFile("$appurl", 'C:\Users\Public\Desktop\installdrives.bat')
            }
            TestScript = { 
                $scriptexist = test-path "C:\Users\Public\Desktop\installdrives.bat"
                $scriptexist
            }
            GetScript = { @{ Result = "File Exists"} }          
        }
        Script webroot
        {
            SetScript = Format-DscScriptBlock -Node $Node -appname "webroot" -ScriptBlock { 
                if ($pshome -like "*syswow64*") {
                    #write-warning "Restarting script under 64 bit powershell" 
                    # relaunch this script under 64 bit shell
                    # if you want powershell 2.0, add -version 2 *before* -file parameter
                    & (join-path ($pshome -replace "syswow64", "sysnative") powershell.exe) -file `
                        (join-path $psscriptroot $myinvocation.mycommand) @args 
                    # exit 32 bit script
                    exit
                }

                (New-Object System.Net.WebClient).DownloadFile("$appurl", 'D:\wsasme.msi')

                $process = Start-Process -FilePath "D:\wsasme.msi" -ArgumentList 'GUILIC=SAAC-SNNX-5E74-97F2-9F5B CMDLINE=SME,quiet /qn' -Wait -PassThru
            }
            TestScript = {
                $appexist = Get-WmiObject -Class Win32_Product -filter "name='Webroot SecureAnywhere' AND version='9.13.58'"
                -not ($appexist -eq $null)            }
            GetScript = { @{ Result = "File Exists"} }          
        }
    }
}
