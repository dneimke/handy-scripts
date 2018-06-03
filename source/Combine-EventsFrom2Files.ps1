<#

.SYNOPSIS
Combines events from 2 SportsCode Xml files and offsets them based on an offset time

.DESCRIPTION
Combines events from 2 SportsCode Xml files and offsets them based on an offset time

.EXAMPLE
Combines files based on an input configuration
.\Combine-EventsFrom2Files.ps1 -Payload .\Data\Payload2.json

.PARAMETER Payload
The path to the payload configuration file

{
    "file1": "/Users/darre/Videos/2018/PLM_R12_AHCvBHC/Plm-1.xml",
    "file2": "/Users/darre/Videos/2018/PLM_R12_AHCvBHC/Plm-2.xml",
    "offset": "2128",
    "outputPath": "/Users/darre/Videos/2018/PLM_R12_AHCvBHC/PLM-R12-Full.xml"
}

#>

param
(
    [Parameter(Mandatory = $True)]
    [ValidateScript( {
            if ( -Not ($_ | Test-Path) ) {
                throw "Payload file does not exist"
            }
            if (-Not ($_ | Test-Path -PathType Leaf) ) {
                throw "The Path argument for Payload file must be a file. Folder paths are not allowed."
            }
            if ($_ -notmatch "(\.json)") {
                throw "The file specified in the path argument must be of type json"
            }
            return $true
        })]
    [System.IO.FileInfo]$Payload
)

$Data = Get-Content $Payload | convertfrom-json

$previousMetadataFilePath = .\Combine-Events.ps1 -Path1 $Data.file1 -Path2 $Data.file2 -Offset $Data.offset

if (Test-Path -Path $previousMetadataFilePath) {
    Copy-Item -Path $previousMetadataFilePath -Destination $Data.outputPath
}

