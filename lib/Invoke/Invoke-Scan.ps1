# Invoke-Scan.ps1
. "lib\Functions\UseHashBase.ps1"
. "lib\Actions\Action-Scan.ps1"
. "lib\Functions\Utils.ps1"
. "lib\Actions\Action-Yara.ps1"
. "lib\Actions\Action-VirusTotal.ps1"


function Invoke-Scan {
    param(
        [Parameter(Mandatory)]
        [object]$Config,

        [Parameter(Mandatory)]
        [string]$In,

        [Parameter(Mandatory)]
        [string]$YaraScan,

        [Parameter(Mandatory)]
        [string]$Vt,

        [Parameter(Mandatory)]
        [string]$Out,

        [Parameter(Mandatory)]
        [string]$Report
    )

    Write-Debug "Path monitored : $($Config.DefaultPaths -join ', ')"

    $OldHashes = LoadHashBase -FilePath $In
    $NewsHashes = GetFileHashesRecursive -Config $Config
    $Differences = CompareHashesRecursive -OldHashes $OldHashes -NewHashes $NewsHashes

    Write-Debug "`nDifferences founds :" 
    
    if ($Differences.Count -ne 0) {
        PrintDiff -Differences $Differences 
    }

    if (-not $Differences -or $Differences.Count -eq 0 -or $null -eq $Differences) {
        Write-Warning "No files found."
        return
    }

    Save-HashBase -Results $Differences -OutPath $Out

    Write-Debug "Successfully build Report of $($Differences.Count) files."

    ##########################################
    ##              YaraScan                ##
    ##########################################
    if ( $YaraScan -eq "True" ) {  # if -YaraScan flag
        $suspiciousFiles = $Differences | Where-Object { $_.Status -in @('new', 'modified') }
        Write-host "Launching yara investigations on $($suspiciousFiles.Count) files" 
        
        $yaraResults = @()
        foreach ($file in $suspiciousFiles) {
            $scanResult = Invoke-YaraScan -YaraBinary $Config.YaraConf.YaraBinaryPath -RulesDirectory $Config.YaraConf.YaraRulesPath -TargetPath $file.Path
            $yaraResults += $scanResult

            # advanced yara debug
            #YaraDebug -scanResult $scanResult


        }#<- comment this
 
            # if you see error in yarascan or the same hash continuously sent to virustotal, uncomment this and read the output to debug
        #    if ($scanResult.HasDetections) {
        #        Write-Debug "DETECTION: $([System.IO.Path]::GetFileName($scanResult.TargetPath))"  
        #        $scanResult.RuleMatches | ForEach-Object { Write-Debug "  Rule: $($_.Rule)"}
        #    } elseif ($scanResult.Errors.Count -gt 0) {
        #        Write-Debug " Error on $([System.IO.Path]::GetFileName($scanResult.TargetPath)): $($scanResult.Errors[0])"  
        #    }
        #}

        # Build Report   
        $report = BuildReport -Differences $Differences -YaraResults $yaraResults -Config $Config -OutputPath $Out -ReportType $Config.ReportsTemplate
        
        # print report in console
        #Write-Debug "New: $($report.Summary.NewFiles) | Modifies: $($report.Summary.ModifiedFiles) | Supprimes: $($report.Summary.DeletedFiles)"  
        
        #yara errors debug
        #write-Host "Yara - Detections: $($report.Summary.YaraDetections) | Errors: $($report.Summary.YaraErrors)"    

        if ($Vt -eq "True" -and $Config.VirusTotalApiKey) { # if we have -Vt flag and key provided
            $suspiciousHashes = $Differences | Where-Object { $_.Status -in @('new', 'modified') -and $_.Hash } | Select-Object -ExpandProperty Hash
            try { # if file is locked or in anormal state
                Write-Debug "`nLaunching VirusTotal scan on $($suspiciousHashes.Count) file(s)..."
                $vtResults = Invoke-VirusTotalScan -Hash $suspiciousHashes -ApiKey $Config.VirusTotalApiKey
                #Write-Debug "" .$vtResults # debug
            }
            catch {
                Write-Debug "No files to analyze or all files are locked by another program. Skipping VirusTotal scan & report.."
                exit 0
            }
            Write-Debug "Building virustotal report...."
            $report = BuildReport -Differences $Differences -YaraResults $yaraResults -Config $Config -VtResults $vtResults -OutputPath $Out -ReportType $Config.ReportsTemplate
        } elseif ($Vt -eq "True" -and $Config.VirusTotalApiKey::IsNullOrEmpty) { #if no key
            Write-Error "VirusTotal API KEY Needed If -Vt used"
        }

        #### alternativ usage of Invoke-VirusTotalScan ###
        # hash
        #$vtResults = Invoke-VirusTotalScan -Hash @("abc123...", "def456...") -ApiKey "your_api_key"

        # file (lookup only)
        #$vtResults = Invoke-VirusTotalScan -FilePath @("C:\file1.exe", "C:\file2.dll") -ApiKey "your_api_key"

        # file with upload
        #$vtResults = Invoke-VirusTotalScan -FilePath @("C:\suspect.exe") -ApiKey "your_api_key" -UploadFile
    } else {
        Write-warning "Unable to start YaraScan & VirusTotal scan: Rules folder does not exist or is empty, please check if you have an index.yar."
    }
}



