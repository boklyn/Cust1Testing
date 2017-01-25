#
# Configuration Data 
#
Add-AzureRmAccount
$ConfigurationName = "demo_role1"
$ConfigurationName = "hp_omsinstall"
$cd = @{
    AllNodes = @(
        @{
			NodeName = 'Localhost'
        }
    )
}
#msft subscription
$subid = "4ff56ee1-f567-4548-9bf0-bea3525e4d61"
#hp devitg subscription
$subid = "5736b0e6-6932-4a38-8196-f46c1ed28af5"
$subid = "474eba22-0ce0-4b20-8815-d56b04aaba88"
$AutomationAccountName = "demoaccount"
$AutomationAccountName = "IMAP-EDW-DevITG-AutoAcct"
$AutomationAccountName = "IMAP-EDW-OMS-PRO-AutoAcct"
$ResourceGroupName = "boklyndemo"
$ResourceGroupName = "imap-edw-itg"
$ResourceGroupName = "imap-edw-production"
$DscBasePath = "C:\Users\boklyn\OneDrive - Microsoft\Engagements\HP"
$DscScriptPath = "$DscBasePath\$ConfigurationName.ps1"


#Login-AzureRmAccount
Get-AzureRmSubscription -SubscriptionId $subid  | Set-AzureRmContext

"Uploading $DscScriptPath"
Import-AzureRmAutomationDscConfiguration -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -SourcePath $DscScriptPath -Force -Published;

"Compiling ConfigurationData"
Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -ConfigurationName $ConfigurationName -ConfigurationData $cd;
