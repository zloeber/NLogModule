function New-NLogFileTarget {
    <#
    .SYNOPSIS
    Creates a new file logging target
    .DESCRIPTION
    Creates a new file logging target
    .PARAMETER ArchiveAboveSize
    Archives file above this many bytes.
    .PARAMETER archiveEvery
    Period of time to archive log files
    .PARAMETER ArchiveNumbering
    How archive files are names
    .PARAMETER CreateDirs
    Create directories when archiving
    .PARAMETER FileName
    Name of log file
    .PARAMETER Encoding
    File encoding type
    .PARAMETER KeepFileOpen
    Maintain a lock on the log file
    .PARAMETER Layout
    Message layout for logs to the file
    .PARAMETER maxArchiveFiles
    Maximum number of archive files to retain.
    .EXAMPLE
    TBD
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$ArchiveAboveSize = 10240000,
        [Parameter()]
        [string]$archiveEvery = 'Month',
        [Parameter()]
        [string]$ArchiveNumbering = 'Rolling',
        [Parameter()]
        [switch]$CreateDirs,
        [Parameter(Mandatory=$true)]
        [string]$FileName,
        [Parameter()]
        [System.Text.Encoding]$Encoding = [System.Text.Encoding]::GetEncoding("iso-8859-2"),
        [Parameter()]
        [switch]$KeepFileOpen,
        [Parameter()]
        [string]$Layout = (Get-NLogMessageLayout -layoutId 1),
        [Parameter()]
        [int]$maxArchiveFiles = 1
    ) 
    
    $LogTarget = New-NLogTarget -targetType 'file'
    $LogTarget.ArchiveAboveSize = $ArchiveAboveSize
    $LogTarget.archiveEvery = $archiveEvery
    $LogTarget.ArchiveNumbering = $ArchiveNumbering    
    $LogTarget.CreateDirs = $CreateDirs    
    $LogTarget.FileName = $FileName
    $LogTarget.Encoding = $Encoding
    $LogTarget.KeepFileOpen = $KeepFileOpen
    $LogTarget.Layout = $Layout
    $LogTarget.maxArchiveFiles = $maxArchiveFiles

    $LogTarget
}
