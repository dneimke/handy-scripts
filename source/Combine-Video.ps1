
$InputPath = "C:\users\darre\Videos\2018\PLW_R6_BHCvPADHC"    
$Extension = "m2ts"
$tmpFile = "C:\temp\temp.txt"
$OutputFile = 'C:\temp\foo.m2ts'

$tmp = New-TemporaryFile



Write-Host "Created temp file $($tmp.FullName)"

$stream = [System.IO.StreamWriter] $tmpFile # $tmp.FullName

gci -Path $InputPath -filter "*.$Extension" | % {
    Write-Host "Adding file $InputPath\$_"

    $stream.WriteLine("file '$InputPath\$_'")
}

$stream.close()

ffmpeg -f concat -safe 0 -i $tmpFile -c copy $OutputFile