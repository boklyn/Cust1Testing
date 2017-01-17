# Resources
This document will cover the following resources

1. buildnodecfgs
3. rebuildallnodecgs
4. rebuildallvsoanalysts
5. rebuildallvsodataserv
6. rebuildallvsogisanalysts
7. installdrives

For scripts 1-6 there has been additional line of code added to place the script in sleep mode for 60 seconds. This code is usually placed after
the Start-AzureRmAutomationDscCompilationJob invocation call. If you are noticing compilation error you might increase this value. 

buildnodecfgs
=============
This is a runbook script that enables new machines to be added into DSC automation management. This script will depend on the following two azure automation variables:

1. subscriptionids

  This is the subscription ID, in which the azure automation will pull the azure automation variables. 
2. rgdscgrps

This is the automation variable that holds all resource group that is covered by the solution. 
This Azure Automation runbook, will run on a schedule that will allow the environment to add any additional virtual machines to monitoring.

NOTE: The script also depends on the VM have a tag called vmtype in place. The only supported values to assign a node to a configuration are:

1. analyst
2. gisanalyst
3. dataserv

The process of onboarding a VM to this DSC solution involves the following steps:

1. Ensure that the Resource group that the VM is located is part of the rgdscgrps AA varible. Planning is key because you do not want to provision a VM in a resource group with other virtual machines that you don't want the DSC AA solution to cover. By adding a resource group onto the AA variable forces the script to automatically add all virtual machines in that resource group into AA DSC management. 
2. Ensure that the vm has a Azure Tag of vmtype filled with one of the supported values listed above. 

rebuildallnodecgs
=================
This runbook would rebuild all DSC node configuration based on a new update. This runbook will be execute if you've made a change in the DSC configurations and you would like to recompile it for all of the nodes. 

rebuildallvsoanalysts
=====================
This runbook would rebuild only DSC nodes' configurations of VSO Analysts type.  

rebuildallvsodataserv
=====================
This runbook would rebuild only DSC nodes' configurations of Data Services type.  

rebuildallvsogisanalysts
========================
This runbook would rebuild only DSC nodes' configurations of GIS Analysts type.

installdrives
=============
This is a bat file script that is placed on each workstation's desktop. Upon execution the bat file will map out network drives used by end users. 
