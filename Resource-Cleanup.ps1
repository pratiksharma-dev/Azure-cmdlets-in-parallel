[CmdletBinding()]
param(
[Parameter(Mandatory=$true)]
[array]$rgs,
[Parameter(Mandatory=$false)]
[array]$rgexcludelist=@()

)
if($rgexcludelist.Count -ne 0)
{
$rgs=$rgs|?{$rgexcludelist -notcontains $_}
}

#create jobs and start them 
foreach ($rg in $rgs){ 
    $sb = { 
            Param($rgname) 
            Write-Output "Checking Resource Group $rgname..."
            if((Get-AzureRmResourceGroup -Name $rgname -ErrorAction SilentlyContinue) -ne $null)
            {
            Write-Output "Deleting Resource Group $rgname..."
            Remove-AzureRmResourceGroup -Name $rgname -Force -ErrorAction SilentlyContinue
            }
          } 
 
    New-Variable -Name "Delete$rg" -Value ([PowerShell]::Create()) 
    $null = (Get-Variable -Name "Delete$rg" -ValueOnly).AddScript($sb).AddArgument($rg)
    New-Variable -Name "jobDelete$rg" -Value ((Get-Variable -Name "Delete$rg" -ValueOnly).BeginInvoke()) 
    If ((Get-Variable -Name "jobDelete$rg" -ValueOnly)) {Write-Host "Job for Deleting resource group $rg - started" -ForegroundColor Green} 
} 
 
#wait for jobs to complete 
$jobsrunning=$true 
while($jobsrunning){ 
    $runningcount=0 
    $runningnames=$null 
 
    foreach ($rg in $rgs){ 
        If(!(Get-Variable -Name "jobDelete$rg" -ValueOnly).IsCompleted){ 
            $runningcount++ 
            [string]$runningnames+="jobDelete$rg, " 
        } 
        Else{ 
            (Get-Variable -Name "Delete$rg" -ValueOnly).EndInvoke((Get-Variable -Name "jobDelete$rg" -ValueOnly)) 
            (Get-Variable -Name "Delete$rg" -ValueOnly).Dispose() 
        } 
    } 
 
    if ($runningcount -gt 0){ 
        Write-Progress -Id "1" -Activity "waiting for jobs" -Status "$runningcount of $($rgs.Count) jobs are still running" -CurrentOperation $runningnames 
    } 
    else{ 
        $jobsrunning=$false 
    } 
 
    start-sleep -Milliseconds 250 
}

#Ref https://blogs.msdn.microsoft.com/mast/2016/06/29/microsoft-azure-how-to-execute-a-synchronous-azure-powershell-cmdlet-multiple-times-at-once-using-a-single-powershell-session/ 
