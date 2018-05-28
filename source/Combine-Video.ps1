

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