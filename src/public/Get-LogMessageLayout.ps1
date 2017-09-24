function Get-LogMessageLayout {
    <#
    .SYNOPSIS
        Sets the log message layout
    .DESCRIPTION
        Defines, how your log message looks like. This function can be enhanced by yourself. I just provided a few examples how log messages can look like
    .EXAMPLE
       $myFilelogtarget.Layout  = Get-LogMessageLayout -layoutId 1
    .PARAMETER LayoutID
        Currently the only defined layout ID is 1. More can be added to suit your needs.
    #>
    [CmdletBinding()]
    param (
        [parameter()] 
        [System.Int32]$layoutId = 1
    ) 
    
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
