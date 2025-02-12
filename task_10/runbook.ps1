# Define parameters
param (
    [string]$ResourceGroupName = "OldResourceCleanupResourceGroup",
    [string]$Location = "North Europe",
    [string]$VMName = "WebServerVM",
    [string]$AdminUser = "azureuser",
    [string]$AdminPassword = "P@ssw0rd123",
    [string]$AutomationAccountName = "MyAutomationAccount",
    [string]$ConfigName = "IISConfig"
)

# Authenticate using Managed Identity
Write-Output "Authenticating with Managed Identity..."
$AzureContext = (Connect-AzAccount -Identity).Context
Write-Output "Authentication successful for: $($AzureContext.Account)"

# Set the correct Azure Subscription
Set-AzContext -SubscriptionId $AzureContext.Subscription.Id

# Get the Automation Account's Managed Identity Object ID
Write-Output "Retrieving Managed Identity Object ID..."
$ManagedIdentity = (Get-AzAutomationAccount -ResourceGroupName $ResourceGroupName -Name $AutomationAccountName).Identity.PrincipalId

# Assign "Contributor" role to the Automation Account
Write-Output "Assigning 'Contributor' role to the Automation Account..."
New-AzRoleAssignment -ObjectId $ManagedIdentity -RoleDefinitionName "Contributor" -Scope "/subscriptions/$($AzureContext.Subscription.Id)/resourceGroups/$ResourceGroupName" -ErrorAction SilentlyContinue
Write-Output "Role assignment completed."

# Convert password to secure string
$SecurePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($AdminUser, $SecurePassword)

# Log start
Write-Output "Starting Deployment Process...."

# Create Public IP Address
Write-Output "Creating Public IP Address..."
$PublicIP = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Location $Location -Name "$VMName-PublicIP" -AllocationMethod Static
Write-Output "Public IP Created: $($PublicIP.IpAddress)"

# Create Virtual Network
Write-Output "Creating Virtual Network and Subnet..."
$SubnetConfig = New-AzVirtualNetworkSubnetConfig -Name "$VMName-Subnet" -AddressPrefix "10.0.0.0/24"
$VNet = New-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Location $Location -Name "$VMName-VNet" -AddressPrefix "10.0.0.0/16" -Subnet $SubnetConfig

# Create Network Security Group and Open Ports
Write-Output "Configuring Network Security Group (NSG)..."
$NSG = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $Location -Name "$VMName-NSG"
$RuleHTTP = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Priority 100 -Access Allow -Direction Inbound -Protocol Tcp -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80
$RuleRDP = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Priority 110 -Access Allow -Direction Inbound -Protocol Tcp -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$NSG.SecurityRules += $RuleHTTP
$NSG.SecurityRules += $RuleRDP
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $NSG

# Create Network Interface and Assign Public IP
Write-Output "Creating Network Interface..."
$NIC = New-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Location $Location -Name "$VMName-NIC" -SubnetId $VNet.Subnets[0].Id -PublicIpAddressId $PublicIP.Id -NetworkSecurityGroupId $NSG.Id

# Create VM Configuration
Write-Output "Creating VM Configuration..."
$VMConfig = New-AzVMConfig -VMName $VMName -VMSize "Standard_DS2_v2" | `
    Set-AzVMOperatingSystem -Windows -ComputerName $VMName -Credential $Credential | `
    Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" | `
    Add-AzVMNetworkInterface -Id $NIC.Id | `
    Set-AzVMBootDiagnostic -Disable

# Create the VM
Write-Output "Creating Virtual Machine..."
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VMConfig

# Attach managed disk
Write-Output "Attaching Managed Disk to $VMName..."
$DiskConfig = New-AzDiskConfig -Location $Location -CreateOption Empty -DiskSizeGB 64 -SkuName "Standard_LRS"
$DataDisk = New-AzDisk -ResourceGroupName $ResourceGroupName -DiskName "$VMName-Disk" -Disk $DiskConfig
$VM = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
$VM = Add-AzVMDataDisk -VM $VM -Name "$VMName-Disk" -ManagedDiskId $DataDisk.Id -Lun 1 -CreateOption Attach
Update-AzVM -VM $VM -ResourceGroupName $ResourceGroupName

# Deploy DSC Configuration
Write-Output "Deploying DSC Configuration...."
$dscConfig = @"
Configuration $ConfigName 
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    Node "localhost" 
    {
        WindowsFeature IIS 
        {
            Ensure = "Present"
            Name = "Web-Server"
        }
        File WebPage 
        {
            Ensure = "Present"
            Type = "File"
            DestinationPath = "C:\\inetpub\\wwwroot\\index.html"
            Contents = "Hello, World! This is the WebServerVM."
        }
    }
}
"@

# Save DSC configuration to a file
$dscConfigPath = "$env:TEMP\$ConfigName.ps1"
$dscConfig | Out-File -FilePath $dscConfigPath -Encoding UTF8 -Force

# Verify file creation
if (-not (Test-Path $dscConfigPath)) {
    Write-Output "Error: Failed to save DSC configuration file."
    exit 1
}

Write-Output "DSC configuration file saved successfully at: $dscConfigPath"

# Import DSC Configuration into Azure Automation
Write-Output "Importing DSC Configuration into Azure Automation..."

Import-AzAutomationDscConfiguration `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $AutomationAccountName `
    -SourcePath $dscConfigPath `
    -Published `
    -Force

Start-AzAutomationDscCompilationJob `
    -ConfigurationName $ConfigName `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $AutomationAccountName   

$DSCConfigName = Get-AzAutomationDscNodeConfiguration `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $AutomationAccountName `
    -ConfigurationName "$ConfigName.localhost"

Register-AzAutomationDscNode `
    -AzureVMName $VMName `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $AutomationAccountName `
    -NodeConfigurationName $DSCConfigName `
    -ConfigurationMode ApplyAndAutocorrect `
    -RebootNodeIfNeeded $True         

# Retrieve Public IP
$PublicIPAddress = (Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name "$VMName-PublicIP").IpAddress
Write-Output "Deployment Completed! Access the website at: http://$PublicIPAddress"

Write-Output "Runbook Execution Completed."