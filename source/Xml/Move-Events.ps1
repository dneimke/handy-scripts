<#

.SYNOPSIS
Moves events in a SportsCode Xml data file

.DESCRIPTION
Move all or just a subset of events based on Time-Start, Time-End, Filter

.EXAMPLE
Move-Events -Path ./Match1.xml -Start 3 -End 200 -Value 20 -Filter Outlet
This command moves all events in the Outlet code forward by 20 seconds that are between 3 and 200 seconds 

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


    if ($Start -gt 0 -and ($Node.start -lt $Start -or $Node.end -lt $Start)) {
        # Write-Host "False Start: $Start; Node Start: $($Node.start); Node End: $($Node.end)"
        return $false
    }

    if ($End -gt 0 -and ($Node.start -gt $End -or $Node.end -gt $End)) {
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

    $startSeconds = $item.node.start
    $endSeconds = $item.node.end
    $code = $item.node.code
   
    if (IsMatch -Node $item.node -Start $Start -End $End -Filter $Filter) {
        
        Write-Host "Start: $startSeconds; End: $endSeconds; Code: $code"
       
        $item.node.start = $startSeconds + $Value
        $item.node.end = $endSeconds + $Value
    }
}


$NewPath = "$env:temp\updated.xml"
Write-Host $NewPath
$xml.Save($NewPath)
code-insiders $NewPath
