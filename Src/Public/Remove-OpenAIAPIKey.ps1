Function Remove-OpenAIAPIKey {
    
    <#
    
    .NOTES
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Module: PS-OpenAI
    Function: New-OpenAIAPIKey (ROAIKey)
    Author:	Martin Cooper (@mc1903)
    Date: 28-01-2023
    GitHub Repo: https://github.com/mc1903/PS-OpenAI
    Version: 1.0.1
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .SYNOPSIS
    This function will delete an existing OpenAI API Key.

    .DESCRIPTION
    This function will delete an existing new OpenAI API Key.

    .PARAMETER deleteApiKey
    (String)
    The redacted API key string

    .PARAMETER deleteApiKeyCreated
    (String)
    The epoch date the redacted API key was created

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
    Remove-OpenAIAPIKey -deleteApiKey "sk-GyUdg***************************************qYiA" -deleteApiKeyCreated 1674993434 -jsonOut -Verbose

    #>
    
    [CmdletBinding()]

    [Alias("ROAIKey")]

    Param (
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String] $deleteApiKey,

        [Parameter(
            Position = 1,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [Int] $deleteApiKeyCreated,

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

    [uri]$url = "https://api.openai.com/dashboard/user/api_keys"

    Write-Verbose "APIKey is $(Hide-String -string $apiKey -percent 75)"

    $body = [Ordered]@{
        action = 'delete'
        redacted_key = "$deleteApiKey"
        created_at = $deleteApiKeyCreated
    }
    $body = $body | ConvertTo-Json -Depth 10
    $body = [System.Text.Encoding]::UTF8.GetBytes($body)

    $headers = @{
        "Content-Type"        = "application/json"
        "Authorization"       = "Bearer $apiKey"
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

