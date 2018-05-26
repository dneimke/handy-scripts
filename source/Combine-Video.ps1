
$InputFolderPath = "C:\users\darre\Videos\2018\PLW_R6_BHCvPADHC"    
$Extension = "m2ts"
$OutputFile = 'C:\temp\foo.m2ts'

$tmp = New-TemporaryFile

Write-Host "Created temp file $($tmp.FullName)"

$stream = [System.IO.StreamWriter] $tmp.FullName

gci -Path $InputFolderPath -filter "*.$Extension" | % {
    Write-Host "Adding file $InputPath\$_"
    $stream.WriteLine("file '$InputPath\$_'")
}

$stream.close()

ffmpeg -f concat -safe 0 -i $tmp.FullName -c copy $OutputFile