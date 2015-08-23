<#
 Created on:   6/25/2015 10:01 AM
 Created by:   Zachary
 Module Name:  NLogModule
 Requires: http://nlog-project.org/
#>

function Get-CallerPreference {
    <#
    .Synopsis
       Fetches "Preference" variable values from the caller's scope.
    .DESCRIPTION
       Script module functions do not automatically inherit their caller's variables, but they can be
       obtained through the $PSCmdlet variable in Advanced Functions.  This function is a helper function
       for any script module Advanced Function; by passing in the values of $ExecutionContext.SessionState
       and $PSCmdlet, Get-CallerPreference will set the caller's preference variables locally.
    .PARAMETER Cmdlet
       The $PSCmdlet object from a script module Advanced Function.
    .PARAMETER SessionState
       The $ExecutionContext.SessionState object from a script module Advanced Function.  This is how the
       Get-CallerPreference function sets variables in its callers' scope, even if that caller is in a different
       script module.
    .PARAMETER Name
       Optional array of parameter names to retrieve from the caller's scope.  Default is to retrieve all
       Preference variables as defined in the about_Preference_Variables help file (as of PowerShell 4.0)
       This parameter may also specify names of variables that are not in the about_Preference_Variables
       help file, and the function will retrieve and set those as well.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Imports the default PowerShell preference variables from the caller into the local scope.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'ErrorActionPreference','SomeOtherVariable'

       Imports only the ErrorActionPreference and SomeOtherVariable variables into the local scope.
    .EXAMPLE
       'ErrorActionPreference','SomeOtherVariable' | Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Same as Example 2, but sends variable names to the Name parameter via pipeline input.
    .INPUTS
       String
    .OUTPUTS
       None.  This function does not produce pipeline output.
    .LINK
       about_Preference_Variables
    #>

    [CmdletBinding(DefaultParameterSetName = 'AllVariables')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_.GetType().FullName -eq 'System.Management.Automation.PSScriptCmdlet' })]
        $Cmdlet,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SessionState]
        $SessionState,

        [Parameter(ParameterSetName = 'Filtered', ValueFromPipeline = $true)]
        [string[]]
        $Name
    )

    begin
    {
        $filterHash = @{}
    }
    
    process
    {
        if ($null -ne $Name)
        {
            foreach ($string in $Name)
            {
                $filterHash[$string] = $true
            }
        }
    }

    end
    {
        # List of preference variables taken from the about_Preference_Variables help file in PowerShell version 4.0

        $vars = @{
            'ErrorView' = $null
            'FormatEnumerationLimit' = $null
            'LogCommandHealthEvent' = $null
            'LogCommandLifecycleEvent' = $null
            'LogEngineHealthEvent' = $null
            'LogEngineLifecycleEvent' = $null
            'LogProviderHealthEvent' = $null
            'LogProviderLifecycleEvent' = $null
            'MaximumAliasCount' = $null
            'MaximumDriveCount' = $null
            'MaximumErrorCount' = $null
            'MaximumFunctionCount' = $null
            'MaximumHistoryCount' = $null
            'MaximumVariableCount' = $null
            'OFS' = $null
            'OutputEncoding' = $null
            'ProgressPreference' = $null
            'PSDefaultParameterValues' = $null
            'PSEmailServer' = $null
            'PSModuleAutoLoadingPreference' = $null
            'PSSessionApplicationName' = $null
            'PSSessionConfigurationName' = $null
            'PSSessionOption' = $null

            'ErrorActionPreference' = 'ErrorAction'
            'DebugPreference' = 'Debug'
            'ConfirmPreference' = 'Confirm'
            'WhatIfPreference' = 'WhatIf'
            'VerbosePreference' = 'Verbose'
            'WarningPreference' = 'WarningAction'
        }


        foreach ($entry in $vars.GetEnumerator())
        {
            if (([string]::IsNullOrEmpty($entry.Value) -or -not $Cmdlet.MyInvocation.BoundParameters.ContainsKey($entry.Value)) -and
                ($PSCmdlet.ParameterSetName -eq 'AllVariables' -or $filterHash.ContainsKey($entry.Name)))
            {
                $variable = $Cmdlet.SessionState.PSVariable.Get($entry.Key)
                
                if ($null -ne $variable)
                {
                    if ($SessionState -eq $ExecutionContext.SessionState)
                    {
                        Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                    }
                    else
                    {
                        $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                    }
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'Filtered')
        {
            foreach ($varName in $filterHash.Keys)
            {
                if (-not $vars.ContainsKey($varName))
                {
                    $variable = $Cmdlet.SessionState.PSVariable.Get($varName)
                
                    if ($null -ne $variable)
                    {
                        if ($SessionState -eq $ExecutionContext.SessionState)
                        {
                            Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                        }
                        else
                        {
                            $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                        }
                    }
                }
            }
        }

    } # end

} # function Get-CallerPreference

function Get-NewLogger {
    <#
    .SYNOPSIS
        Creates a new LogManager instance
    .DESCRIPTION
        Important to log messages to file, mail, console etc.
    .EXAMPLE
       $myLogger = Get-NewLogger()
    #>
    param ( [parameter(mandatory=$true)] [System.String]$loggerName ) 
    
    [NLog.LogManager]::GetLogger($loggerName) 
}

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

function Get-NewLogTarget {
    <#
    .SYNOPSIS
        Creates a new logging target
    .DESCRIPTION
        Logging targets are required to write down the log messages somewhere
    .EXAMPLE
       $myFilelogtarget = Get-NewLogTarget -targetType "file"
    #>
    param ( [parameter(mandatory=$true)] [System.String]$targetType ) 
    
    switch ($targetType) {
        "console" {
            New-Object NLog.Targets.ColoredConsoleTarget    
        }
        "file" {
            New-Object NLog.Targets.FileTarget
        }
        "mail" { 
            New-Object NLog.Targets.MailTarget
        }
    }

}

function Get-LogMessageLayout {
    <#
    .SYNOPSIS
        Sets the log message layout
    .DESCRIPTION
        Defines, how your log message looks like. This function can be enhanced by yourself. I just provided a few examples how log messages can look like
    .EXAMPLE
       #$myFilelogtarget.Layout    = Get-LogMessageLayout -layoutId 1
    #>
    param ( [parameter(mandatory=$true)] [System.Int32]$layoutId ) 
    
    switch ($layoutId) {
        1 {
            $layout    = '${longdate} | ${machinename} | ${processid} | ${processname} | ${level} | ${logger} | ${message}'
        }
        default {
            $layout    = '${longdate} | ${machinename} | ${processid} | ${processname} | ${level} | ${logger} | ${message}'
        }
    }
    return $layout
}

Function Write-Verbose {
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
    
.LINK
    http://go.microsoft.com/fwlink/p/?linkid=294032
    
.LINK
    Online Version:
    
.LINK
    Write-Error
    
.LINK
    Write-Warning
    
.LINK
    about_Preference_Variables
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

Function Write-Host {
<#
.SYNOPSIS
    Writes customized output to a host.
    
.DESCRIPTION
    The Write-Host cmdlet customizes output. You can specify the color of text by using the ForegroundColor parameter, and you can specify the background color by using the BackgroundColor parameter. The Separator parameter lets you specify a string to use to separate displayed objects. The particular result depends on the program that is hosting Windows PowerShell.
    
.PARAMETER BackgroundColor
    Specifies the background color. There is no default.
    
.PARAMETER ForegroundColor
    Specifies the text color. There is no default.
    
.PARAMETER NoNewline
    Specifies that the content displayed in the console does not end with a newline character.
    
.PARAMETER Object
    Objects to display in the console.
    
.PARAMETER Separator
    String to the output between objects displayed on the console.
    
.EXAMPLE
    PS C:\>write-host "no newline test " -nonewline
    no newline test PS C:\>
    This command displays the input to the console, but because of the NoNewline parameter, the output is followed directly by the prompt.
    
.EXAMPLE
    PS C:\>write-host (2,4,6,8,10,12) -Separator ", +2= "
    2, +2= 4, +2= 6, +2= 8, +2= 10, +2= 12
    This command displays the even numbers from 2 through 12. The Separator parameter is used to add the string , +2= (comma, space, +, 2, =, space).
    
.EXAMPLE
    PS C:\>write-host (2,4,6,8,10,12) -Separator ", -> " -foregroundcolor DarkGreen -backgroundcolor white
    This command displays the even numbers from 2 through 12. It uses the ForegroundColor parameter to output dark green text and the BackgroundColor parameter to display a white background.
    
.EXAMPLE
    PS C:\>write-host "Red on white text." -ForegroundColor red -BackgroundColor white
    Red on white text.
    This command displays the string "Red on white text." The text is red, as defined by the ForegroundColor parameter. The background is white, as defined by the BackgroundColor parameter.
    
.INPUTS
    System.Object
    
.OUTPUTS
    None
    
.LINK
    http://go.microsoft.com/fwlink/p/?linkid=294029
    
.LINK
    Online Version:
    
.LINK
    Clear-Host
    
.LINK
    Out-Host
    
.LINK
    Write-Debug
    
.LINK
    Write-Error
    
.LINK
    Write-Output
    
.LINK
    Write-Progress
    
.LINK
    Write-Verbose
    
.LINK
    Write-Warning
#>


    [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=113426', RemotingCapability='None')]
     param(
         [Parameter(Position=0, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
         [System.Object]
         ${Object},
     
         [switch]
         ${NoNewline},
     
         [System.Object]
         ${Separator},
     
         [System.ConsoleColor]
         ${ForegroundColor},
     
         [System.ConsoleColor]
         ${BackgroundColor})
     
     begin
     {
         try {
             $outBuffer = $null
             if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
             {
                 $PSBoundParameters['OutBuffer'] = 1
             }
             $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Host', [System.Management.Automation.CommandTypes]::Cmdlet)
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
            $Message = [string]$Object
            $script:Logger.Info("$Message")
        }
         try {
             $steppablePipeline.End()
         } catch {
             throw
         }
     }
}

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
             $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Warning', [System.Management.Automation.CommandTypes]::Cmdlet)
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
            $script:Logger.Warn("$Message")
        }
         try {
             $steppablePipeline.End()
         } catch {
             throw
         }
     }
}

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
    
.LINK
    http://go.microsoft.com/fwlink/p/?linkid=294028
    
.LINK
    Online Version:
    
.LINK
    Write-Debug
    
.LINK
    Write-Host
    
.LINK
    Write-Output
    
.LINK
    Write-Progress
    
.LINK
    Write-Verbose
    
.LINK
    Write-Warning
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

Function Write-Debug {
<#
.SYNOPSIS
    Writes a debug message to the console.
    
.DESCRIPTION
    The Write-Debug cmdlet writes debug messages to the console from a script or command.
    
    By default, debug messages are not displayed in the console, but you can display them by using the Debug parameter or the $DebugPreference variable.
    
.EXAMPLE
    PS C:\>Write-Debug "Cannot open file."
    This command writes a debug message. Because the value of $DebugPreference is "SilentlyContinue", the message is not displayed in the console.
    
.EXAMPLE
    PS C:\>$DebugPreference
    SilentlyContinue
    PS C:\>Write-Debug "Cannot open file."
    PS C:\>
    PS C:\>Write-Debug "Cannot open file." -debug
    DEBUG: Cannot open file.
    This example shows how to use the Debug common parameter to override the value of the $DebugPreference variable for a particular command.
    The first command displays the value of the $DebugPreference variable, which is "SilentlyContinue", the default.
    The second command writes a debug message but, because of the value of $DebugPreference, the message does not appear.
    The third command writes a debug message. It uses the Debug common parameter to override the value of $DebugPreference and to display the debug messages resulting from this command.
    As a result, even though the value of $DebugPreference is "SilentlyContinue", the debug message appears.
    For more information about the Debug common parameter, see about_CommonParameters.
    
.EXAMPLE
    PS C:\>$DebugPreference
    SilentlyContinue
    PS C:\>Write-Debug "Cannot open file."
    PS C:\>
    PS C:\>$DebugPreference = "Continue"
    PS C:\>Write-Debug "Cannot open file."
    DEBUG: Cannot open file.
    This command shows the effect of changing the value of the $DebugPreference variable on the display of debug messages.
    The first command displays the value of the $DebugPreference variable, which is "SilentlyContinue", the default.
    The second command writes a debug message but, because of the value of $DebugPreference, the message does not appear.
    The third command assigns a value of "Continue" to the $DebugPreference variable.
    The fourth command writes a debug message, which appears on the console.
    For more information about $DebugPreference, see about_Preference_Variables.
    
.INPUTS
    System.String
    
.OUTPUTS
    None
    
.LINK
    http://go.microsoft.com/fwlink/p/?linkid=294027
    
.LINK
    Online Version:
    
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
    Write-Warning
#>


    [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=113424', RemotingCapability='None')]
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
             $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Debug', [System.Management.Automation.CommandTypes]::Cmdlet)
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
            $script:Logger.Trace($Message)
        }
         try {
             $steppablePipeline.End()
         } catch {
             throw
         }
     }
}

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

function Register-NLog {
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

function UnRegister-NLog {
    [CmdletBinding()]
    param ()
    if ($Script:Logger -ne $null) {
        $Script:NLogConfig = Get-NewLogConfig
        $Script:Logger = $null
    }
    else {
        Write-Host 'NlogModule: You must first run Register-NLog!'
    }
}

function Get-NLogDllLoadState {
    if (-not (get-module | where {($_.Name -eq 'nlog') -or ($_.Name -eq 'Nlog45')})) {
        return $false
    }
    else {
        return $true
    }
}

try {
    $DotNetInstalled = (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse | 
        Get-ItemProperty -name Version -ea 0 | 
        Where { $_.PSChildName -match '^(?!S)\p{L}'} | 
        Select @{n='version';e={[decimal](($_.Version).Substring(0,3))}} -Unique |
        Sort-Object -Descending | select -First 1).Version
}
catch {
    $DotNetInstalled = 3.5
}

if ($DotNetInstalled -ge 4.5) {
    $__dllPath = Join-Path -Path $MyInvocation.MyCommand.ScriptBlock.Module.ModuleBase -ChildPath 'Nlog45.dll'
}
else {
    $__dllPath = Join-Path -Path $MyInvocation.MyCommand.ScriptBlock.Module.ModuleBase -ChildPath 'Nlog.dll'
}

try {
    Write-Host "Attempting to import $($__dllPath)..."
    Import-Module -Name $__dllPath -ErrorAction Stop
}
catch {
    throw
}

$Logger = $null
$NLogConfig = Get-NewLogConfig

Export-ModuleMember Load-NLog, Get-NewLogger, Get-NewLogConfig, Get-NewLogTarget, Get-LogMessageLayout, Write-Verbose, Write-Host, Write-Warning, Write-Error, Write-Debug, Write-Output, Register-NLog, UnRegister-NLog, Get-NLogDllLoadState
Export-ModuleMember -Variable NLogConfig

#region Module Cleanup
$ExecutionContext.SessionState.Module.OnRemove = {
    if ( Get-NLogDllLoadState ) {
        try {
            get-module | where {($_.Name -eq 'nlog') -or ($_.Name -eq 'Nlog45')} | foreach {Remove-Module $_}
        }
        catch { 
            Write-Warning "Unable to uninitialize module."
        }
    }    
}
#endregion Module Cleanup