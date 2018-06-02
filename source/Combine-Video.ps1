# C:\Users\darre\repos\handy-scripts\source\Combine-Video.ps1 
#    -InputFolderPath "C:\Users\darre\Videos\2018-SuperLeague\Round 1\Saints Clips" 
#    -Extension mp4 
#    -OutputFile "Saints - All Clips.mp4"

param(
    [string]$InputFolderPath = $(throw "Supply the input folder path"),
    [string]$Extension = $(throw "Supply an extension"),
    [string]$OutputFile = $(throw "Specify an output file")   
)

$tmp = New-TemporaryFile

Write-Host "Created temp file $($tmp.FullName)"

$stream = [System.IO.StreamWriter] $tmp.FullName

gci -Path $InputFolderPath -filter "*.$Extension" | % {
    Write-Host "Adding file $($_.FullName)"
    $stream.WriteLine("file '$($_.FullName)'")
}

$stream.close()

ffmpeg -f concat -safe 0 -i $tmp.FullName -c copy $OutputFile