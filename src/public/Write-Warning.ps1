Function Write-Warning {
<#
.SYNOPSIS
    Writes a warning message.
    
.DESCRIPTION
    The Write-Warning cmdlet writes a warning message to the Windows PowerShell host. The response to the warning depends on the value of the user's $WarningPreference variable and the use of the WarningAction common parameter.
    
.EXAMPLE
    PS C:\>write-warning "This is only a test warning."
    This command displays the message "WARNING: This is only a test warning."
    
.EXAMPLE
    PS C:\>$w = "This is only a test warning."
    PS C:\>$w | write-warning
    This example shows that you can use a pipeline operator (|) to send a string to Write-Warning. You can save the string in a variable, as shown in this command, or pipe the string directly to Write-Warning.
    
.EXAMPLE
    PS C:\>$warningpreference
    Continue
    
    PS C:\>write-warning "This is only a test warning."
    This is only a test warning.
    
    PS C:\>$warningpreference = "SilentlyContinue"
    PS C:\>write-warning "This is only a test warning."
    PS C:\>
    PS C:\>$warningpreference = "Stop"
    PS C:\>write-warning "This is only a test warning."
    
    WARNING: This is only a test message.
    Write-Warning : Command execution stopped because the shell variable "WarningPreference" is set to Stop.
    At line:1 char:14
    + write-warning <<<<  "This is only a test message."
    This example shows the effect of the value of the $WarningPreference variable on a Write-Warning command.
    The first command displays the default value of the $WarningPreference variable, which is "Continue". As a result, when you write a warning, the warning message is displayed and execution continues.
    When you change the value of the $WarningPreference variable, the effect of the Write-Warning command changes again. A value of "SilentlyContinue" suppresses the warning. A value of "Stop" displays the warning and then stops execution of the command.
    For more information about the $WarningPreference variable, see about_Preference_Variables.
    
.EXAMPLE
    PS C:\>write-warning "This is only a test warning." -warningaction Inquire
    
    WARNING: This is only a test warning.
    Confirm
    Continue with this operation?
    [Y] Yes  [A] Yes to All  [H] Halt Command  [S] Suspend  [?] Help (default is "Y"):
    This example shows the effect of the WarningAction common parameter on a Write-Warning command. You can use the WarningAction common parameter with any cmdlet to determine how Windows PowerShell responds to warnings resulting from that command. The WarningAction common parameter overrides the value of the $WarningPreference only for that particular command.
    This command uses the Write-Warning cmdlet to display a warning. The WarningAction common parameter with a value of "Inquire" directs the system to prompt the user when the command displays a warning.
    For more information about the WarningAction common parameter, see about_CommonParameters.
    
.NOTES
    The default value for the $WarningPreference variable is "Continue", which displays the warning and then continues executing the command. To determine valid values for a preference variable such as $WarningPreference, set it to a string of random characters, such as "abc". The resulting error message will list the valid values.
    
.INPUTS
    System.String
    
.OUTPUTS
    None
    
.LINK
    http://go.microsoft.com/fwlink/p/?linkid=294033
    
.LINK
    Online Version:
    
.LINK
    Write-Debug
    
.LINK
    Write-Error
    
.LINK
    Write-Host
    
.LINK
    Write-Output
    
.LINK
    Write-Progress
    
.LINK
    Write-Verbose
    
.LINK
    about_CommonParameters
    
.LINK
    about_Preference_Variables
#>


    [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=113430', RemotingCapability='None')]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Alias('Msg')]
        [AllowEmptyString()]
        [string]${Message}
    )
     
    begin
    {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Warning', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } 
        catch {
            throw
        }
    }
     
    process
    {
        try {
            $steppablePipeline.Process($_)
        }
        catch {
            throw
        }
    }
     
    end {
        if ($script:Logger -ne $null) {
            $script:Logger.Warn("$Message")
        }
        try {
            $steppablePipeline.End()
        }
        catch {
            throw
        }
    }
}