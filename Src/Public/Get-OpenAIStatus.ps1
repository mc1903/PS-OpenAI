Function Get-OpenAIStatus {

    <#
    
    .NOTES
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Module: PS-OpenAI
    Function: Get-OpenAIStatus (GOAIStatus)
    Author:	Martin Cooper (@mc1903)
    Date: 18-02-2023
    GitHub Repo: https://github.com/mc1903/PS-OpenAI
    Version: 1.1.7
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .SYNOPSIS
    This function returns the current OpenAI status, from their Atlassian™ Statuspage.
    
        Interactive - https://status.openai.com/
        API Documentation - https://status.openai.com/api/v2

    .DESCRIPTION
    This function returns the current OpenAI status including overall platform status, per component summary, any incidents and any scheduled maintenace* events.
    
        * It is not clear if OpenAI are using the scheduled maintenance feature at this time.   
    
    The Atlassian™ Statuspage API endpoint is public and does NOT require any authentication

    .PARAMETER status
    (Switch)
    (Optional / Default)
    Will return the overall status.
 
    .PARAMETER summary
    (Switch)
    (Optional)
    Will return the status of each components as well as the overall status.

    .PARAMETER incidents
    (List - all, investigating, identified, monitoring, postmortem, resolved or unresolved)
    (Optional)
    Will return upto the last 50 incidents.
    Unresolved will return investigating, identified & monitoring incidents

    .PARAMETER maintenances
    (List - all, active, completed, in_progress, scheduled, verify)
    (Optional)
    Will return upto the last 50 maintenance events.

    .PARAMETER jsonOut
    (Switch)
    (Optional)
    If set the output is returned in Json format, otherwise a PSCustomObject is returned.

    .EXAMPLE
    Get-OpenAIStatus

    #>
    
    [CmdletBinding(DefaultParameterSetName = 'Status')]

    [Alias("GOAIStatus")]
    [Alias("Get-OpenAIAPIStatus")] # Deprecating the former function name. Will be removed.

    Param (
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'Status'
        )]
        [Switch]$status,

        [Parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'Summary'
        )]
        [Switch]$summary,

        [Parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'Incidents'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("all", "investigating", "identified", "monitoring", "postmortem", "resolved", "unresolved")]
        [String]$incidents,

        [Parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'Maintenances'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("all", "active", "completed", "in_progress", "scheduled", "verify")]
        [String]$maintenances,

        [Parameter(
            Position = 1,
            Mandatory = $false
        )]
        [Switch] $jsonOut
    )

    If ($MyInvocation.InvocationName -eq 'Get-OpenAIAPIStatus') {
        Write-Warning -Verbose "The function name 'Get-OpenAIAPIStatus' has been deprecated and will be removed in a future version. Please use 'Get-OpenAIStatus' instead."
    }

    [uri]$baseurl = "https://status.openai.com"

    If ($PSCmdlet.ParameterSetName -eq 'Summary') {
        [string]$uri = "api/v2/summary.json"
    }
    ElseIf ($PSCmdlet.ParameterSetName -eq 'Incidents') {
        If ($incidents -eq "unresolved") {
            [string]$uri = "api/v2/incidents/unresolved.json"
        }
        Else {
            [string]$uri = "api/v2/incidents.json"
        }
    }
    ElseIf ($PSCmdlet.ParameterSetName -eq 'Maintenances') {
        If ($maintenances -eq "scheduled") {
            [string]$uri = "api/v2/scheduled-maintenances/upcoming.json"
        }
        ElseIf ($maintenances -eq "active" -or $maintenances -eq "inprogress" -or $maintenances -eq "verify") {
            [string]$uri = "api/v2/scheduled-maintenances/active.json"
        }
        Else {
            [string]$uri = "api/v2/scheduled-maintenances.json"
        }
    }
    Else {
        [string]$uri = "api/v2/status.json"
    }

    $headers = @{
        "Content-Type" = "application/json"
    }

    Try {
        $response = Invoke-RestMethod -Method Get -Uri "$($baseurl)$($uri)" -Headers $headers
    }
    Catch {
        $response = $_ | ConvertFrom-Json
    }

    If ($PSCmdlet.ParameterSetName -eq 'Incidents') {
        If ($incidents -ne "all" -and $incidents -ne "unresolved") {
            $objPage = $response.page
            $objIncidents = $response.incidents | Where-Object { $_.status -eq $incidents }
            $response = [PSCustomObject]@{
                page      = $objPage
                incidents = @($objIncidents)
            }
        }
    }

    If ($PSCmdlet.ParameterSetName -eq 'Maintenances') {
        If ($maintenances -ne "all" -and $maintenances -ne "active" -and $maintenances -ne "scheduled") {
            $objPage = $response.page
            $objSchedMaint = $response.scheduled_maintenances | Where-Object { $_.status -eq $maintenances }
            $response = [PSCustomObject]@{
                page                   = $objPage
                scheduled_maintenances = @($objSchedMaint)
            }
        }
    }

    If ($jsonOut) {
        Return $response | ConvertTo-Json -Depth 20
    }
    Else {
        Return $response
    } 
}

