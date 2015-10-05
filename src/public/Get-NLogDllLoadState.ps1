function Get-NLogDllLoadState {
    if (-not (get-module | where {($_.Name -eq 'nlog') -or ($_.Name -eq 'Nlog45')})) {
        return $false
    }
    else {
        return $true
    }
}