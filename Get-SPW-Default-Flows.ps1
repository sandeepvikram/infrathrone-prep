Power Automate – Extracting Last Run Date & Status via PowerShell
1. Objective

Extract the latest run date/time and run status for Power Automate flows using PowerShell, starting with the SPW Online (default) environment, and export the results to an Excel-compatible format.

Primary requirement:

Last run start time

Last run status

Secondary (best-effort):

Flow name

Flow ID

Owner identifier

2. Scope

Environment: SPW Online (default) (initial implementation)

Tooling: Power Platform PowerShell

Output: CSV file (Excel-compatible)

Out of scope:

Historical run analysis

Deep flow configuration analysis

Owner name/email resolution (objectId only unless Graph access is approved)

3. Preconditions / Setup

Before running the script, ensure:

Required Power Platform admin role is activated via PIM

PowerShell is opened as Administrator

Authentication to Power Platform is completed using:

Add-PowerAppsAccount


PowerShell module available:

Microsoft.PowerApps.Administration.PowerShell

Get-FlowRun cmdlet is available in the active session

4. Approach Overview

Power Automate flow metadata and flow run history are retrieved via separate APIs.

Get-AdminFlow
→ Retrieves flow inventory and metadata
→ Does not include run history

Get-FlowRun
→ Retrieves run history for a specific flow
→ Required to obtain last run date and status

Therefore, the solution follows this model:

Retrieve all flows using Get-AdminFlow

For each flow:

Query run history using Get-FlowRun

Select the most recent run

Merge results and export to CSV

5. Execution Steps
Step 1: Identify the environment
Get-AdminPowerAppEnvironment | Select DisplayName, EnvironmentName


Store the EnvironmentName (GUID) for reuse.

Step 2: Retrieve flow inventory
$flows = Get-AdminFlow -EnvironmentName $envId


This returns:

Flow display name

Flow ID

Creation metadata

State

Note: No run information is included at this stage.

Step 3: Validate run history retrieval (single flow)
Get-FlowRun -EnvironmentName $envId -FlowName <FlowId> |
Sort-Object StartTime -Descending |
Select-Object -First 1


Fields used:

StartTime

Status

Step 4: Validate against Power Automate UI

Compared PowerShell StartTime with Power Automate UI (28-day run history)

Confirmed timestamps match

Z suffix indicates UTC (aligns with UK time during January)

Step 5: Full export logic

For each flow:

Call Get-FlowRun

Extract the most recent run

Handle edge cases:

Flows that have never run

Flows with restricted run history access

Export results to CSV

6. Script Behaviour (Important)

One Get-FlowRun call is made per flow

Execution time increases linearly with number of flows

This is expected and unavoidable due to API design

7. Data Mapping
Column	Source
FlowName	Get-AdminFlow.DisplayName
FlowId	Get-AdminFlow.FlowName
LastRunDateTime	Get-FlowRun.StartTime
LastRunStatus	Get-FlowRun.Status
Owner	CreatedBy.objectId (best available)
8. Known Limitations

Flows that have never run will not return a last run timestamp

Some flows may not expose run history due to permission scope

Owner is returned as objectId, not display name/email

Script execution can be slow for large environments

These are platform-level constraints.

9. Output

Format: CSV (Excel-compatible)

Location: User Documents folder

Filename: Timestamped to avoid overwrite

One row per flow, containing latest run information

10. Summary

Flow inventory retrieved via Get-AdminFlow

Last run data retrieved via Get-FlowRun

Results validated against Power Automate UI

Output exported for reporting and migration analysis

Approach is repeatable across Dev / UAT / Prod by switching environment ID
