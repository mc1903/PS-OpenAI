Function New-OpenAIUser {

    <#
    
    .NOTES
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Module: PS-OpenAI
    Function: New-OpenAIUser (NOAIUser)
    Author:	Martin Cooper (@mc1903)
    Date: 28-01-2023
    GitHub Repo: https://github.com/mc1903/PS-OpenAI
    Version: 1.0.3
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .SYNOPSIS
    This function will create a new OpenAI User invitation

    .DESCRIPTION
    This function will create a new OpenAI User invitation

    .PARAMETER emailAddress
    (Required)
    (String)
    The email address to send the new OpenAI User invitation to 

    .PARAMETER role
    (Required)
    The role the new OpenAI User account will be granted from the following:

        Owner - Can modify billing information and manage organization members
        Reader - Can make standard API requests and read basic organizational data
        Writer - Can make API requests that read or modify data (** USE WITH CAUTION AS THIS ROLE IS NOT EXPOSED IN THE WEB UI **)

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
    New-OpenAIUser -emailAddress "user@example.com" -role Reader

    #>
    
    [CmdletBinding()]

    [Alias("NOAIUser")]

    Param (
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$")]
        [String] $emailAddress,

        [Parameter(
            Position = 1,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Owner", "Reader", "Writer")]
        [String] $role,

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

    [uri]$url = "https://api.openai.com/v1/organizations/$orgID/invite_request"

    Write-Verbose "APIKey is $(Hide-String -string $apiKey -percent 75)"

    $headers = @{
        "Content-Type"        = "application/json"
        "Authorization"       = "Bearer $apiKey"
        "OpenAI-Organization" = "$orgID"
    }

    $body = @{
        emails = @($emailAddress)
        role   = $role.ToLower()
    }
    $body = $body | ConvertTo-Json -Depth 10
    $body = [System.Text.Encoding]::UTF8.GetBytes($body)

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

