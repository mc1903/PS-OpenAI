Function Get-OpenAIBilling {
    
    <#
    
    .NOTES
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Module: PS-OpenAI
    Function: Get-OpenAIBilling (GOAIBills)
    Author:	Martin Cooper (@mc1903)
    Date: 21-01-2023
    GitHub Repo: https://github.com/mc1903/PS-OpenAI
    Version: 1.0.3
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .SYNOPSIS
    This function will return the OpenAI billing data for a range of dates.

    .DESCRIPTION
    This function will return the OpenAI billing data for a range of dates.

    .PARAMETER today
    (Switch)
    (Optional / Default)
    Will return billing data for today.

    .PARAMETER yesterday
    (Switch)
    (Optional)
    Will return billing data for yesterday.

    .PARAMETER thisWeek
    (Switch)
    (Optional)
    Will return billing data for this week.

    .PARAMETER lastWeek
    (Switch)
    (Optional)
    Will return billing data for last week.

    .PARAMETER thisMonth
    (Switch)
    (Optional)
    Will return billing data for this month.

    .PARAMETER lastMonth
    (Switch)
    (Optional)
    Will return billing data for last month.

    .PARAMETER startDate
    (DateTime)
    (Required)
    The start date you want to return billing data from (yyyy-MM-dd).

    .PARAMETER endDate
    (DateTime)
    (Required)
    The end date you want to return billing data up to (yyyy-MM-dd).

    .PARAMETER apiKey
    (String)
    If the OpenAI API Key has been set using the environment variable $env:OpenAIApiKey, then providing it here is not necessary.

    .PARAMETER orgID
    (String)
    If the OpenAI Organisation ID has been set using the environment variable $env:OpenAIOrgID, then providing it here is not necessary.

    .PARAMETER jsonOut
    (Switch)
    If set the output is returned in Json format, otherwise a PSCustomObject is returned.

    .EXAMPLE
    Get-OpenAIBilling

    #>
    
    [CmdletBinding(DefaultParameterSetName = 'Today')]

    [Alias("GOAIBills")]
    
    Param (
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'Today'
        )]
        [Switch]$today,

        [Parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'Yesterday'
        )]
        [Switch]$yesterday,

        [Parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'ThisWeek'
        )]
        [Switch]$thisWeek,

        [Parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'LastWeek'
        )]
        [Switch]$lastWeek,

        [Parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'ThisMonth'
        )]
        [Switch]$thisMonth,

        [Parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'LastMonth'
        )]
        [Switch]$lastMonth,

        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = 'CustomRange'
        )]
        [ValidateNotNullOrEmpty()]
        [Datetime] $startDate,

        [Parameter(
            Position = 1,
            Mandatory = $true,
            ParameterSetName = 'CustomRange'
        )]
        [ValidateNotNullOrEmpty()]
        [Datetime] $endDate,

        [Parameter(
            Position = 2,
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [String] $apiKey = $env:OpenAIApiKey,
 
        [Parameter(
            Position = 3,
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [String] $orgID = $env:OpenAIOrgID,

        [Parameter(
            Position = 4,
            Mandatory = $false
        )]
        [Switch] $jsonOut
    )

    If ([String]::IsNullOrEmpty($apiKey)) {
        Throw 'Please supply your OpenAI API Key as either the $env:OpenAIApiKey environment variable or by specifying the -apiKey parameter'
    }

    If ([String]::IsNullOrEmpty($orgID)) {
        Throw 'Please supply your OpenAI Organisation ID as either the $env:OpenAIOrgID environment variable or by specifying the -orgID parameter'
    }

    [uri]$url = "https://api.openai.com/dashboard/billing/usage"

    Write-Verbose "ParameterSetName is $($PSCmdlet.ParameterSetName)"

    If ($PSCmdlet.ParameterSetName -eq 'Today') {
        $startDate = (Get-Date).Date
        $endDate = (Get-Date).AddDays(1).Date
    }
    ElseIf ($PSCmdlet.ParameterSetName -eq 'Yesterday') {
        $startDate = (Get-Date).AddDays(-1).Date
        $endDate = (Get-Date).Date
    }
    ElseIf ($PSCmdlet.ParameterSetName -eq 'ThisWeek') {
        $startDate = (Get-Date).AddDays( - ((Get-Date).DayOfWeek)).Date
        $endDate = (Get-Date).AddDays(7 - (Get-Date).DayOfWeek).Date
    }
    ElseIf ($PSCmdlet.ParameterSetName -eq 'LastWeek') {
        $startDate = (Get-Date).AddDays( - ((Get-Date).DayOfWeek + 7)).Date
        $endDate = (Get-Date).AddDays(7 - (Get-Date).DayOfWeek - 7).Date
    }
    ElseIf ($PSCmdlet.ParameterSetName -eq 'ThisMonth') {
        $startDate = (Get-Date).AddDays( - ((Get-Date).Day)).Date
        $endDate = (Get-Date).AddMonths(1).AddDays( - ((Get-Date).Day)).Date
    }
    ElseIf ($PSCmdlet.ParameterSetName -eq 'LastMonth') {
        $startDate = (Get-Date).AddMonths(-1).AddDays( - ((Get-Date).Day)).Date
        $endDate = (Get-Date).AddDays( - ((Get-Date).Day)).Date
    }

    $body = [Ordered]@{
        end_date   = $endDate.ToString("yyyy-MM-dd")
        start_date = $startDate.ToString("yyyy-MM-dd")
    }
    Write-Verbose "End_date is $($body.end_date)"
    Write-Verbose "Start_date is $($body.start_date)"

    $headers = @{
        "Content-Type"        = "application/json"
        "Authorization"       = "Bearer $apiKey"
        "OpenAI-Organization" = "$orgID"
    }

    Write-Verbose "APIKey is $(Hide-String -string $apiKey -percent 75)"

    Try {
        $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers -Body $body
    }
    Catch {
        $response = $_ | ConvertFrom-Json
    }

    If ($jsonOut) {
        Return $response | ConvertTo-Json -Depth 10
    }
    Else {
        Return $response
    }
}

