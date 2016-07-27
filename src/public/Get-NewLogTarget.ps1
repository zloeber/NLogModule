function Get-NewLogTarget {
    <#
    .SYNOPSIS
        Creates a new logging target
    .DESCRIPTION
        Logging targets are required to write down the log messages somewhere
    .PARAMETER TargetType
        Type of target to return, Console, file, or mail are supported.
    .EXAMPLE
       $myFilelogtarget = Get-NewLogTarget -targetType "file"
    #>
    param (
        [parameter(mandatory=$true)]
        [System.String]$TargetType ) 
    
    switch ($TargetType) {
        "console" {
            New-Object NLog.Targets.ColoredConsoleTarget    
        }
        "file" {
            New-Object NLog.Targets.FileTarget
        }
        "mail" { 
            New-Object NLog.Targets.MailTarget
        }
    }

}