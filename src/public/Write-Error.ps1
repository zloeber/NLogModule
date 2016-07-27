Function Write-Error {
<#
.SYNOPSIS
    Writes an object to the error stream.
    
.DESCRIPTION
    The Write-Error cmdlet declares a non-terminating error. By default, errors are sent in the error stream to the host program to be displayed, along with output.
    
    To write a non-terminating error, enter an error message string, an ErrorRecord object, or an Exception object.  Use the other parameters of Write-Error to populate the error record.
    
    Non-terminating errors write an error to the error stream, but they do not stop command processing. If a non-terminating error is declared on one item in a collection of input items, the command continues to process the other items in the collection.
    
    To declare a terminating error, use the Throw keyword. For more information, see about_Throw (http://go.microsoft.com/fwlink/?LinkID=145153).
    
.PARAMETER Category
    Specifies the category of the error. The default value is NotSpecified.
    
    For information about the error categories, see "ErrorCategory Enumeration" in the MSDN (Microsoft Developer Network) library at http://go.microsoft.com/fwlink/?LinkId=143600.
    
.PARAMETER CategoryActivity
    Describes the action that caused the error.
    
.PARAMETER CategoryReason
    Explains how or why the activity caused the error.
    
.PARAMETER CategoryTargetName
    Specifies the name of the object that was being processed when the error occurred.
    
.PARAMETER CategoryTargetType
    Specifies the type of the object that was being processed when the error occurred.
    
.PARAMETER ErrorId
    Specifies an ID string to identify the error. The string should be unique to the error.
    
.PARAMETER ErrorRecord
    Specifies an error record object that represents the error. Use the properties of the object to describe the error.
    
    To create an error record object, use the New-Object cmdlet or get an error record object from the array in the $Error automatic variable.
    
.PARAMETER Exception
    Specifies an exception object that represents the error. Use the properties of the object to describe the error.
    
    To create an exception object, use a hash table or use the New-Object cmdlet.
    
.PARAMETER Message
    Specifies the message text of the error.  If the text includes spaces or special characters, enclose it in quotation marks. You can also pipe a message string to Write-Error.
    
.PARAMETER RecommendedAction
    Describes the action that the user should take to resolve or prevent the error.
    
.PARAMETER TargetObject
    Specifies the object that was being processed when the error occurred. Enter the object (such as a string), a variable that contains the object, or a command that gets the object.
    
.EXAMPLE
    PS C:\>Get-ChildItem | ForEach-Object { if ($_.GetType().ToString() -eq "Microsoft.Win32.RegistryKey") {Write-Error "Invalid object" -ErrorID B1 -Targetobject $_ } else {$_ } }
    This command declares a non-terminating error when the Get-ChildItem cmdlet returns a Microsoft.Win32.RegistryKey object, such as the objects in the HKLM: or HKCU: drives of the Windows PowerShell Registry provider.
    
.EXAMPLE
    PS C:\>Write-Error "Access denied."
    This command declares a non-terminating error and writes an "Access denied" error. The command uses the Message parameter to specify the message, but omits the optional Message parameter name.
    
.EXAMPLE
    PS C:\>Write-Error -Message "Error: Too many input values." -Category InvalidArgument
    This command declares a non-terminating error and specifies an error category.
    
.EXAMPLE
    PS C:\>$e = [System.Exception]@{$e = [System.Exception]@{Source="Get-ParameterNames.ps1";HelpLink="http://go.microsoft.com/fwlink/?LinkID=113425"}HelpLink="http://go.microsoft.com/fwlink/?LinkID=113425"}
    PS C:\> Write-Error $e -Message "Files not found. The $Files location does not contain any XML files."
    This command uses an Exception object to declare a non-terminating error.
    The first command uses a hash table to create the System.Exception object. It saves the exception object in the $e variable. You can use a hash table to create any object of a type that has a null constructor.
    The second command uses the Write-Error cmdlet to declare a non-terminating error. The value of the Exception parameter is the Exception object in the $e variable.
    
.INPUTS
    System.String
    
.OUTPUTS
    Error object
#>


    [CmdletBinding(DefaultParameterSetName='NoException', RemotingCapability='None')]
     param(
         [Parameter(ParameterSetName='WithException', Mandatory=$true)]
         [System.Exception]
         ${Exception},
     
         [Parameter(ParameterSetName='NoException', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
         [Parameter(ParameterSetName='WithException')]
         [Alias('Msg')]
         [AllowEmptyString()]
         [AllowNull()]
         [string]
         ${Message},
     
         [Parameter(ParameterSetName='ErrorRecord', Mandatory=$true)]
         [System.Management.Automation.ErrorRecord]
         ${ErrorRecord},
     
         [Parameter(ParameterSetName='WithException')]
         [Parameter(ParameterSetName='NoException')]
         [System.Management.Automation.ErrorCategory]
         ${Category},
     
         [Parameter(ParameterSetName='NoException')]
         [Parameter(ParameterSetName='WithException')]
         [string]
         ${ErrorId},
     
         [Parameter(ParameterSetName='NoException')]
         [Parameter(ParameterSetName='WithException')]
         [System.Object]
         ${TargetObject},
     
         [string]
         ${RecommendedAction},
     
         [Alias('Activity')]
         [string]
         ${CategoryActivity},
     
         [Alias('Reason')]
         [string]
         ${CategoryReason},
     
         [Alias('TargetName')]
         [string]
         ${CategoryTargetName},
     
         [Alias('TargetType')]
         [string]
         ${CategoryTargetType})
     
     begin
     {
         try {
             $outBuffer = $null
             if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
             {
                 $PSBoundParameters['OutBuffer'] = 1
             }
             $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Error', [System.Management.Automation.CommandTypes]::Cmdlet)
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
            $script:Logger.Error($Message)
        }
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
     }
}