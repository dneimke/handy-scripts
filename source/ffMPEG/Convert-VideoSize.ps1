param(
    [ValidateScript({Test-Path $_})]
    $OriginalFile = $(throw "OriginalFile - must be supplied"),
    $Width = "1280",
    [switch]$DryRun = $false,
    [switch]$Test = $false
)

# Should discover what the AR is for the existing video stream, but this'll do for the moment
$AspectRatio = (16/9) 

function ConvertTo-AspectRatio($x) {

    return [Math]::round($x/$AspectRatio,0)
}

if($Test.IsPresent) {
    Write-Host "AspectRatio: $AspectRatio"
    $sizes = @()
    $sizes += 1920
    $sizes += 1280
    $sizes += 1024

    foreach($x in $sizes) {
        $y = ConvertTo-GoldenRatio($x)
        write-host "$($x)x$($y)"
    }
    exit
}

# Get the new height
$Height = ConvertTo-AspectRatio($Width)

# Da file stuff
$InputFile = Get-ChildItem $OriginalFile
$Directory = Split-Path -Path $InputFile.ToString() 

# Compose the new filename
$ConvertedFileName = "$($InputFile.BaseName)_$($Width)p$($InputFile.Extension)"

# Tell 'em that you love 'em
Write-Host -ForegroundColor Cyan "Converting ""$OriginalFile"" to $($Width)x$($Height) as ""$Directory/$ConvertedFileName"""

# Do conversion
if(! $DryRun.IsPresent) {
    ffmpeg -i $OriginalFile -s "$($Width)x$($Height)" "$($Directory)/$($ConvertedFileName)"
}
