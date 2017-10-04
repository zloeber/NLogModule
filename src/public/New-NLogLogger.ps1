function New-NLogLogger {
    <#
    .SYNOPSIS
    Creates a new LogManager instance
    .DESCRIPTION
    Important to log messages to file, mail, console etc.
    .EXAMPLE
    $myLogger = New-NLogLogger
    .PARAMETER LoggerName
    Name of the logger to get
    #>
    param (
        [parameter(mandatory=$true)] 
        [System.String]$LoggerName
    ) 
    
    [NLog.LogManager]::GetLogger($loggerName)
}
