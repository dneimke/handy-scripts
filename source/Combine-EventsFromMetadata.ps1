<#

.SYNOPSIS
Combines events from N SportsCode Xml files and offsets them based on cumulative video time

.DESCRIPTION
Combines events from N SportsCode Xml files and offsets them based on cumulative video time

.EXAMPLE
Combines files based on an input configuration
.\Combine-EventsFromMetadata.ps1 -Payload Payload.json

.PARAMETER Payload
The path to the payload configuration file

{
    "path": "/Users/darre/Videos/2018-SuperLeague/Round 2/Men",
    "outputPath": "/Users/darre/Videos/2018-SuperLeague/Round 2/Men/SLM-R2-Full.xml",
    "sets": [
        {
            "file": "Metadata1.xml",
            "video": "VideoFile1.mp4"
        },
        {
            "file": "Metadata2.xml",
            "video": "VideoFile2.mp4"
        }
    ]
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
$cumulative = 0

foreach ($item in $Data.sets) {
   
    $videoFilePath = "$($Data.path)\$($item.video)"
    $metadataFilePath = "$($Data.path)\$($item.file)"
    $counter = 0

    $result = ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 $videoFilePath

    $arr = $result -split ' '

    if ($arr -and $arr.Length) {
        $length = $arr[0] # Print output

        if ($cumulative -gt 0) {
            Write-Host ".\Combine-Events.ps1 -Path1 $previousMetadataFilePath -Path2 $metadataFilePath -Offset $cumulative"

            if ($counter -eq 1) {
                $previousMetadataFilePath = .\Combine-Events.ps1 -Path1 $previousMetadataFilePath -Path2 $metadataFilePath -Offset $cumulative
            } else {
                $previousMetadataFilePath = .\Combine-Events.ps1 -Path1 $previousMetadataFilePath -Path2 $metadataFilePath -Offset $cumulative
            }

        } else {
            $previousMetadataFilePath = $metadataFilePath
        }

        $cumulative += $length
        $counter += 1
    }
   
}

if (Test-Path -Path $previousMetadataFilePath) {
    Copy-Item -Path $previousMetadataFilePath -Destination $Data.outputPath
}

