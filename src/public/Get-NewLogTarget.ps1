function Get-NewLogTarget {
    <#
    .SYNOPSIS
        Creates a new logging target
    .DESCRIPTION
        Logging targets are required to write down the log messages somewhere
    .EXAMPLE
       $myFilelogtarget = Get-NewLogTarget -targetType "file"
    #>
    param ( [parameter(mandatory=$true)] [System.String]$targetType ) 
    
    switch ($targetType) {
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