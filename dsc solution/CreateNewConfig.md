# Instructions to add a new VM Classification 
There are scenarios where you would need to add a brand new configuration for a new VM type. This document will guide you to the steps you need to take to create a new configuration and the code modifications to integrate the configuration with AA DSC. 

Step 1: Create new configuration
================================
The source code contains a base configuration called ABB_vso_base. You can use that to produce a copy that would hold the specific configurations of your scenario. 
Once you have finished modifying it you can upload the new configuraiton to AA DSC. You can get further instructions in the AA DSC Documentation provided. For additional information on modifying it to add new scenarios please read the ReadMe.md file for external resource links. 

NOTE: Remember to swap out the ABB_vso_base name in the code with your custom config name as well as rename the code file to match.  

Step 2: Code modifications 
==========================

You would need to modify buildnodecfgs runbook source code. 

1. After line 64 you would need to copy the previous line and write in new value representing your new VM classifiction. The configname would have to be the same 
one you created in Step 1. 

Step3: Create your own rebuild custom config runbook. 
=====================================================

1. Make a copy of the rebuildalldataservcfgs runbook and rename it to rebuildall<yourconfigname>cfgs
2. At line 56 rename the configname value to the name determined in Step 1. 
3. Upload your new runbook into AA DSC. You can get further instructions in the AA DSC Documentation provided.