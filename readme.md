# Readme

Handy-Scripts is a repository for storing useful scripts for doing repetitive tasks.  These tasks might include combining 2 videos, restoring an Azure database from a .bacpac file, or even something as simple as making a HTTP GET Request.

## FFMpeg

The FFMpeg utility commands allow you to 

* Convert-VideoSize - uses ffmpeg to compress a video to 1080p
* Combine-Video - combines all video files for a specified format within a folder into a single output video file
* New-ClipsVideo - takes a [Matchlib.com](https://matchlib.com) data payload and uses it to generate video clips from a source video file

## SportsCode XML

The SportsCode XML commands are useful when you need to manipulate data files and don't have access to the SportsCode tooling. 

* **Combine-Events** - combines events from 2 SportsCode Xml files based on Time-Offset for the 2nd file.  This is useful if you code 2 separate iCoda periods and then need to combine them into a single file to import into Hudl.
* **Combine-EventsFromMetadata** - similar to Combine-Events but this version takes a configuration file and can combine any number of files.  This version relies on ff-mpeg as a dependency and uses the length of an associated video file to calculate the offset in time for each subsequent XML data file.
* **Move-Events** - allows user to modify a SportsCode events file using targeted queries

**EXAMPLES**

Moves all events backward by 364 seconds that are after 2300 seconds 

```powershell
Move-Events -Path './YourSportscodeFile.xml' -Value -364 -Start 2300
```

Moves all events in the **Outlet** code forward by 20 seconds that are between 3 and 200 seconds 

```powershell
Move-Events -Path './YourSportscodeFile.xml' -Start 3 -End 200 -Value 20 -Filter Outlet
```

Combines 2 files with an offset of 600 seconds (10 minutes) for the 2nd file's events 

```powershell
Combine-Events -Path1 './Match1.xml' -Path2 './Match2.xml' -Offset 600
```

Combines files based on an input configuration file (refer below for format of input configuration file)

```powershell
Combine-EventsFromMetadata -Payload 'Payload.json'
```

Input configuration file example:

```json
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
```

## Databases

* Import-FromAzureExport - imports an export of an Azure database into a LocalDb instance

## Useful Links

* [Approved Verbs for Windows PowerShell Commands](https://msdn.microsoft.com/en-us/library/ms714428)
* [Strongly Encouraged Development Guidelines](https://msdn.microsoft.com/en-us/library/dd878270)
* [Download ffMpeg](https://www.ffmpeg.org/download.html)


## Meta

Darren Neimke – [@digory](https://twitter.com/digory)

Distributed under the MIT license. See [LICENSE](https://github.com/dneimke/handy-scripts/blob/master/LICENSE) for more information.



## Contributing

1. Fork it (<https://github.com/yourname/yourproject/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request
