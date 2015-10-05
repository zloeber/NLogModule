Function Write-Output {
<#
.SYNOPSIS
    Sends the specified objects to the next command in the pipeline. If the command is the last command in the pipeline, the objects are displayed in the console.
    
.DESCRIPTION
    The Write-Output cmdlet sends the specified object down the pipeline to the next command. If the command is the last command in the pipeline, the object is displayed in the console.
    
    Write-Output sends objects down the primary pipeline, also known as the "output stream" or the "success pipeline." To send error objects down the error pipeline, use Write-Error.
    
    This cmdlet is typically used in scripts to display strings and other objects on the console. However, because the default behavior is to display the objects at the end of a pipeline, it is generally not necessary to use the cmdlet. For example, "get-process | write-output" is equivalent to "get-process".
    
.PARAMETER InputObject
    Specifies the objects to send down the pipeline. Enter a variable that contains the objects, or type a command or expression that gets the objects.
    
.PARAMETER NoEnumerate
    By default, the Write-Output cmdlet always enumerates its output. The NoEnumerate parameter suppresses the default behavior, and prevents Write-Output from enumerating output. The NoEnumerate parameter has no effect on collections that were created by wrapping commands in parentheses, because the parentheses force enumeration.
    
.EXAMPLE
    PS C:\>$p = get-process
    PS C:\>write-output $p
    PS C:\>$p
    These commands get objects representing the processes running on the computer and display the objects on the console.
    
.EXAMPLE
    PS C:\>write-output "test output" | get-member
    This command pipes the "test output" string to the Get-Member cmdlet, which displays the members of the String class, demonstrating that the string was passed along the pipeline.
    
.EXAMPLE
    PS C:\>write-output @(1,2,3) | measure
    
    Count    : 3
...
    PS C:\>write-output @(1,2,3) -NoEnumerate | measure
    
    Count    : 1
    This command adds the NoEnumerate parameter to treat a collection or array as a single object through the pipeline.
    
.INPUTS
    System.Management.Automation.PSObject
    
.OUTPUTS
    System.Management.Automation.PSObject
    
.LINK
    http://go.microsoft.com/fwlink/p/?linkid=294030
    
.LINK
    Online Version:
    
.LINK
    Tee-Object
    
.LINK
    Write-Debug
    
.LINK
    Write-Error
    
.LINK
    Write-Host
    
.LINK
    Write-Progress
    
.LINK
    Write-Verbose
    
.LINK
    Write-Warning
#>
    [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=113427', RemotingCapability='None')]
     param(
         [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
         [AllowEmptyCollection()]
         [AllowNull()]
         [psobject[]]${InputObject},
         [switch]${NoEnumerate})
     
     begin
     {
         try {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
             $outBuffer = $null
             if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
             {
                 $PSBoundParameters['OutBuffer'] = 1
             }
             $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Output', [System.Management.Automation.CommandTypes]::Cmdlet)
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
            $OutputMessage = [string]$InputObject
            $script:Logger.Info("$OutputMessage")
        }
         try {
             $steppablePipeline.End()
         } catch {
             throw
         }

     }
}