Function Find-InviteId {

    <#
    
    .NOTES
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Module: PS-OpenAI
    Function: Find-InviteId
    Author:	Martin Cooper (@mc1903)
    Date: 28-01-2023
    GitHub Repo: https://github.com/mc1903/PS-OpenAI
    Version: 1.0.1
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .SYNOPSIS
    This function will find the InviteID for a OpenAI User account invitation

    .DESCRIPTION
    This function will find the InviteID for a OpenAI User account invitation

    .PARAMETER emailAddress
    (Required)
    (String)
     The email address of the OpenAI User account invitation you want to find the InviteID for.

    .EXAMPLE
    Find-InviteId -emailAddress "user@example.com"

    #>

    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$")]
        [String] $emailAddress
    )

    $users = Get-OpenAIUsers
    
    Foreach ($invite in $users.invited) {
        If ($invite.email -eq $emailAddress) {
            Return $invite.id
        }
    }

}

