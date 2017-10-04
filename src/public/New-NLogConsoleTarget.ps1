function New-NLogConsoleTarget {
    <#
    .SYNOPSIS
    Creates a new console logging target
    .DESCRIPTION
    Creates a new console logging target
    .PARAMETER ErrorStream
    Enable error stream logging
    .PARAMETER Encoding
    File encoding type
    .PARAMETER Layout
    Message layout for logs to the console
    .EXAMPLE
    TBD
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Text.Encoding]$Encoding = [System.Text.Encoding]::GetEncoding("iso-8859-2"),
        [Parameter()]
        [switch]$ErrorStream,
        [Parameter()]
        [string]$Layout = (Get-NLogMessageLayout -layoutId 3)
    )
    
    $LogTarget = New-NLogTarget -targetType 'console'
    $LogTarget.ErrorStream = $ErrorStream
    $LogTarget.Encoding = $Encoding
    $LogTarget.Layout = $Layout

    $LogTarget
}
