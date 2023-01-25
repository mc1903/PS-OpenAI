Function Get-OpenAIUsers {

    <#
    
    .NOTES
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Module: PS-OpenAI
    Function: Get-OpenAIUsers (GOAIUsers)
    Author:	Martin Cooper (@mc1903)
    Date: 21-01-2023
    GitHub Repo: https://github.com/mc1903/PS-OpenAI
    Version: 1.0.5
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .SYNOPSIS
    This function will return a list of OpenAI Users.

    .DESCRIPTION
    This function will return a list of OpenAI Users for a given Organisation ID, including their name, email address, role and unique userID

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
    Get-OpenAIUsers

    #>
    
    [CmdletBinding()]

    [Alias("GOAIUsers")]

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

    [uri]$url = "https://api.openai.com/v1/organizations/$orgID/users"

    If ($PSBoundParameters['Verbose']) {
        Write-Verbose "APIKey is $(Hide-String -string $apiKey -percent 75)"
    }

    $headers = @{
        "Content-Type"  = "application/json"
        "Authorization" = "Bearer $apiKey"
        "OpenAI-Organization" = "$orgID"
    }

    $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers

    If ($jsonOut) {
        Return $response | ConvertTo-Json -Depth 10
    }
    Else {
        Return $response
    }
}

