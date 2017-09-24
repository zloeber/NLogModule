function Write-Verbose {
<#
.SYNOPSIS
    Writes text to the verbose message stream.
    
.DESCRIPTION
    The Write-Verbose cmdlet writes text to the verbose message stream in Windows PowerShell. Typically, the verbose message stream is used to deliver information about command processing that is used for debugging a command.
    
    By default, the verbose message stream is not displayed, but you can display it by changing the value of the $VerbosePreference variable or using the Verbose common parameter in any command.
    
.EXAMPLE
    PS C:\>Write-Verbose -Message "Searching the Application Event Log."
    PS C:\>Write-Verbose -Message "Searching the Application Event Log." -verbose
    These commands use the Write-Verbose cmdlet to display a status message. By default, the message is not displayed.
    The second command uses the Verbose common parameter, which displays any verbose messages, regardless of the value of the $VerbosePreference variable.
    
.EXAMPLE
    PS C:\>$VerbosePreference = "Continue"
    PS C:\>Write-Verbose "Copying file $filename"
    These commands use the Write-Verbose cmdlet to display a status message. By default, the message is not displayed.
    The first command assigns a value of "Continue" to the $VerbosePreference preference variable. The default value, "SilentlyContinue", suppresses verbose messages. The second command writes a verbose message.
    
.NOTES
    Verbose messages are returned only when the command uses the Verbose common parameter. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).
    In Windows PowerShell background jobs and remote commands, the $VerbosePreference variable in the job session and remote session determine whether the verbose message is displayed by default. For more information about the $VerbosePreference variable, see about_Preference_Variables (http://go.microsoft.com/fwlink/?LinkID=113248).
    
.INPUTS
    System.String
    
.OUTPUTS
    None
#>


    [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=113429', RemotingCapability='None')]
     param(
         [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
         [Alias('Msg')]
         [AllowEmptyString()]
         [string]
         ${Message})
     
    begin
    {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
         try {
             $outBuffer = $null
             if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
             {
                 $PSBoundParameters['OutBuffer'] = 1
             }
             $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Verbose', [System.Management.Automation.CommandTypes]::Cmdlet)
             $scriptCmd = {& $wrappedCmd @PSBoundParameters }
             $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
             $steppablePipeline.Begin($PSCmdlet)
         } catch {
             throw
         }
     }
     
     process
     {
         try {
             $steppablePipeline.Process($_)
         } catch {
             throw
         }
     }
     
     end
     {
        if ($script:Logger -ne $null) {
            $script:Logger.Info("$Message")
        }
         try {
             $steppablePipeline.End()
         } catch {
             throw
         }
     }
}
