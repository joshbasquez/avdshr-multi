# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}
$sites = @("A","B")

$sessionHostParametersA = Get-FunctionConfig _SessionHostParametersA #contains region, subnet
$sessionHostParametersB = Get-FunctionConfig _SessionHostParametersB
$sessionHostNamePrefixA = Get-FunctionConfig _SessionHostNamePrefixA
$sessionHostNamePrefixB = Get-FunctionConfig _SessionHostNamePrefixB
$sessionHostResourceGroupNameA = Get-FunctionConfig _SessionHostResourceGroupNameA
$sessionHostResourceGroupNameB = Get-FunctionConfig _SessionHostResourceGroupNameB

foreach($site in $sites){ #iterate for each site in the hostpool/function app
 if($site = "A"){
            $sessionHostResourceGroupName = Get-FunctionConfig _SessionHostResourceGroupNameA
            $sessionHostParameters = Get-FunctionConfig _SessionHostParametersA #contains region, subnet
            $sessionHostNamePrefix = Get-FunctionConfig _SessionHostNamePrefixA
        }
 else { #else output for siteB
            $sessionHostResourceGroupName = Get-FunctionConfig _SessionHostResourceGroupNameB
            $sessionHostParameters = Get-FunctionConfig _SessionHostParametersB
            $sessionHostNamePrefix = Get-FunctionConfig _SessionHostNamePrefixB
        }

Write-PSFMessage -Level Host -Message "Checking session hosts in site {0}" -StringValues $site
Write-PSFMessage -Level Host -Message "Using resource group {0} for session hosts" -StringValues $sessionHostResourceGroupName
Write-PSFMessage -Level Host -Message "Using prefix {0} for session hosts" -StringValues $sessionHostNamePrefix
Write-PSFMessage -Level Host -Message "Using Parameters for session hosts: `n{0}" -StringValues $sessionHostParameters

<# Comment out Logic while tuning params

        # Decide which Resource groups to use for Session Hosts
        $hostPoolResourceGroupName = Get-FunctionConfig _HostPoolResourceGroupName
            # 
            if($site = "A"){
            $sessionHostResourceGroupName = Get-FunctionConfig _SessionHostResourceGroupNameA
            }
            else {$sessionHostResourceGroupName = Get-FunctionConfig _SessionHostResourceGroupNameB
            }
        Write-PSFMessage -Level Host -Message "Using resource group {0} for session hosts" -StringValues $sessionHostResourceGroupName

        # Get session hosts and update tags if needed.
        $sessionHosts = Get-SHRSessionHost -FixSessionHostTags:(Get-FunctionConfig _FixSessionHostTags) -
        Write-PSFMessage -Level Host -Message "Found {0} session hosts" -StringValues $sessionHosts.Count

        # Filter to Session hosts that are included in auto replace
        $sessionHostsFiltered = $sessionHosts | Where-Object { $_.IncludeInAutomation }
        Write-PSFMessage -Level Host -Message "Filtered to {0} session hosts enabled for automatic replacement: {1}" -StringValues $sessionHostsFiltered.Count, ($sessionHostsFiltered.VMName -join ',')

        # Get running deployments, if any
        $runningDeployments = Get-SHRRunningDeployment -ResourceGroupName $sessionHostResourceGroupName
        Write-PSFMessage -Level Host -Message "Found {0} running deployments" -StringValues $runningDeployments.Count

        # load session host parameters
        $sessionHostParameters = (Get-FunctionConfig _SessionHostParameters)

        # Get latest version of session host image
        Write-PSFMessage -Level Host -Message "Getting latest image version using Image Reference: {0}" -StringValues ($sessionHostParameters.ImageReference | Out-String)
        $latestImageVersion = Get-SHRLatestImageVersion -ImageReference $sessionHostParameters.ImageReference

        # Get number session hosts to deploy
        $hostPoolDecisions = Get-SHRHostPoolDecision -SessionHosts $sessionHostsFiltered -RunningDeployments $runningDeployments -LatestImageVersion $latestImageVersion

        # Deploy new session hosts
        if ($hostPoolDecisions.PossibleDeploymentsCount -gt 0) {
            Write-PSFMessage -Level Host -Message "We will deploy {0} session hosts" -StringValues $hostPoolDecisions.PossibleDeploymentsCount
            # Deploy session hosts
            $existingSessionHostVMNames = (@($sessionHosts.VMName) + @($hostPoolDecisions.ExistingSessionHostVMNames)) | Sort-Object | Select-Object -Unique

            Deploy-SHRSessionHost -SessionHostResourceGroupName $sessionHostResourceGroupName -NewSessionHostsCount $hostPoolDecisions.PossibleDeploymentsCount -ExistingSessionHostVMNames $existingSessionHostVMNames
        }

        # Delete expired session hosts
        if ($hostPoolDecisions.AllowSessionHostDelete -and $hostPoolDecisions.SessionHostsPendingDelete.Count -gt 0) {
            Write-PSFMessage -Level Host -Message "We will decommission {0} session hosts: {1}" -StringValues $hostPoolDecisions.SessionHostsPendingDelete.Count, ($hostPoolDecisions.SessionHostsPendingDelete.VMName -join ',')
            # Decommission session hosts
            $removeAzureDevice = Get-FunctionConfig _RemoveAzureADDevice
            Remove-SHRSessionHost -SessionHostsPendingDelete $hostPoolDecisions.SessionHostsPendingDelete -RemoveAzureDevice $removeAzureDevice
        }
#>

} #end foreach site in the hostpool



# Write an information log with the current time.
Write-Host "PowerShell timer trigger function finished! TIME: $currentUTCtime"
