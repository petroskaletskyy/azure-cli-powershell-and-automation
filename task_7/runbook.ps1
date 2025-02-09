param(
    [string]$ResourceGroupName,
    [string]$VMName
)

try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity

    Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -NoWait
    Write-Output "VM start command executed successfully."
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}