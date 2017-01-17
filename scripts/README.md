# Velocity Scripts

This readme provides high level overview of all the scripts in this folder. For detailed information about each script please read the comments located on each script. 

script-createkeyvault
=====================
This script creates the keyvault in which the deployment solution depends on for storing secrets. The following considerations and additional notes for this script are:

1. For line 14 to get a list of possible locations to place your keyvault execute get-azurermlocation and the command will provide you with a list of possible location values. 
2. For line 20, in order to create a keyvault, the user executing this script will have to be a member of the directory that controls the subscription. By default the command will grant the user full control over the keyvault in order to delegate additional users of the keyvault. 
3. For line 22, you can leverage the keyvault to store the keys used to encrypt the disk of your Azure VMs. If your keyvault is expected to provide that functionality, you would need to uncomment this line. 
4. For line 23, you can grant addiitional users acess to this keyvault by uncommenting this line and specifiying your own user's email instead of the token someoneemail@somedomain.com value. This command will grant the user all access to the keyvault. For more selective actions, please see the following link: https://msdn.microsoft.com/en-us/library/mt603625.aspx

script-addkeyvaultsecrets
=========================
The password secrets will have to be stored as clear txt temporarily, you can delete the password after usage for security. The important varibles are storacctname and containername. The script will use these values to build the url values for the template references. 

script-createcustrole
=====================
This script will allow you to create a new Azure Role for the following specific permissions:

1. Ability to start/restart/deallcoate virtual machines
2. Ability to read only the compute/network resources attached to the VM
3. Ability to look at the perfomrance health metrics of the VM. 

The following considerations and additonal notes for the script?

1. For scenarios in which the role has already been created, code lines 30 -32 will allow you to retrieve the role and add additional permissions to the role. It is currently commented out 
 
set-usermachinemap
==================
This script allows the user to process a txt file, to allow a user to be granted local administrator rights, as well as assigned the VSO vm operator azure role to their specific vm. This will allow them to have the ability to start/restart/deallocated their VM. The format of the input file must be as follows:

(vmname),(email@us.abb.com),(velocity.com\userid),(resourcegroupofvm)

1. The second item has to be an us.abb.com valid email since, it will leverage that email to grant portal acccess. 
2. The third item has to be a valid user of the velocity domain. 
3. The fourth item will be the resource group in which the VM would reside. 

Here is an example of a sample input line:

usw-usrwks02-vm,chris.tornow@us.abb.com,velocity.com\ged-ctornow,abbsc-vsorgp-02

Here is an example of a powershell execution line leveraging the inputfile functionality:

.\set-usermachinemap.ps1 -InputFile inputfile.txt

The script also allows you to choose to specific an inputline in case you would like to process one item as oppose to multi-item option of an inputfile. The powershell execution line is as follows:

.\set-usermachinemap.ps1 -InputLine "usw-usrwks02-vm,chris.tornow@us.abb.com,velocity.com\ged-ctornow,abbsc-vsorgp-02"

script-createdeploystorage
==========================
This script will create the storage account use for the deployment solution. The script will also transfer all files in the assets parent folder into the newly created container. The script will depend on the following values filled correctly:

1. subid
2. storlocation
3. resourcegrp
4. storagename
5. containername
6. assetpath

Please see the script for additional details. 


