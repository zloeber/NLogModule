function Get-NewLogConfig {
    <#
    .SYNOPSIS
        Creates a new configuration in memory
    .DESCRIPTION
        Important to add logging behaviour and log targets to your LogManager
    .EXAMPLE
       $myLogconfig = Get-NewLogConfig()
    #>
    New-Object NLog.Config.LoggingConfiguration 
}