Function New-OpenAIAPIKey {
    
    <#
    
    .NOTES
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Module: PS-OpenAI
    Function: New-OpenAIAPIKey (NOAIKey)
    Author:	Martin Cooper (@mc1903)
    Date: 28-01-2023
    GitHub Repo: https://github.com/mc1903/PS-OpenAI
    Version: 1.0.1
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .SYNOPSIS
    This function will create a new OpenAI API Key.

    .DESCRIPTION
    This function will create a new OpenAI API Key. ** THE NEW API KEY IS RETURNED IN PLAIN TEXT **

    .PARAMETER apiKey
    (String)
    If the current OpenAI API Key has been set using the environment variable $env:OpenAIApiKey, then providing it here is not necessary.

    .PARAMETER orgID
    (String)
    If the OpenAI Organisation ID has been set using the environment variable $env:OpenAIOrgID, then providing it here is not necessary.

    .PARAMETER jsonOut
    (Switch)
    If set the output is returned in Json format, otherwise a PSCustomObject is returned.

    .EXAMPLE
    New-OpenAIAPIKey

    #>
    
    [CmdletBinding()]

    [Alias("NOAIKey")]

    Param (
        [Parameter(
            Position = 0,
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [String] $apiKey = $env:OpenAIApiKey,

        [Parameter(
            Position = 1,
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [String] $orgID = $env:OpenAIOrgID,

        [Parameter(
            Position = 2,
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

    [uri]$url = "https://api.openai.com/dashboard/user/api_keys"

    Write-Verbose "APIKey is $(Hide-String -string $apiKey -percent 75)"

    $body = @{
        action = 'create'
    }
    $body = $body | ConvertTo-Json -Depth 10
    $body = [System.Text.Encoding]::UTF8.GetBytes($body)

    $headers = @{
        "Content-Type"  = "application/json"
        "Authorization" = "Bearer $apiKey"
        "OpenAI-Organization" = "$orgID"
    }

    Try {
        $response = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body
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

