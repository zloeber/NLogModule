function New-NLogConfig {
    <#
    .SYNOPSIS
        Creates a new configuration in memory
    .DESCRIPTION
        Important to add logging behaviour and log targets to your LogManager
    .EXAMPLE
       $myLogconfig = New-NLogConfig
    #>
    New-Object NLog.Config.LoggingConfiguration 
}
