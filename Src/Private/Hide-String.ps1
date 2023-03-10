Function Hide-String {

    <#
    
    .NOTES
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Module: PS-OpenAI
    Function: Hide-String
    Author:	Martin Cooper (@mc1903)
    Date: 21-01-2023
    GitHub Repo: https://github.com/mc1903/PS-OpenAI
    Version: 1.0.1
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .SYNOPSIS
    This function will hides some of the characters in a string.

    .DESCRIPTION
    For a given string, this function will replace characters with a asterisk (*) character. It starts from the middle of the string and works outwards in both direcections.

    .PARAMETER string
    The string to hide
    (Required)

    .PARAMETER percent
    The percentage of the string to hide
    (Required)

    .EXAMPLE
    Hide-string "ABCDEFGHIJKLMNOPQRSTUVWXYZ" -percent 60

    Will return "ABCDE****************VWXYZ"

    #>

    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String] $string,

        [Parameter(
            Position = 1,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 100)]
        [Int] $percent
    )

    $length = [Math]::Round($string.Length * $percent / 100)
    $leftPart = $string.Substring(0, [int]($string.Length / 2) - [int]($length / 2))
    $rightPart = $string.Substring([int]($string.Length / 2) + [int]($length / 2))
    $hiddenstring = $leftPart + ("*" * $length) + $rightPart
    return [String]$hiddenstring

}

