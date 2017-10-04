function Get-NLogMessageLayout {
    <#
    .SYNOPSIS
        Sets the log message layout
    .DESCRIPTION
        Defines, how your log message looks like. This function can be enhanced by yourself. I just provided a few examples how log messages can look like
    .EXAMPLE
       $myFilelogtarget.Layout  = Get-NLogMessageLayout -layoutId 1
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
            $layout = '${longdate} | ${machinename} | ${processid} | ${processname} | ${level} | ${logger} | ${message}'
        }
        2 {
            $layout = '${shortdate} | ${processname} | ${level} | ${logger} | ${message}'
        }

        3 {
            $layout = '${longdate}|${level:uppercase=true}|${logger}|${message}'
        }
        default {
            $layout    = '${longdate} | ${machinename} | ${processid} | ${processname} | ${level} | ${logger} | ${message}'
        }
    }
    return $layout
}
