
<#
 Created on:   6/25/2015 10:01 AM
 Created by:   Zachary Loeber
 Module Name:  NLogModule
 Requires: http://nlog-project.org/
#>


#endregion Methods

$Logger = $null
$NLogConfig = Get-NewLogConfig

Export-ModuleMember -Variable NLogConfig -Function  'Get-LogMessageLayout', 'Get-NewLogConfig', 'Get-NewLogger', 'Get-NewLogTarget', 'Get-NLogDllLoadState', 'Register-NLog', 'UnRegister-NLog', 'Write-Debug', 'Write-Error', 'Write-Host', 'Write-Output', 'Write-Verbose', 'Write-Warning'

#region Module Cleanup
$ExecutionContext.SessionState.Module.OnRemove = {Remove-NLogDLL} 
$null = Register-EngineEvent -SourceIdentifier ( [System.Management.Automation.PsEngineEvent]::Exiting ) -Action {Remove-NLogDLL}
#endregion Module Cleanup