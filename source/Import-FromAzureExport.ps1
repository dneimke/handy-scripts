
param (
    [String]$Path = $(throw "A Path was not supplied"),
    [String]$DbName = $(throw "A DbName was not supplied"),
    [String]$Username = $(throw "A Username was not supplied")
)

function Import-FromAzureExport {
    <#
        .SYNOPSIS
        Automates the process of restoring Azure exported database files into a LocalDb instance
    
        .DESCRIPTION
        Prior to running this script, go to your Azure SqlServer instance, select your desired database
        and run an Export job.  This will export the database to a storage file as a .bacpac.

        Download the .bacpac file and run the script to import it into a LocalDb instance

        .EXAMPLE
        .\Import-FromAzureExport.ps1 -Path \Downloads\somedb-2018-3-30-14-16.bacpac -DbName "yourdb" -Username "auser"
        Creates a database if required and restores the bacpac into it

    #>
    [CmdletBinding(
        ConfirmImpact = 'Medium',
        SupportsShouldProcess = $true
    )]
    param (
        [String]$Path = $(throw "A Path was not supplied"),
        [String]$DbName = $(throw "A DbName was not supplied"),
        [String]$Username = $(throw "A Username was not supplied")
    )

    $Password = Read-Host -Prompt "Enter password" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null 

    $localDBInstance = "MSSQLLocalDB"
    Invoke-Expression "SQLLocalDB create `"$($localDBInstance)`""

    Write-Host "------ Servers --------"

    Invoke-Expression "SQLLocalDB i"

    $sqlServer = new-object ("Microsoft.SqlServer.Management.Smo.Server") "(localdb)\MSSQLLocalDB"

    Write-Host "------ Databases --------"

    ForEach ($sqlDatabase in $sqlServer.Databases) {$sqlDatabase.name}

    $db = $sqlServer.Databases[$DbName]

    If ($null -eq $db) {
        $db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -ArgumentList $sqlServer, $DbName  
        $db.Create()
    }

    Write-Host "====="  
    Write-Host "Login Mappings for the database: "+ $db.Name  
    
    $dt = $db.EnumLoginMappings()  

    # Display the results  
    ForEach ($row in $dt.Rows) {  
        ForEach ($col in $row.Table.Columns) {  
            $col.ColumnName + "=" + $row[$col]  
        } 
    }  

    # May need to create a Login if it doesn't already exist
    If ($false) {
        # Write-Host "------- Creating Login -------"
        $Login = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList $SqlServer, "$Username"
        $Login.LoginType = 'SqlLogin'
        $Login.Create($PlainPassword)
        $Login.AddToRole('dbo')

        # Write-Host "------- Adding User -------"
        # $User = New-Object -TypeName Microsoft.SqlServer.Management.Smo.User -ArgumentList $db, $Username
        # $User.Login = $Username
        # $User.Create()
    }

    If ($PSCmdlet.ShouldProcess("ShouldProcess?")) {
        $Command = "SqlPackage.exe"
        $Params = "/Action:Import /SourceFile:$Path /TargetConnectionString:""Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=$DbName; Integrated Security=true;"""

        $Prms = $Params.Split(" ")

        & $Command $Prms 
    }
}

Import-FromAzureExport -Path $Path -DbName $DbName -Username $Username
