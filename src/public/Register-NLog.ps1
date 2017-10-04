function Register-NLog {
    <#
    .SYNOPSIS
    Start NLog logging with a basic configuration.
    .DESCRIPTION
    Start NLog logging with a basic configuration.
    .PARAMETER FileName
    File to start logging to
    .PARAMETER LoggerName
    An Nlog name (useful for multiple logging targets)
    .PARAMETER LogLevel
    Level of logging. Default is Info.
    .PARAMETER Target
    An NLog target (created with New-NLogFileTarget or New-NLogConsoleTarget)
    .EXAMPLE
    Register-NLog -FileName C:\temp\testlogger.log
    #>
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [Parameter(Mandatory = $True, ParameterSetName='Default')]
        [string]$FileName,
        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='TargetSupplied')]
        [string]$LoggerName = 'TestLogger',
        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='TargetSupplied')]
        [NLog.LogLevel]$LogLevel = [NLog.LogLevel]::Debug,
        [Parameter(Mandatory = $True, ParameterSetName='TargetSupplied')]
        [object]$Target
    )

    if ($null -eq $Script:Logger) {
        switch ($PsCmdlet.ParameterSetName) {
            'default'  {
                $Target = New-NlogFileTarget -FileName $FileName
                $Script:NLogConfig.AddTarget("file", $Target)
            }
            'TargetSupplied'  {
                switch ($Target.GetType().Name) {
                    'FileTarget' {
                        $Script:NLogConfig.AddTarget("file", $Target)
                    }
                    'ColoredConsoleTarget' {
                        $Script:NLogConfig.AddTarget("console", $Target)
                    }
                    'MailTarget' {
                        $Script:NLogConfig.AddTarget("mail", $Target)
                    }
                }
            }
        }

        $rule1 = New-Object NLog.Config.LoggingRule("*", $LogLevel, $Target)
        $Script:NLogConfig.LoggingRules.Add($rule1)

        # Assign configured Log config to LogManager
        [NLog.LogManager]::Configuration = $Script:NLogConfig

        # Create a new Logger
        $Script:Logger = New-NLogLogger -loggerName $LoggerName
    }
    else {
        Write-Warning 'NlogModule: You must first run UnRegister-NLog!'
    }
}
