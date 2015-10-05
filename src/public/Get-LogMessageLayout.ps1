function Get-LogMessageLayout {
    <#
    .SYNOPSIS
        Sets the log message layout
    .DESCRIPTION
        Defines, how your log message looks like. This function can be enhanced by yourself. I just provided a few examples how log messages can look like
    .EXAMPLE
       #$myFilelogtarget.Layout    = Get-LogMessageLayout -layoutId 1
    #>
    param ( [parameter(mandatory=$true)] [System.Int32]$layoutId ) 
    
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