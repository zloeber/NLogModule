function Get-NewLogger {
    <#
    .SYNOPSIS
        Creates a new LogManager instance
    .DESCRIPTION
        Important to log messages to file, mail, console etc.
    .EXAMPLE
       $myLogger = Get-NewLogger()
    .PARAMETER LoggerName
        Name of the logger to get
    #>
    param (
        [parameter(mandatory=$true)] 
        [System.String]$LoggerName
    ) 
    
    [NLog.LogManager]::GetLogger($loggerName) 
}
