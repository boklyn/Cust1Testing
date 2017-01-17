# Velocity Azure Automation DSC system. 

After the workstations are provisioned by ARM, the machines will be managed and configured by Azure Automation DSC for software settings. There are three DSC roles that can be appled based on the vmtype tag value of each machine. The roles are as follows:

1. ABB_vso_anaylst
2. ABB_vso_dataserv
3. ABB_vso_gisanalyst

The solution is dependent on the following requirements: 

1. AA Enviornmental variables

   Each DSC role confguration depends on Azure Automation Environmental variables to be in place for reference. For software installation the variables holds the URL secure string for the installation executable or zip files. For DSC node integration, the environmental variables will tell the agent how often it communicates with the parent server, and which resource groups to target for DSC integration. 
2. The script resources needed to create runbooks. 

ABB_vso_anaylst
===============
The following software and configuration will be appled to all machines with the "analyst" value for the vmtype tag:

1. Disable Internet exploer enhanced security for both Administrators and Users. 
2. Java installation 
3. MS SQL Studio Express
4. Adobe Reader
5. Tortoise
6. Toad 10.5
7. Oracle 32Bit Client
8. Oracle 64Bit Client
9. Network Drive Mapping bat file. 

ABB_vso_dataserv
================
The following software and configuration will be appled to all machines with the "dataserv" value for the vmtype tag:

1. Disable Internet exploer enhanced security for both Administrators and Users. 
2. Tortoise
3. Toad 12.6
4. Java installation
5. MS SQL Studio Express
6. Adobe Reader
7. Oracle 32Bit Client
8. Oracle 64Bit Client
9. Network Drive Mapping bat file. 

ABB_vso_gisanalyst
==================
The following software and configuration will be appled to all machines with the "gisanalyst" value for the vmtype tag:

1. Disable Internet exploer enhanced security for both Administrators and Users. 
2. Map Pro
3. Toad 10.5
4. Java installation
5. MS SQL Studio Express
6. Adobe Reader
7. Oracle 32Bit Client
8. Oracle 64Bit Client
9. Network Drive Mapping bat file
10. Gootle Earth Pro
11. Map Basic

Updating AA environmental variables
===================================
For the purposes of DSC Automation AA environmental variables store the URL link for the softwares needed by DSC. Those links have a one year expiration date. At some point you would have to update those values to correct ones, or need to upate them due to new versions of the software that you are currently using for new provisioned VM. To update them you can use Azure storage explorer preview to generate your SAS tokens. Through the portal you will be provided access to the azure automation account and under the asset tab you should see all the azure automation varaibles in place. 
Using azure storage explorer preview you can also upload any new software verions you have. The storage account we are currently using to store the software assets is: abbscvsostor01. 

Script DSC Resource usage
=========================
This solution uses the DSC script resource to cover application installations that require more than one file present. The script resource will download the package locally and proceed to unpackage the files onto a folder. From there the script resource will then install the application. For applications that are 64bit, the script resource will detect the 32bit process running and exit and restart the installation under a 64bit process. For more information on DSC script resource please see the following link: https://msdn.microsoft.com/en-us/powershell/dsc/scriptresource

Format-DscScriptBlock function usage:

The dsc script resource requires that dynamic variables be determined at compilation time of the configuration file. This forces us to create a helper function in order to dynamically assign the value during compilation phase. All the function does is retrieve the value of the application url from Azure Automation variables and replace the appurl string with the retrieved value. If you are planning to add additional script resources you would need to add the additional switch case for your application. Please see the other switch cases for additional guidance. 

DSC Package Usage 
=================

The DSC package is used for application installation executables or MSI files. It assumes that you are downloading only one file and you should use the DSC script resource if you are expecting more files than the primary executable. The DSC package resource is a basic resource type in which you specifc the path to the package and the arguements for the executable. For additional instructions please refer to the following link:

https://msdn.microsoft.com/en-us/powershell/dsc/packageresource

Generating New URL for AA variables
===================================
There are scenarios in which you would have to update the AA variables with new values. They are:

1. You would need to update the DSC configuration to reflect new software versions. 
2. You would neeed to add a new AA variable for a new software added to a specific DC configurations.
3. The current SAS token is about to expire

The first step you would neeed to take is to uplaod your new file onto the the storage account for scenarios 1 and 2. 
After that you would need a URL value to either enter into the new AA variable or update the existing AA variable. To get the URL please follow the instructions from GenerateSASTokenFromBlob document. 
