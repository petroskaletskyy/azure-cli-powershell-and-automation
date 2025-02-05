# Azure CLI and Azure PowerShell and Azure Automation Tasks

## Practical Task 1: Install and Configure Azure CLI and PowerShell

1. Install Azure CLI and Azure PowerShell on your local machine.
2. Verify the installation by checking the versions of Azure CLI and PowerShell modules.
3. Log in to your Azure account using both Azure CLI and PowerShell.
4. List all available subscriptions in your Azure account using both tools.

![img](/screenshots/1_1.png)
![img](/screenshots/1_2.png)

## Practical Task 2: Create and Manage Resource Groups

1. Use Azure CLI to create a new resource group named MyResourceGroup in the East US region.
2. Use Azure PowerShell to create a new resource group named MyPSResourceGroup in the West Europe region.
3. List all resource groups in your subscription using both CLI and PowerShell.
4. Delete the resource group MyResourceGroup using Azure CLI.
5. Delete the resource group MyPSResourceGroup using Azure PowerShell.

## Practical Task 3: Deploy and Manage Virtual Machines using Azure CLI and PowerShell

1. Use Azure CLI to create a new virtual machine named MyVM1 in a new resource group VMResourceGroup.
2. Use Azure PowerShell to create another virtual machine named MyVM2 in the same resource group.
3. Retrieve details about both virtual machines using both CLI and PowerShell.
4. Stop MyVM1 using Azure CLI and MyVM2 using Azure PowerShell.
5. Delete the virtual machines using the respective tools.

## Practical Task 4: Manage Storage Accounts using Azure CLI and PowerShell

1. Use Azure CLI to create a new storage account named mystoragecli in the East US region.
2. Use Azure PowerShell to create a new storage account named mystorageps in the West Europe region.
3. List all storage accounts in the subscription using both CLI and PowerShell.
4. Retrieve the connection string for the mystoragecli storage account using Azure CLI.
5. Retrieve the connection string for the mystorageps storage account using Azure PowerShell.
6. Delete both storage accounts using the respective tools.

## Practical Task 5: Assign Role-Based Access Control (RBAC) Roles

1. Create a new Azure Active Directory user named ```testuser@example.com``` using Azure CLI.
2. Assign the Reader role to ```testuser@example.com``` for a specific resource group using Azure CLI.
3. Use Azure PowerShell to assign the Contributor role to ```testuser@example.com``` for a specific storage account.
4. Verify that the user has been assigned the correct roles using both CLI and PowerShell.
5. Remove the user’s role assignments using the respective tools.

## Practical Task 6: Set Up a Scalable Web Server with VM, Storage, and Networking

1. Create a Resource Group
2. Use Azure CLI to create a resource group named WebServerGroup in the East US region.
3. Deploy a Virtual Network (VNet) and Subnet
4. Use Azure CLI to create a virtual network named WebVNet in WebServerGroup.
5. Add a subnet named WebSubnet.
6. Create a Storage Account for Logs
7. Use Azure PowerShell to create a storage account named webserverlogs in WebServerGroup.
8. Enable blob storage and set up a container named logs for storing application logs.
9. Deploy a Virtual Machine as a Web Server
10. Use Azure CLI to create a virtual machine named WebVM in WebServerGroup.
11. Configure WebVM to use the WebVNet and WebSubnet.
12. Open port 80 on the VM for web traffic.
13. Install and Configure Nginx on the VM
14. Use Azure CLI to execute a script on WebVM that installs and configures Nginx as a web server.
15. Enable Diagnostics and Store Logs in Storage Account
16. Use Azure PowerShell to enable diagnostics on WebVM, directing logs to webserverlogs storage account.
17. Verify the Web Server is Running
18. Retrieve the public IP of WebVM using Azure CLI.
19. Access the Nginx default page from a web browser using ```http://<Public-IP>```.
20. Clean Up Resources
21. Delete all created resources (WebVM, webserverlogs, WebVNet, WebServerGroup) using both Azure CLI and PowerShell.

## Practical Task 7: Create and Run an Azure Automation Runbook

1. Create an Azure Automation Account named MyAutomationAccount in the East US region using Azure CLI.
2. Create a PowerShell Runbook named StartAzureVMRunbook inside MyAutomationAccount.
3. Edit the Runbook to start a specified Azure Virtual Machine when executed.
4. Test the Runbook manually by executing it and verifying that the VM starts.
5. Publish the Runbook and set up a schedule to automatically run it every day at 6:00 AM.

## Practical Task 8: Automate Resource Cleanup Using a PowerShell Runbook

1. Create a new Runbook named CleanupOldResources in MyAutomationAccount.
2. Write a PowerShell script that:
3. Lists all resource groups that have not been used in the past 30 days.
4. Deletes unused resource groups after user confirmation.
5. Test the Runbook in Azure Automation.
6. Publish the Runbook and configure a webhook to trigger it on demand.
7. Call the webhook using Azure CLI and verify the cleanup process.

## Practical Task 9: Implement Desired State Configuration (DSC) to Enforce VM Settings

1. Create a new Azure Automation DSC Configuration named MyDSCConfig.
2. Define a DSC script that:
3. Ensures the Windows feature Web-Server (IIS) is installed on a Windows VM.
4. Ensures a specific configuration file (C:\inetpub\wwwroot\config.xml) exists with predefined content.
5. Ensures that a required Windows service (e.g., w3svc) is always running.
6. Compile and publish the DSC configuration in Azure Automation.
7. Assign the DSC configuration to an existing VM and verify compliance.
8. Force a non-compliant state (e.g., stop the service or delete the config file), the observe Azure Automation remediating the issue automatically.

## Practical Task 10: Automate Multi-Resource Deployment and Configuration Using Runbooks and DSC

1. Create a new Runbook named DeployAndConfigureWebServer.
2. Inside the Runbook, automate the following tasks:
3. Create a new VM named WebServerVM.
4. Attach a managed disk to WebServerVM.
5. Deploy a DSC configuration to ensure IIS is installed and a website is running.
6. Publish and execute the Runbook, ensuring the web server is deployed and configured automatically.
7. Verify the deployment by accessing the website hosted on the VM via its public IP address.
8. Implement logging within the Runbook to track execution progress.
