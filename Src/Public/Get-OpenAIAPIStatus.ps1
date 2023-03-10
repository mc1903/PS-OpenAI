Function Get-OpenAIAPIStatus {

    <#
    
    .NOTES
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Module: PS-OpenAI
    Function: Get-OpenAIAPIStatus (GOAIStatus)
    Author:	Martin Cooper (@mc1903)
    Date: 21-01-2023
    GitHub Repo: https://github.com/mc1903/PS-OpenAI
    Version: 1.0.2
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .SYNOPSIS
    This function returns the current OpenAI API status.

    .DESCRIPTION
    This function returns the current OpenAI API status. No API authentication is required.

    .PARAMETER jsonOut
    (Switch)
    (Optional)
    If set the output is returned in Json format, otherwise a PSCustomObject is returned.

    .EXAMPLE
    Get-OpenAIAPIStatus

    #>
    
    [CmdletBinding()]

    [Alias("GOAIStatus")]

    Param (
        [Parameter(
            Position = 0,
            Mandatory = $false
        )]
        [Switch] $jsonOut
    )

    [uri]$url = "https://status.openai.com/api/v2/status.json"

    $headers = @{
        "Content-Type"        = "application/json"
    }

    Try {
        $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
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

