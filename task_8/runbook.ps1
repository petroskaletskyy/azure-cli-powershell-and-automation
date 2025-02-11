param
(
    [Parameter(Mandatory=$true)]
    [int]$daysInactive,

    [ValidateSet("yes", "no")]
    [string]$confirmation = "no"
)

# Authenticate using Managed Identity
Connect-AzAccount -Identity

#define the inactivity period
$cutoffTime = (Get-Date).AddDays(-$daysInactive)

# Retrieve all resource group
$resourceGroups = Get-AzResourceGroup 

# Create an empty list to store inactive resource groups
$inactiveResourceGroups = @()

foreach ($rg in $resourceGroups) {
    # Get activity log  for the resource group
    $Activity = Get-AzActivityLog -StartTime $cutoffTime -ResourceGroupName $rg.ResourceGroupName

    # If no activity is found, consider it inactive
    if (-not $Activity) {
        $inactiveResourceGroups += $rg.ResourceGroupName
    }
 }

# Output the inactive resource groups
if ($inactiveResourceGroups.Count -eq 0) {
    Write-Output "All resource groups have been used in the last $daysInactive days."
} else {
    Write-Output "Inactive Resource Groups (No activity in last $daysInactive days):"
    $inactiveResourceGroups | ForEach-Object { Write-Output "- $_" }
}

# Confirm deletion
#$confirmation = Read-Host "Do you want to delete these resource groups? (yes/no)"
if ($confirmation -eq "yes") {
    foreach ($rg in $inactiveResourceGroups) {
        Write-Output "Deleting resource group: $rg"
        Remove-AzResourceGroup -Name $rg -Force -Confirm:$false
    }
    Write-Output "Cleanup completed."
} else {
    Write-Output "Cleanup canceled."
}