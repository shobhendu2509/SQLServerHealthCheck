function Get-DbaMaintenanceSolutionLog {
    <#
    .SYNOPSIS
        Reads the log files generated by the IndexOptimize Agent Job from Ola Hallengren's MaintenanceSolution.

    .DESCRIPTION
        Ola wrote a .sql script to get the content from the commandLog table. However, if LogToTable='N', there will be no logging in that table. This function reads the text files that are written in the SQL Instance's Log directory.

    .PARAMETER SqlInstance
        The target SQL Server instance or instances.

    .PARAMETER SqlCredential
        Login to the target instance using alternative credentials. Windows and SQL Authentication supported. Accepts credential objects (Get-Credential)

    .PARAMETER LogType
        Accepts 'IndexOptimize', 'DatabaseBackup', 'DatabaseIntegrityCheck'. ATM only IndexOptimize parsing is available

    .PARAMETER Since
        Consider only files generated since this date

    .PARAMETER Path
        Where to search for log files. By default it's the SQL instance errorlogpath path

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .NOTES
        Tags: Ola, Maintenance
        Author: Klaas Vandenberghe (@powerdbaklaas) | Simone Bizzotto ( @niphlod )

        Website: https://dbatools.io
        Copyright: (c) 2018 by dbatools, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT

    .LINK
        https://dbatools.io/Get-DbaMaintenanceSolutionLog

    .EXAMPLE
        PS C:\> Get-DbaMaintenanceSolutionLog -SqlInstance sqlserver2014a

        Gets the outcome of the IndexOptimize job on sql instance sqlserver2014a.

    .EXAMPLE
        PS C:\> Get-DbaMaintenanceSolutionLog -SqlInstance sqlserver2014a -SqlCredential $credential

        Gets the outcome of the IndexOptimize job on sqlserver2014a, using SQL Authentication.

    .EXAMPLE
        PS C:\> 'sqlserver2014a', 'sqlserver2020test' | Get-DbaMaintenanceSolutionLog

        Gets the outcome of the IndexOptimize job on sqlserver2014a and sqlserver2020test.

    .EXAMPLE
        PS C:\> Get-DbaMaintenanceSolutionLog -SqlInstance sqlserver2014a -Path 'D:\logs\maintenancesolution\'

        Gets the outcome of the IndexOptimize job on sqlserver2014a, reading the log files in their custom location.

    .EXAMPLE
        PS C:\> Get-DbaMaintenanceSolutionLog -SqlInstance sqlserver2014a -Since '2017-07-18'

        Gets the outcome of the IndexOptimize job on sqlserver2014a, starting from july 18, 2017.

    .EXAMPLE
        PS C:\> Get-DbaMaintenanceSolutionLog -SqlInstance sqlserver2014a -LogType IndexOptimize

        Gets the outcome of the IndexOptimize job on sqlserver2014a, the other options are not yet available! sorry

#>
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstanceParameter[]]$SqlInstance,
        [Alias("Credential")]
        [PSCredential]$SqlCredential,
        [ValidateSet('IndexOptimize', 'DatabaseBackup', 'DatabaseIntegrityCheck')]
        [string[]]$LogType = 'IndexOptimize',
        [datetime]$Since,
        [string]$Path,
        [Alias('Silent')]
        [switch]$EnableException
    )
    begin {
        function process-block ($block) {
            $fresh = @{
                'ObjectType'     = $null
                'IndexType'      = $null
                'ImageText'      = $null
                'NewLOB'         = $null
                'FileStream'     = $null
                'ColumnStore'    = $null
                'AllowPageLocks' = $null
                'PageCount'      = $null
                'Fragmentation'  = $null
                'Error'          = $null
            }
            foreach ($l in $block) {
                $splitted = $l -split ': ', 2
                if (($splitted.Length -ne 2) -or ($splitted[0].length -gt 20)) {
                    if ($null -eq $fresh['Error']) {
                        $fresh['Error'] = New-Object System.Collections.ArrayList
                    }
                    $null = $fresh['Error'].Add($l)
                    continue
                }
                $k = $splitted[0]
                $v = $splitted[1]
                if ($k -eq 'Date and Time') {
                    # this is the end date, we already parsed the start date of the block
                    if ($fresh.ContainsKey($k)) {
                        continue
                    }
                }
                $fresh[$k] = $v
            }
            if ($fresh.ContainsKey('Command')) {
                if ($fresh['Command'] -match '(SET LOCK_TIMEOUT (?<timeout>\d+); )?ALTER INDEX \[(?<index>[^\]]+)\] ON \[(?<database>[^\]]+)\]\.\[(?<schema>[^]]+)\]\.\[(?<table>[^\]]+)\] (?<action>[^\ ]+)( PARTITION = (?<partition>\d+))? WITH \((?<options>[^\)]+)') {
                    $fresh['Index'] = $Matches.index
                    $fresh['Statistics'] = $null
                    $fresh['Schema'] = $Matches.Schema
                    $fresh['Table'] = $Matches.Table
                    $fresh['Action'] = $Matches.action
                    $fresh['Options'] = $Matches.options
                    $fresh['Timeout'] = $Matches.timeout
                    $fresh['Partition'] = $Matches.partition
                } elseif ($fresh['Command'] -match '(SET LOCK_TIMEOUT (?<timeout>\d+); )?UPDATE STATISTICS \[(?<database>[^\]]+)\]\.\[(?<schema>[^]]+)\]\.\[(?<table>[^\]]+)\] \[(?<stat>[^\]]+)\]') {
                    $fresh['Index'] = $null
                    $fresh['Statistics'] = $Matches.stat
                    $fresh['Schema'] = $Matches.Schema
                    $fresh['Table'] = $Matches.Table
                    $fresh['Action'] = $null
                    $fresh['Options'] = $null
                    $fresh['Timeout'] = $Matches.timeout
                    $fresh['Partition'] = $null
                }
            }
            if ($fresh.ContainsKey('Comment')) {
                $commentparts = $fresh['Comment'] -split ', '
                foreach ($part in $commentparts) {
                    $indkey, $indvalue = $part -split ': ', 2
                    if ($fresh.ContainsKey($indkey)) {
                        $fresh[$indkey] = $indvalue
                    }
                }
            }
            if ($null -ne $fresh['Error']) {
                $fresh['Error'] = $fresh['Error'] -join "`n"
            }

            return $fresh
        }
    }
    process {
        foreach ($instance in $sqlinstance) {
            $logdir = $logfiles = $null
            $computername = $instance.ComputerName

            try {
                $server = Connect-SqlInstance -SqlInstance $instance -SqlCredential $sqlcredential
            } catch {
                Stop-Function -Message "Can't connect to $instance" -Category ConnectionError -ErrorRecord $_ -Target $instance -Continue
            }
            if ($logtype -ne 'IndexOptimize') {
                Write-Message -Level Warning -Message "Parsing $logtype is not supported at the moment"
                Continue
            }
            if ($Path) {
                $logdir = Join-AdminUnc -Servername $server.ComputerName -Filepath $Path
            } else {
                $logdir = Join-AdminUnc -Servername $server.ComputerName -Filepath $server.errorlogpath # -replace '^(.):', "\\$computername\`$1$"
            }
            if (!$logdir) {
                Write-Message -Level Warning -Message "No log directory returned from $instance"
                Continue
            }

            Write-Message -Level Verbose -Message "Log directory on $computername is $logdir"
            if (! (Test-Path $logdir)) {
                Write-Message -Level Warning -Message "Directory $logdir is not accessible"
                continue
            }
            $logfiles = [System.IO.Directory]::EnumerateFiles("$logdir", "IndexOptimize_*.txt")
            if ($Since) {
                $filteredlogs = @()
                foreach ($l in $logfiles) {
                    $base = $($l.Substring($l.Length - 15, 15))
                    try {
                        $datefile = [DateTime]::ParseExact($base, 'yyyyMMdd_HHmmss', $null)
                    } catch {
                        $datefile = Get-ItemProperty -Path $l | Select-Object -ExpandProperty CreationTime
                    }
                    if ($datefile -gt $since) {
                        $filteredlogs += $l
                    }
                }
                $logfiles = $filteredlogs
            }
            if (! $logfiles.count -ge 1) {
                Write-Message -Level Warning -Message "No log files returned from $computername"
                Continue
            }
            $instanceinfo = @{ }
            $instanceinfo['ComputerName'] = $server.ComputerName
            $instanceinfo['InstanceName'] = $server.ServiceName
            $instanceinfo['SqlInstance'] = $server.Name

            foreach ($File in $logfiles) {
                Write-Message -Level Verbose -Message "Reading $file"
                $text = New-Object System.IO.StreamReader -ArgumentList "$File"
                $block = New-Object System.Collections.ArrayList
                $remember = @{}
                while ($line = $text.ReadLine()) {

                    $real = $line.Trim()
                    if ($real.Length -eq 0) {
                        $processed = process-block $block
                        if ('Procedure' -in $processed.Keys) {
                            $block = New-Object System.Collections.ArrayList
                            continue
                        }
                        if ('Database' -in $processed.Keys) {
                            Write-Message -Level Verbose -Message "Index and Stats Optimizations on Database $($processed.Database) on $computername"
                            $processed.Remove('Is accessible')
                            $processed.Remove('User access')
                            $processed.Remove('Date and time')
                            $processed.Remove('Standby')
                            $processed.Remove('Recovery Model')
                            $processed.Remove('Updateability')
                            $processed['Database'] = $processed['Database'].Trim('[]')
                            $remember = $processed.Clone()
                        } else {
                            foreach ($k in $processed.Keys) {
                                $remember[$k] = $processed[$k]
                            }
                            $remember.Remove('Command')
                            $remember['StartTime'] = [dbadatetime]([DateTime]::ParseExact($remember['Date and time'] , "yyyy-MM-dd HH:mm:ss", $null))
                            $remember.Remove('Date and time')
                            $remember['Duration'] = ($remember['Duration'] -as [timespan])
                            [pscustomobject]$remember
                        }
                        $block = New-Object System.Collections.ArrayList
                    } else {
                        $null = $block.Add($real)
                    }
                }
                $text.close()
            }
        }
    }
}

