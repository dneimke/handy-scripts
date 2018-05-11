<#
.SYNOPSIS
Generates a video from a specified set of clips

.DESCRIPTION
This script will perform the following actions:
    - Read a payload file which contains a set of clips
    - Extracts a video segment for each clip
    - Concatenates the clips into a single playable video

    JSON Structure
    {
        "playlistName": "Goals_For",
        "videoUrl": "/Users/foo/Dropbox/Hockey/AHC/2017/PA/GF/R25_GF_SHCvAHC_FullGame.mp4",
        "clips": [{
            "start": "00:32:00",
            "duration": "5",
            "description": "Nice angled shot to base board"
        }, {
            "start": "00:45:00",
            "duration": "5"
        }, {
            "start": "1:05:00",
            "duration": "15"
        }, {
            "start": "1:09:00",
            "duration": "15"
        }]
    }

.PARAMETER Payload
The filename of the payload file

.EXAMPLE
.\New-ClipsVideo.ps1 outletting_playlist.json -Payload 'foo.json'
#>

param(
    [string]$Payload = $(throw "Supply the payload filename"),
    [string]$Font = '/Library/Fonts/Microsoft/Eurostile',
    [string]$VideoFile    
)

write-host "`nPlaylist Extractor`n"

Write-Host "Config: Font: $Font; VideoFile: $VideoFile"

#$FFMPEG_OPTS = "-loglevel quiet -hide_banner -nostats"
$TITLE = "Match Share"

if((Test-Path "$($Payload)") -eq $False) {
    Write-Host -ForegroundColor Red "  -- Error: the specified payload file could not be found"
    exit -1
}

$Data = Get-Content $Payload | convertfrom-json

if($VideoFile) {
    $Data.videoUrl = $VideoFile
}

$InputFile = $data.videoUrl
$PlayList = $Data.PlaylistName
$Clips = $Data.Clips

Write-Host -ForegroundColor Cyan "Processing PlayList"
Write-Host -ForegroundColor Cyan "  -- Name: $PlayList"
Write-Host -ForegroundColor Cyan "  -- InputFile: $InputFile"
Write-Host -ForegroundColor Cyan "  -- Total Clips: $($Clips.Count)"

#
# Generate clips
#
$ClipId = 0
$Clips | foreach-object {
    $ClipId++
    $ClipFile = "$($PlayList)_$($ClipId).mp4"
    $StartOffset = $_.Start
    $Duration = $_.Duration
    $Description = $_.Description

    Write-Host -ForegroundColor Cyan "     + ($ClipFile) - [$ClipId] [$StartOffset, $Duration] '$Description'"
    ffmpeg -loglevel quiet -hide_banner -ss $StartOffset -i $InputFile -c copy -t $Duration $ClipFile 
    #ffmpeg -loglevel quiet -hide_banner -ss $StartOffset -t $Duration -i $InputFile -filter_complex "drawtext=:fontfile=$Font:fontcolor=yellow:fontsize=48:text='$Description':x=main_w-(text_w+12):y=main_h-(text_h+12), drawtext=:fontfile=$Font:fontcolor=white:fontsize=32:text='$TITLE':x=(12):y=(text_h+12)" $ClipFile -y
}

#
# Concatenate clips
#
if((Test-Path "$($PlayList).list")) {
    remove-item "$($PlayList).list"
}

if((get-childitem "$($PlayList)_*.mp4").Count -gt 0) {
        get-childitem "$($PlayList)_*.mp4" | foreach-object {
            "file '$($_)'" | out-file -Encoding ASCII -FilePath "$($PlayList).list" -Append
        }
}

if(Test-Path "$($PlayList).list") {
    Write-Host -ForegroundColor Cyan " -- OutputFile: $PlayList.mp4"
    ffmpeg -loglevel quiet -hide_banner -nostats -f concat -safe 0 -i "$($PlayList).list" -c copy "$($PlayList).mp4" -y
}

#
# Cleanup files
#
if(Test-Path "$($PlayList).mp4") {
    Write-Host "Cleaning $($PlayList).mp4"
    remove-item "$($Playlist)_*.mp4"
    remove-item "$($Playlist).list"
}else{
    Write-Host "Not Cleaning $($PlayList).mp4" 
}