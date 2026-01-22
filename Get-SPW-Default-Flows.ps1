# ==============================
# CONFIG
# ==============================
$EnvironmentName = "Default-fb353110-fd2c-4931-b319-e33eba81ef34"
$EnvironmentLabel = "SPW Online (default)"
$OutputPath = "$env:USERPROFILE\Documents\SPW_Default_Flow_Report.csv"

# ==============================
# AUTH & MODULE
# ==============================
Import-Module Microsoft.PowerApps.Administration.PowerShell
Add-PowerAppsAccount

# ==============================
# GET FLOWS
# ==============================
Write-Host "Fetching flows from $EnvironmentLabel ..." -ForegroundColor Cyan

$flows = Get-AdminFlow -EnvironmentName $EnvironmentName

# ==============================
# BUILD REPORT
# ==============================
$results = foreach ($f in $flows) {
    [PSCustomObject]@{
        Environment        = $EnvironmentLabel
        FlowName           = $f.DisplayName
        FlowId             = $f.FlowName
        State              = $f.State
        Owner              = $f.CreatedBy.displayName
        CreatedTime        = $f.CreatedTime
        LastRunDateTime    = ""     # Not available via PowerShell in this tenant
        LastRunStatus      = ""     # To be populated from Admin Center UI if needed
        Notes              = "Last run to be confirmed via PPAC UI"
    }
}

# ==============================
# EXPORT
# ==============================
$results |
Sort-Object FlowName |
Export-Csv $OutputPath -NoTypeInformation -Encoding UTF8

Write-Host "Export completed:" -ForegroundColor Green
Write-Host $OutputPath -ForegroundColor Yellow
