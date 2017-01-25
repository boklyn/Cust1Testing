Configuration demo_role1 {
    param(
    [Parameter(ValueFromPipeline=$True)]
    [string]$nodename
    ) 
    $OIPackageLocalPath = "D:\MMASetup-AMD64.exe"
	$OIPackageLocalPathSvcMap = "D:\InstallDependencyAgent-Windows.exe"
 
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
 

    #get storage one time access token.  to provision solution.     
    node role1node { 
        xRemoteFile OIPackage {
            Uri = "http://download.microsoft.com/download/1/5/E/15E274B9-F9E2-42AE-86EC-AC988F7631A0/MMASetup-AMD64.exe"
            DestinationPath = $OIPackageLocalPath
        }

        Package OI {
            Ensure = "Present"
            Path  = $OIPackageLocalPath
            Name = "Microsoft Monitoring Agent"
            ProductId = "E387F779-C574-4252-8B91-009CE5648A46"
            Arguments = '/C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_ID=' + $OPSINSIGHTS_WS_ID + ' OPINSIGHTS_WORKSPACE_KEY=' + $OPSINSIGHTS_WS_KEY + ' AcceptEndUserLicenseAgreement=1"'
            DependsOn = "[xRemoteFile]OIPackage"
        } 

        xRemoteFile dagentpackge {
                Uri = "https://aka.ms/dependencyagentwindows"
                DestinationPath = $OIPackageLocalPathSvcMap
                DependsOn = "[Package]OI"
        }

        xScript dagent {
            SetScript = { 
                if ($pshome -like "*syswow64*") {
                    #write-warning "Restarting script under 64 bit powershell" 
                    # relaunch this script under 64 bit shell
                    # if you want powershell 2.0, add -version 2 *before* -file parameter
                    & (join-path ($pshome -replace "syswow64", "sysnative") powershell.exe) -file `
                        (join-path $psscriptroot $myinvocation.mycommand) @args 
                    # exit 32 bit script
                    exit
                }
                $folderdir = "C:\Program Files\Microsoft Dependency Agent"
                $exist = test-path $folderdir
                if($exist){
                    Remove-Item -Recurse -Force $folderdir
                }
                $process = Start-Process -FilePath "D:\InstallDependencyAgent-Windows.exe" -ArgumentList '/S' -Wait -PassThru
            }

            TestScript = { 
                $scriptexist = test-path "C:\Program Files\Microsoft Dependency Agent\Uninstall.exe"
                $scriptexist
            }

            GetScript = { 
                @{ Result = "dependency_agent is installed"} 
            }
                      
            DependsOn = "[xRemoteFile]dagentpackge"
        }   
               
    }
}
