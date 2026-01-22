# ==============================
# CONFIG
# ==============================
$envId    = "Default-fb353110-fd2c-4931-b319-e33eba81ef34"
$envLabel = "SPW Online (default)"
$outPath  = "$env:USERPROFILE\Documents\SPW_Flows_LastRun.csv"

# ==============================
# MODULE + LOGIN
# ==============================
Import-Module Microsoft.PowerApps.Administration.PowerShell
# If Get-FlowRun is available in your session already, keep going.
# If not, you may need to Import-Module for the module that provides it.

Add-PowerAppsAccount

# ==============================
# GET FLOWS
# ==============================
Write-Host "Fetching flows from $envLabel..." -ForegroundColor Cyan
$flows = Get-AdminFlow -EnvironmentName $envId

# ==============================
# BUILD REPORT
# ==============================
$results = foreach ($f in $flows) {

    $lastRunTime = $null
    $lastRunStatus = $null
    $lastRunNote = ""

    try {
        # Get newest run
        $r = Get-FlowRun -EnvironmentName $envId -FlowName $f.FlowName |
             Sort-Object StartTime -Descending |
             Select-Object -First 1

        if ($null -ne $r) {
            $lastRunTime   = $r.StartTime
            $lastRunStatus = $r.Status
        } else {
            $lastRunNote = "NEVER_RAN_OR_NO_RUNS_RETURNED"
        }
    }
    catch {
        $lastRunNote = "NO_ACCESS_OR_RUN_HISTORY_ERROR"
    }

    # Owner handling:
    # Best effort: try to get display name / UPN if present; otherwise use objectId
    $owner = $null
    if ($f.CreatedBy -and $f.CreatedBy.userPrincipalName) {
        $owner = $f.CreatedBy.userPrincipalName
    } elseif ($f.CreatedBy -and $f.CreatedBy.displayName) {
        $owner = $f.CreatedBy.displayName
    } elseif ($f.CreatedBy -and $f.CreatedBy.objectId) {
        $owner = $f.CreatedBy.objectId
    } else {
        $owner = "UNKNOWN"
    }

    [PSCustomObject]@{
        Environment     = $envLabel
        FlowName        = $f.DisplayName
        FlowId          = $f.FlowName
        Owner           = $owner
        LastRunDateTime = $lastRunTime
        LastRunStatus   = $lastRunStatus
        Notes           = $lastRunNote
    }
}

# ==============================
# EXPORT
# ==============================
$results |
Sort-Object FlowName |
Export-Csv $outPath -NoTypeInformation -Encoding UTF8

Write-Host "Export completed: $outPath" -ForegroundColor Green
