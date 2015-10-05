function Get-NewLogger {
    <#
    .SYNOPSIS
        Creates a new LogManager instance
    .DESCRIPTION
        Important to log messages to file, mail, console etc.
    .EXAMPLE
       $myLogger = Get-NewLogger()
    #>
    param ( [parameter(mandatory=$true)] [System.String]$loggerName ) 
    
    [NLog.LogManager]::GetLogger($loggerName) 
}