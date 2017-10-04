function Get-NLogInstance {
    <#
    .SYNOPSIS
        Gets the current nlog instance for the module
    .DESCRIPTION
        Gets the current nlog instance for the module
    .EXAMPLE
        $myCurrentNlog = Get-NLogInstance
    #>
    param ()

    $Script:Logger
}
