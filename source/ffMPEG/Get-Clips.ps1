<#
    .SYNOPSIS
    Splits a video into clips
    .DESCRIPTION
    Uses the metadata passed in to segment video clips from a video file
    .EXAMPLE
    Get-Clips
    .PARAMETER FilePath
    The relative path to the Video file
    #>

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $True)]
    [string]$FilePath
)

begin {
    Write-Verbose "Processing $($FilePath)"
    # Remove-Item ??
}
      
process {
    Write-Verbose "Started processing"

    # TODO: Specify the config data to pass in

    # TODO: Test-Path, Add optional output path

    # TODO: Add process logic here
}