<#
 Created on:   6/25/2015 10:01 AM
 Created by:   Zachary Loeber
 Module Name:  NLogModule
 Requires: http://nlog-project.org/
#>

# Current script path
[string]$ScriptPath = Split-Path (get-variable myinvocation -scope script).value.Mycommand.Definition -Parent

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
    $__dllPath = Join-Path -Path $MyInvocation.MyCommand.ScriptBlock.Module.ModuleBase -ChildPath '/lib/Nlog45.dll'
}
else {
    $__dllPath = Join-Path -Path $MyInvocation.MyCommand.ScriptBlock.Module.ModuleBase -ChildPath '/lib/Nlog.dll'
}

try {
    Write-Host "Attempting to import $($__dllPath)..."
    Import-Module -Name $__dllPath -ErrorAction Stop
}
catch {
    throw
}

#region Methods
Get-ChildItem $ScriptPath/src/private -Recurse -Filter "*.ps1" -File | Foreach { 
    Write-Verbose "Dot sourcing private script file: $($_.Name)"
    . $_.FullName
}

# Load and export methods
Get-ChildItem $ScriptPath/src/public -Recurse -Filter "*.ps1" -File | Foreach { 
    Write-Verbose "Dot sourcing public script file: $($_.Name)"
    . $_.FullName

    # Find all the functions defined no deeper than the first level deep and export it.
    # This looks ugly but allows us to not keep any uneeded variables in memory that are not related to the module.
    ([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref]$null, [ref]$null)).FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | Foreach {
        Export-ModuleMember $_.Name
    }
}

Export-ModuleMember -Variable NLogConfig
#endregion Methods

$Logger = $null
$NLogConfig = Get-NewLogConfig

#region Module Cleanup
$ExecutionContext.SessionState.Module.OnRemove = {
    if ( Get-NLogDllLoadState ) {
        try {
            get-module | where {($_.Name -eq 'nlog') -or ($_.Name -eq 'Nlog45')} | foreach {
                Remove-Module $_
            }
        }
        catch { 
            Write-Warning "Unable to uninitialize module."
        }
    }    
}
#endregion Module Cleanup