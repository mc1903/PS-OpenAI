Function Find-UserId {

    <#
    
    .NOTES
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Module: PS-OpenAI
    Function: Find-UserId
    Author:	Martin Cooper (@mc1903)
    Date: 28-01-2023
    GitHub Repo: https://github.com/mc1903/PS-OpenAI
    Version: 1.0.1
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .SYNOPSIS
    This function will find the UserId for a OpenAI User account

    .DESCRIPTION
    This function will find the UserId for a OpenAI User account 

    .PARAMETER emailAddress
    (Required)
    (String)
    The email address of the OpenAI User account you want to find the UserId for.

    .EXAMPLE
    Find-UserId -emailAddress "user@example.com"

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
    
    Foreach ($user in $users.members.data) {
        If ($user.user.email -eq $emailAddress) {
            Return $user.user.id
        }
    }

}

