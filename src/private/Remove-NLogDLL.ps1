function Remove-NLogDLL
{
    <#
    .SYNOPSIS
        Unload the NLog dlls from memory.        
    .DESCRIPTION
        Unload the NLog dlls from memory.
    .EXAMPLE
        Remove-NLogDLL
    #>
    if ( Get-NLogDllLoadState ) {
        try {
            get-module | where {($_.Name -eq 'nlog') -or ($_.Name -eq 'Nlog45')} | foreach {
                Write-Host "Removing Nested Module $($_.Name)"
                Remove-Module $_
            }
        }
        catch { 
            Write-Warning "Unable to uninitialize module."
        }
    }
}
