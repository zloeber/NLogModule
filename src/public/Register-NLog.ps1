function Register-NLog {
    <#
    .SYNOPSIS
        Register the NLog dlls and create a file logging target.        
    .DESCRIPTION
        Register the NLog dlls and create a file logging target.
    .PARAMETER FileName
        File to start logging to
    .PARAMETER loggername
        An Nlog name (useful for multiple logging targets)
    .EXAMPLE
        Register-NLog -FileName C:\temp\testlogger.log
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string]$FileName,
        [Parameter()]
        [string]$LoggerName = 'TestLogger'
        
    )
    if ($Script:Logger -eq $null) {
        $debugLog                      = Get-NewLogTarget -targetType "file"
        $debugLog.ArchiveAboveSize     = 10240000
        $debugLog.archiveEvery         = "Month"
        $debugLog.ArchiveNumbering     = "Rolling"    
        $debugLog.CreateDirs           = $true    
        $debugLog.FileName             = $FileName
        $debugLog.Encoding             = [System.Text.Encoding]::GetEncoding("iso-8859-2")
        $debugLog.KeepFileOpen         = $false
        $debugLog.Layout               = Get-LogMessageLayout -layoutId 1    
        $debugLog.maxArchiveFiles      = 1
        
        $Script:NLogConfig.AddTarget("file", $debugLog)
        
        $rule1 = New-Object NLog.Config.LoggingRule("*", [NLog.LogLevel]::Debug, $debugLog)
        $Script:NLogConfig.LoggingRules.Add($rule1)

        # Assign configured Log config to LogManager
        [NLog.LogManager]::Configuration = $Script:NLogConfig

        # Create a new Logger
        $Script:Logger = Get-NewLogger -loggerName $LoggerName
    }
    else {
        Write-Warning 'NlogModule: You must first run UnRegister-NLog!'
    }
}