function Write-Host {
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
#>


    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkID=113426', RemotingCapability = 'None')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromRemainingArguments = $true)]
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
     
    begin {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Host', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch {
            throw
        }
    }
     
    process {
        try {
            $steppablePipeline.Process($_)
        }
        catch {
            throw
        }
    }
     
    end {
        if ($null -ne $script:Logger) {
            $OutputMessage = @(([string]$Object).Split([Environment]::NewLine) | Where-Object {-not [string]::IsNullOrEmpty($_)}) -join ''
            $script:Logger.Info($OutputMessage)
        }
        try {
            $steppablePipeline.End()
        }
        catch {
            throw
        }
    }
}
