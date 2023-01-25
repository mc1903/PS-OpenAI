Function Get-OpenAIUsage {
   
    <#
    
    .NOTES
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Module: PS-OpenAI
    Function: Get-OpenAIUsage (GOAIUsage)
    Author:	Martin Cooper (@mc1903)
    Date: 21-01-2023
    GitHub Repo: https://github.com/mc1903/PS-OpenAI
    Version: 1.0.4
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .SYNOPSIS
    This function will return the OpenAI usage for a date or range of dates.

    .DESCRIPTION
    This function will return the OpenAI usage for a date or range of dates. If an userID is specified, only data for that user will be returned.

    .PARAMETER startDate
    (DateTime)
    (Required)
    The date/day or start date you want to return usage data from.

    .PARAMETER endDate
    (DateTime)
    (Optional)
    The end date you want to return usage data up to.

    .PARAMETER userID
    (String)
    (Optional)
    The public user ID for user specific usage data.

    .PARAMETER apiKey
    (String)
    If the OpenAI API Key has been set using the environment variable $env:OpenAIApiKey, then providing it here is not necessary.

    .PARAMETER orgID
    (String)
    If the OpenAI Organisation ID has been set using the environment variable $env:OpenAIApiKey, then providing it here is not necessary.

    .PARAMETER jsonOut
    (Switch)
    If set the output is returned in Json format, otherwise a PSCustomObject is returned.

    .EXAMPLE
    Get-OpenAIUsage

    #>
    
    [CmdletBinding()]

    [Alias("GOAIUsage")]

    Param (
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [Datetime] $startDate,

        [Parameter(
            Position = 1,
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [Datetime] $endDate,

        [Parameter(
            Position = 2,
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [String] $userID,

        [Parameter(
            Position = 3,
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [String] $apiKey = $env:OpenAIApiKey,
 
        [Parameter(
            Position = 4,
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [String] $orgID = $env:OpenAIOrgID,

        [Parameter(
            Position = 5,
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

    [uri]$url = "https://api.openai.com/v1/usage"

    If ($startDate -ne $null -and $EndDate -ne $null) {
        $body = [Ordered]@{
            end_date   = $endDate.ToString("yyyy-MM-dd")
            start_date = $startDate.ToString("yyyy-MM-dd")
        }
    }
    else {
        $body = [Ordered]@{
            date = $startDate.ToString("yyyy-MM-dd")
        }
    }

    If ($userID) {
        $body += [Ordered]@{
            user_public_id = $userID
        }

    }

    $headers = @{
        "Content-Type"        = "application/json"
        "Authorization"       = "Bearer $apiKey"
        "OpenAI-Organization" = "$orgID"
    }

    If ($PSBoundParameters['Verbose']) {
        Write-Verbose "APIKey is $(Hide-String -string $apiKey -percent 75)"
    }

    $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers -Body $body

    If ($jsonOut) {
        Return $response | ConvertTo-Json -Depth 10
    }
    Else {
        Return $response
    }
}

