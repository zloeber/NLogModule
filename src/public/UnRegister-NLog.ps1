function UnRegister-NLog {
        <#
    .SYNOPSIS
        UnRegister the NLog Target..
    .DESCRIPTION
        UnRegister the NLog Target..
        
    .EXAMPLE
         UnRegister-NLog

    #>
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