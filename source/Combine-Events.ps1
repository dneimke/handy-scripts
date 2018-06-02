<#

.SYNOPSIS
Combines events in two SportsCode Xml data files

.DESCRIPTION
Combine events from 2 SportsCode Xml files based on Time-Offset for the 2nd file

.EXAMPLE
Combines 2 files with an offset of 600 seconds (10 minutes) for the 2nd file's events 
.\Combine-Events.ps1 -Path1 ./Match1.xml -Path2 ./Match2.xml -Offset 600

.PARAMETER Path1
The relative path to the first data file

.PARAMETER Path2
The relative path to the second data file

.PARAMETER Offset
Number of seconds to offset for the second file's events

.PARAMETER Verbose

#>

param
(
    [Parameter(Mandatory = $True)]
    [ValidateScript( {
            if ( -Not ($_ | Test-Path) ) {
                throw "File 1 does not exist"
            }
            if (-Not ($_ | Test-Path -PathType Leaf) ) {
                throw "The Path argument for File 1 must be a file. Folder paths are not allowed."
            }
            if ($_ -notmatch "(\.xml)") {
                throw "The file specified in the path argument must be of type xml"
            }
            return $true
        })]
    [System.IO.FileInfo]$Path1,
    [Parameter(Mandatory = $True)]
    [ValidateScript( {
            if ( -Not ($_ | Test-Path) ) {
                throw "File 1 does not exist"
            }
            if (-Not ($_ | Test-Path -PathType Leaf) ) {
                throw "The Path argument for File 1 must be a file. Folder paths are not allowed."
            }
            if ($_ -notmatch "(\.xml)") {
                throw "The file specified in the path argument must be of type xml"
            }
            return $true
        })]
    [System.IO.FileInfo]$Path2,
    [Parameter(Mandatory = $True)]
    [int]$Offset
)

Write-Verbose "Processing $($Path1), $($Path2) with Offset $($Offset)"

$xml1 = New-Object -TypeName XML
$xml1.Load($Path1)

$xml2 = New-Object -TypeName XML
$xml2.Load($Path2)

$counter = (Select-Xml -Xml $xml1 -XPath "//instance").Count

# <instance>
#     <ID>1</ID>
#     <start>0.00</start>
#     <end>6.83</end>
#     <code>Goal Shot</code>
#     <label>
#         <group>Goal Shot</group>
#         <text>Difficult</text>
#     </label>
# </instance>

foreach ($item in (Select-Xml -Xml $xml2 -XPath "//instance")) {
    $startSeconds = [double]$item.node.start
    $endSeconds = [double]$item.node.end
    $code = $item.node.code
   
    $newStart = ($startSeconds + $Offset).ToString()
    $newEnd = ($endSeconds + $Offset).ToString()
    
    $item.node.ID = (++$counter).ToString()
    $item.node.start = $newStart
    $item.node.end = $newEnd

    $doc = New-Object -TypeName XML
    $doc.LoadXml($item.node.OuterXml)
    $node = $doc.DocumentElement;  

    Write-Verbose "Old: Start: $startSeconds; End: $endSeconds; New: Start: $newStart; End: $newEnd;  Code: $code"

    $e = $xml1.ImportNode($node, $true);
    $xml1.file.ALL_INSTANCES.AppendChild($e) | out-null
}

$NewPath = "$env:temp\combined.xml"
Write-Verbose $NewPath
$xml1.Save($NewPath)
code-insiders $NewPath

return $NewPath
