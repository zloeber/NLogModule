function Get-NLogDllLoadState {
    <#
    .SYNOPSIS
        Validate if the NLog Dll is loaded or not.
    .DESCRIPTION
        Validate if the NLog Dll is loaded or not.
    .EXAMPLE
       Get-NLogDllLoadState
    #>
    if (-not (get-module | where {($_.Name -eq 'nlog') -or ($_.Name -eq 'Nlog45')})) {
        return $false
    }
    else {
        return $true
    }
}
