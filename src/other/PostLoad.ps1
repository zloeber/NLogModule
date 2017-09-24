
# Use this variable for any path-sepecific actions (like loading dlls and such) to ensure it will work in testing and after being built
$MyModulePath = $(
    Function Get-ScriptPath {
        $Invocation = (Get-Variable MyInvocation -Scope 1).Value
        if($Invocation.PSScriptRoot) {
            $Invocation.PSScriptRoot
        }
        Elseif($Invocation.MyCommand.Path) {
            Split-Path $Invocation.MyCommand.Path
        }
        elseif ($Invocation.InvocationName.Length -eq 0) {
            (Get-Location).Path
        }
        else {
            $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
        }
    }

    Get-ScriptPath
)

#region Module Cleanup
$ExecutionContext.SessionState.Module.OnRemove = {
    # Action to take if the module is removed
}

$null = Register-EngineEvent -SourceIdentifier ( [System.Management.Automation.PsEngineEvent]::Exiting ) -Action {
    # Action to take if the whole pssession is killed
}

# Use this in your scripts to check if the function is being called from your module or independantly.
$ThisModuleLoaded = $true

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
    #$__dllPath = Join-Path -Path $MyInvocation.MyCommand.ScriptBlock.Module.ModuleBase -ChildPath "$($Script:ScriptPath)/lib/Nlog45.dll"
    $__dllPath = "$($MyModulePath)\lib\Nlog45.dll"
}
else {
    #$__dllPath = Join-Path -Path $MyInvocation.MyCommand.ScriptBlock.Module.ModuleBase -ChildPath "$($Script:ScriptPath)/lib/Nlog.dll"
    $__dllPath = "$($MyModulePath)\lib\Nlog.dll"
}

try {
    #Write-Host "Attempting to import $($__dllPath)..."
    Import-Module -Name $__dllPath -ErrorAction Stop
}
catch {
    throw
}

$Logger = $null
$NLogConfig = Get-NewLogConfig

#region Module Cleanup
$ExecutionContext.SessionState.Module.OnRemove = {Remove-NLogDLL} 
$null = Register-EngineEvent -SourceIdentifier ( [System.Management.Automation.PsEngineEvent]::Exiting ) -Action {Remove-NLogDLL}
#endregion Module Cleanup

# Exported members
Export-ModuleMember -Variable NLogConfig -Function  'Get-LogMessageLayout', 'Get-NewLogConfig', 'Get-NewLogger', 'Get-NewLogTarget', 'Get-NLogDllLoadState', 'Register-NLog', 'UnRegister-NLog', 'Write-Debug', 'Write-Error', 'Write-Host', 'Write-Output', 'Write-Verbose', 'Write-Warning'
