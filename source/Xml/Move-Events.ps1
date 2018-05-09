<#

.SYNOPSIS
Moves events in a SportsCode Xml data file

.DESCRIPTION
Move all or just a subset of events based on Time-Start, Time-End, Filter

.EXAMPLE
Moves all events in the Outlet code forward by 20 seconds that are between 3 and 200 seconds 
.\Move-Events.ps1 -Path ./Match1.xml -Start 3 -End 200 -Value 20 -Filter Outlet

.EXAMPLE
Moves all events backward by 364 seconds that are after 2300 seconds 
.\Move-Events.ps1 -Path 'North East-AHC PLM 5_05_2018 2018 PLW.xml' -Value -364 -Start 2300

.PARAMETER Path
The relative path to the data file

.PARAMETER Value
The amount of seconds to move each event by

.PARAMETER Start
Optional value to filter events based on the starting seconds 

.PARAMETER End
Optional value to filter events based on the ending seconds 

.PARAMETER Filter
Optional value to filter events based on the code

#>

param
(
    [Parameter(Mandatory = $True)]
    [ValidateScript( {
            if ( -Not ($_ | Test-Path) ) {
                throw "File or folder does not exist"
            }
            if (-Not ($_ | Test-Path -PathType Leaf) ) {
                throw "The Path argument must be a file. Folder paths are not allowed."
            }
            if ($_ -notmatch "(\.xml)") {
                throw "The file specified in the path argument must be of type xml"
            }
            return $true
        })]
    [System.IO.FileInfo]$Path,
    [Parameter(Mandatory = $True)]
    [int]$Value,
    [int]$Start,
    [int]$End,
    [string]$Filter
)


function IsMatch($Node, [int]$Start, [int]$End, [string]$Filter) {

    $startSeconds = [double]$Node.start
    $endSeconds = [double]$Node.end

    if ($Start -gt 0 -and ($startSeconds -lt $Start -or $endSeconds -lt $Start)) {
        # Write-Host "False Start: $Start; Node Start: $($Node.start); Node End: $($Node.end)"
        return $false
    }

    if ($End -gt 0 -and ($startSeconds -gt $End -or $endSeconds -gt $End)) {
        # Write-Host "False End: $End; Node Start: $($Node.start); Node End: $($Node.end)"
        return $false
    }

    if ($Filter -and $Node.code -ne $Filter) {
        # Write-Host "False Filter: $Filter; Node code: $($Node.code)"
        return $false
    }

    return $true
}


      
Write-Verbose "Processing $($Path)"
Write-Verbose "Started processing with parameters - Value: $Value, Start: $Start, End: $End, Filter: $Filter"

$xml = New-Object -TypeName XML
$xml.Load($Path)

foreach ($item in (Select-XML -Xml $xml -XPath '//instance')) {

    # Write-Host "Start: $($item.node.start); End: $($item.node.end)."
    $startSeconds = [double]$item.node.start
    $endSeconds = [double]$item.node.end
    $code = $item.node.code
   
    if (IsMatch -Node $item.node -Start $Start -End $End -Filter $Filter) {
        
        $newStart = ($startSeconds + $Value).ToString()
        $newEnd = ($endSeconds + $Value).ToString()
        Write-Host "Old: Start: $startSeconds; End: $endSeconds;. New: Start: $newStart; End: $newEnd;  Code: $code"
       
        $item.node.start = $newStart
        $item.node.end = $newEnd
    }
}


$NewPath = "$env:temp\updated.xml"
Write-Host $NewPath
$xml.Save($NewPath)
code-insiders $NewPath
