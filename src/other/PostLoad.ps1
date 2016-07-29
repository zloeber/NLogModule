function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    if($Invocation.PSScriptRoot)
    {
        $Invocation.PSScriptRoot;
    }
    Elseif($Invocation.MyCommand.Path)
    {
        Split-Path $Invocation.MyCommand.Path
    }
    else
    {
        $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
    }
}

$MyModulePath = Get-ScriptDirectory

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
