function Set-DbaTempdbConfig {
    <#
    .SYNOPSIS
        Sets tempdb data and log files according to best practices.

    .DESCRIPTION
        Calculates tempdb size and file configurations based on passed parameters, calculated values, and Microsoft best practices. User must declare SQL Server to be configured and total data file size as mandatory values. Function then calculates the number of data files based on logical cores on the target host and create evenly sized data files based on the total data size declared by the user, with a log file 25% of the total data file size.

        Other parameters can adjust the settings as the user desires (such as different file paths, number of data files, and log file size). No functions that shrink or delete data files are performed. If you wish to do this, you will need to resize tempdb so that it is "smaller" than what the function will size it to before running the function.

    .PARAMETER SqlInstance
        The target SQL Server instance or instances.

    .PARAMETER SqlCredential
        Login to the target instance using alternative credentials. Windows and SQL Authentication supported. Accepts credential objects (Get-Credential)

    .PARAMETER DataFileCount
        Specifies the number of data files to create. If this number is not specified, the number of logical cores of the host will be used.

    .PARAMETER DataFileSizeMB
        Specifies the total data file size in megabytes. This is distributed across the total number of data files.

    .PARAMETER LogFileSizeMB
        Specifies the log file size in megabytes. If not specified, this will be set to 25% of total data file size.

    .PARAMETER DataFileGrowthMB
        Specifies the growth amount for the data file(s) in megabytes. The default is 512 MB.

    .PARAMETER LogFileGrowthMB
        Specifies the growth amount for the log file in megabytes. The default is 512 MB.

    .PARAMETER DataPath
        Specifies the filesystem path in which to create the tempdb data files. If not specified, current tempdb location will be used.

    .PARAMETER LogPath
        Specifies the filesystem path in which to create the tempdb log file. If not specified, current tempdb location will be used.

    .PARAMETER OutputScriptOnly
        If this switch is enabled, only the T-SQL script to change the tempdb configuration is created and output.

    .PARAMETER OutFile
        Specifies the filesystem path into which the generated T-SQL script will be saved.

    .PARAMETER DisableGrowth
        If this switch is enabled, the tempdb files will be configured to not grow. This overrides -DataFileGrowthMB and -LogFileGrowthMB.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .NOTES
        Tags: Tempdb, Space, Configure, Configuration
        Author: Michael Fal (@Mike_Fal), http://mikefal.net

        Website: https://dbatools.io
        Copyright: (c) 2018 by dbatools, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT

    .LINK
        https://dbatools.io/Set-DbaTempdbConfig

    .EXAMPLE
        PS C:\> Set-DbaTempdbConfig -SqlInstance localhost -DataFileSizeMB 1000

        Creates tempdb with a number of data files equal to the logical cores where each file is equal to 1000MB divided by the number of logical cores, with a log file of 250MB.

    .EXAMPLE
        PS C:\> Set-DbaTempdbConfig -SqlInstance localhost -DataFileSizeMB 1000 -DataFileCount 8

        Creates tempdb with 8 data files, each one sized at 125MB, with a log file of 250MB.

    .EXAMPLE
        PS C:\> Set-DbaTempdbConfig -SqlInstance localhost -DataFileSizeMB 1000 -OutputScriptOnly

        Provides a SQL script output to configure tempdb according to the passed parameters.

    .EXAMPLE
        PS C:\> Set-DbaTempdbConfig -SqlInstance localhost -DataFileSizeMB 1000 -DisableGrowth

        Disables the growth for the data and log files.

    .EXAMPLE
        PS C:\> Set-DbaTempdbConfig -SqlInstance localhost -DataFileSizeMB 1000 -OutputScriptOnly

        Returns the T-SQL script representing tempdb configuration.

#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [parameter(Mandatory)]
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstanceParameter]$SqlInstance,
        [PSCredential]$SqlCredential,
        [int]$DataFileCount,
        [Parameter(Mandatory)]
        [int]$DataFileSizeMB,
        [int]$LogFileSizeMB,
        [int]$DataFileGrowthMB = 512,
        [int]$LogFileGrowthMB = 512,
        [string]$DataPath,
        [string]$LogPath,
        [string]$OutFile,
        [switch]$OutputScriptOnly,
        [switch]$DisableGrowth,
        [Alias('Silent')]
        [switch]$EnableException
    )
    begin {
        $sql = @()
        $server = Connect-SqlInstance $sqlinstance -SqlCredential $SqlCredential

        if ($server.VersionMajor -lt 9) {
            Stop-Function -Message "SQL Server 2000 is not supported"
            return
        }
    }

    process {

        if (Test-FunctionInterrupt) {
            return
        }

        $cores = $server.Processors
        if ($cores -gt 8) {
            $cores = 8
        }

        #Set DataFileCount if not specified. If specified, check against best practices.
        if (-not $DataFileCount) {
            $DataFileCount = $cores
            Write-Message -Message "Data file count set to number of cores: $DataFileCount" -Level Verbose
        } else {
            if ($DataFileCount -gt $cores) {
                Write-Message -Message "Data File Count of $DataFileCount exceeds the Logical Core Count of $cores. This is outside of best practices." -Level Warning
            }
            Write-Message -Message "Data file count set explicitly: $DataFileCount" -Level Verbose
        }

        $DataFilesizeSingleMB = $([Math]::Floor($DataFileSizeMB / $DataFileCount))
        Write-Message -Message "Single data file size (MB): $DataFilesizeSingleMB." -Level Verbose

        if ($DataPath) {
            if ((Test-DbaPath -SqlInstance $server -Path $DataPath) -eq $false) {
                Stop-Function -Message "$datapath is an invalid path."
                return
            }
        } else {
            $Filepath = $server.Databases['tempdb'].ExecuteWithResults('SELECT physical_name as FileName FROM sys.database_files WHERE file_id = 1').Tables[0].Rows[0].FileName
            $DataPath = Split-Path $Filepath
        }

        Write-Message -Message "Using data path: $datapath." -Level Verbose

        if ($LogPath) {
            if ((Test-DbaPath -SqlInstance $server -Path $LogPath) -eq $false) {
                Stop-Function -Message "$LogPath is an invalid path."
                return
            }
        } else {
            $Filepath = $server.Databases['tempdb'].ExecuteWithResults('SELECT physical_name as FileName FROM sys.database_files WHERE file_id = 2').Tables[0].Rows[0].FileName
            $LogPath = Split-Path $Filepath
        }
        Write-Message -Message "Using log path: $LogPath." -Level Verbose

        # Check if the file growth needs to be disabled
        if ($DisableGrowth) {
            $DataFileGrowthMB = 0
            $LogFileGrowthMB = 0
        }

        # Check current tempdb. Throw an error if current tempdb is larger than config.
        $CurrentFileCount = $server.Databases['tempdb'].ExecuteWithResults('SELECT count(1) as FileCount FROM sys.database_files WHERE type=0').Tables[0].Rows[0].FileCount
        $TooBigCount = $server.Databases['tempdb'].ExecuteWithResults("SELECT TOP 1 (size/128) as Size FROM sys.database_files WHERE size/128 > $DataFilesizeSingleMB AND type = 0").Tables[0].Rows[0].Size

        if ($CurrentFileCount -gt $DataFileCount) {
            Stop-Function -Message "Current tempdb not suitable to be reconfigured. The current tempdb has a greater number of files ($CurrentFileCount) than the calculated configuration ($DataFileCount)."
            return
        }

        if ($TooBigCount) {
            Stop-Function -Message "Current tempdb not suitable to be reconfigured. The current tempdb ($TooBigCount MB) is larger than the calculated individual file configuration ($DataFilesizeSingleMB MB)."
            return
        }

        $EqualCount = $server.Databases['tempdb'].ExecuteWithResults("SELECT count(1) as FileCount FROM sys.database_files WHERE size/128 = $DataFilesizeSingleMB AND type = 0").Tables[0].Rows[0].FileCount

        if ($EqualCount -gt 0) {
            Stop-Function -Message "Current tempdb not suitable to be reconfigured. The current tempdb is the same size as the specified DataFileSizeMB."
            return
        }

        Write-Message -Message "tempdb configuration validated." -Level Verbose

        $DataFiles = $server.Databases['tempdb'].ExecuteWithResults("select f.name as Name, f.physical_name as FileName from sys.filegroups fg join sys.database_files f on fg.data_space_id = f.data_space_id where fg.name = 'PRIMARY' and f.type_desc = 'ROWS'").Tables[0];

        #Checks passed, process reconfiguration
        for ($i = 0; $i -lt $DataFileCount; $i++) {
            $File = $DataFiles.Rows[$i]
            if ($File) {
                $Filename = Split-Path $File.FileName -Leaf
                $LogicalName = $File.Name
                $NewPath = "$datapath\$Filename"
                $sql += "ALTER DATABASE tempdb MODIFY FILE(name=$LogicalName,filename='$NewPath',size=$DataFilesizeSingleMB MB,filegrowth=$DataFileGrowthMB);"
            } else {
                $NewName = "tempdev$i.ndf"
                $NewPath = "$datapath\$NewName"
                $sql += "ALTER DATABASE tempdb ADD FILE(name=tempdev$i,filename='$NewPath',size=$DataFilesizeSingleMB MB,filegrowth=$DataFileGrowthMB);"
            }
        }

        if (-not $LogFileSizeMB) {
            $LogFileSizeMB = [Math]::Floor($DataFileSizeMB / 4)
        }

        $logfile = $server.Databases['tempdb'].ExecuteWithResults("SELECT name, physical_name as FileName FROM sys.database_files WHERE file_id = 2").Tables[0].Rows[0];
        $Filename = Split-Path $logfile.FileName -Leaf
        $LogicalName = $logfile.Name
        $NewPath = "$LogPath\$Filename"
        $sql += "ALTER DATABASE tempdb MODIFY FILE(name=$LogicalName,filename='$NewPath',size=$LogFileSizeMB MB,filegrowth=$LogFileGrowthMB);"

        Write-Message -Message "SQL Statement to resize tempdb." -Level Verbose
        Write-Message -Message ($sql -join "`n`n") -Level Verbose

        if ($OutputScriptOnly) {
            return $sql
        } elseif ($OutFile) {
            $sql | Set-Content -Path $OutFile
        } else {
            if ($Pscmdlet.ShouldProcess($SqlInstance, "Executing query and informing that a restart is required.")) {
                try {
                    $server.Databases['master'].ExecuteNonQuery($sql)
                    Write-Message -Level Verbose -Message "tempdb successfully reconfigured."

                    [PSCustomObject]@{
                        ComputerName         = $server.ComputerName
                        InstanceName         = $server.ServiceName
                        SqlInstance          = $server.DomainInstanceName
                        DataFileCount        = $DataFileCount
                        DataFileSizeMB       = $DataFileSizeMB
                        SingleDataFileSizeMB = $DataFilesizeSingleMB
                        LogSizeMB            = $LogFileSizeMB
                        DataPath             = $DataPath
                        LogPath              = $LogPath
                        DataFileGrowthMB     = $DataFileGrowthMB
                        LogFileGrowthMB      = $LogFileGrowthMB
                    }

                    Write-Message -Level Output -Message "tempdb reconfigured. You must restart the SQL Service for settings to take effect."
                } catch {
                    Stop-Function -Message "Unable to reconfigure tempdb. Exception: $_" -Target $sql -InnerErrorRecord $_
                    return
                }
            }
        }
    }
    end {
        Test-DbaDeprecation -DeprecatedOn "1.0.0" -EnableException:$false -Alias Set-SqlTempDbConfiguration
        Test-DbaDeprecation -DeprecatedOn "1.0.0" -EnableException:$false -Alias Set-DbaTempDbConfiguration
    }
}

