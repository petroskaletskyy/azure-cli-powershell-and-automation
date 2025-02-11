$grp = "OldResourceCleanupResourceGroup"
$location = "northeurope"
$vmName = "TestWindowsVM"

# Create resource group
az group create --name $grp --location $location

# Creating VM
az vm create --resource-group $grp --name $vmName --image Win2019Datacenter --admin-username azureuser --admin-password 
az vm open-port --resource-group $grp --name $vmName --priority 100 --port 80

# Import configuration
$grp = "OldResourceCleanupResourceGroup"
Import-AzAutomationDscConfiguration -Published -ResourceGroupName $grp -SourcePath ./task_9/configuration.ps1 -Force -AutomationAccountName MyAutomationAccount