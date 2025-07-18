function LoadConfig {
    <#
    .SYNOPSIS
        Loads hScan configuration from PowerShell configuration file.

    .DESCRIPTION
        Validates configuration file existence and executes it to load settings.
        The configuration file contains default paths, hash algorithms, limits,
        supported formats, logging settings, and report templates.

    .PARAMETER configPath
        [Optional] Path to configuration file. Default: ".\config.ps1"
        Must be a valid PowerShell script containing configuration variables.

    .EXAMPLE
        $config = LoadConfig
        Loads configuration from default path ".\config.ps1".

    .EXAMPLE
        $config = LoadConfig -configPath ".\config.ps1"
        Loads configuration from custom path.

    .NOTES
        - Validates configuration file existence before loading
        - Executes configuration script to return configuration object
        - Exits with code 1 if configuration file not found
        - Configuration file must contain valid PowerShell syntax

    .OUTPUTS
        Configuration object containing hScan settings and parameters
    #>

    param (
        [string]$configPath = ".\config.ps1"
    )

    if (Test-Path $configPath) {
        $config = & $configPath
        return $config
    } else {
        Write-Host "ERREUR: Can't access configuration file" -ForegroundColor Red
        exit 1
    }
}

function Show-Help {
    <#
    .SYNOPSIS
        Displays hScan usage information and command syntax.

    .DESCRIPTION
        Shows formatted help text with available actions, options, and usage examples.
        Provides quick reference for command-line usage of hScan module.

    .EXAMPLE
        Show-Help
        Displays complete usage information and examples.

    .NOTES
        - Called automatically when "help" action is specified
        - Displays actions: build, scan, help
        - Shows all available options and parameters
        - Includes practical usage examples

    .OUTPUTS
        Formatted help text to console
    #>

    #Show-hScanBannerAnimated
    Write-Host ""
    Write-Host "    +==============================================================+" -ForegroundColor DarkBlue
    Write-Host "    |                       hScan v1.0.0                        |" -ForegroundColor Cyan
    Write-Host "    |                   Hash Scanner & Monitor                   |" -ForegroundColor White
    Write-Host "    +==============================================================+" -ForegroundColor DarkBlue
    Write-Host ""
    Write-Host "    USAGE: .\main.ps1 <action> [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "    ACTIONS:" -ForegroundColor Yellow
    Write-Host "    * build     Generate baseline hash database" -ForegroundColor White
    Write-Host "    * scan      Compare current files against baseline" -ForegroundColor White
    Write-Host "    * help      Display this help information" -ForegroundColor White
    Write-Host ""
    Write-Host "    OPTIONS:" -ForegroundColor Yellow
    Write-Host "    > -Out <file>      Output file (extension auto-detected)" -ForegroundColor White
    Write-Host "    > -In <file>       Input file (required for scan)" -ForegroundColor White
    Write-Host "    > -Format <type>   Format if no extension: CSV, JSON, XML" -ForegroundColor White
    Write-Host "    > -Report <file>   Report file for scan results" -ForegroundColor White
    Write-Host "    > -Vt              Enable VirusTotal analysis" -ForegroundColor White
    Write-Host ""
    Write-Host "    EXAMPLES:" -ForegroundColor Yellow
    Write-Host "    * Generate baseline:" -ForegroundColor White
    Write-Host "      .\main.ps1 build -Out baseline.csv" -ForegroundColor Gray
    Write-Host "    * Basic scan:" -ForegroundColor White
    Write-Host "      .\main.ps1 scan -In baseline.csv -Report changes.csv" -ForegroundColor Gray
    Write-Host "    * Advanced scan with analysis:" -ForegroundColor White
    Write-Host "      .\main.ps1 scan -In baseline.csv -Report changes.csv -Vt" -ForegroundColor Gray
    Write-Host ""
    Write-Host "    Author: P. Berra | For: Département de la Gironde" -ForegroundColor Cyan
    Write-Host "    Github: PaulBerra | Build: 2025.07.16" -ForegroundColor Green
    Write-Host ""
}



function Show-hScanBanner {
    <#
    .SYNOPSIS
        Displays the hScan ASCII banner with logo and information.

    .DESCRIPTION
        Shows formatted ASCII art banner with hScan logo, subtitle, feature list,
        and author information. Uses colored output for visual appeal and
        professional presentation.

    .EXAMPLE
        Show-hScanBanner
        Displays the complete hScan banner with all information.

    .NOTES
        - Features ASCII art logo with gradient colors (Cyan to Blue)
        - Displays subtitle: "File Integrity Forensic"
        - Shows feature list: Build, Scan, Monitor, Protect
        - Includes author, version, and build information
        - Uses consistent border and spacing for professional appearance

    .OUTPUTS
        Colored ASCII banner to console
    #>

    Write-Host ""
    Write-Host "    +==============================================================+" -ForegroundColor DarkBlue
    Write-Host "    |                                                              |" -ForegroundColor DarkBlue
    Write-Host "    |     " -ForegroundColor DarkBlue -NoNewline
    Write-Host "##   ## #####  ######  ####  #   #" -ForegroundColor Cyan -NoNewline
    Write-Host "     |" -ForegroundColor DarkBlue
    Write-Host "    |     " -ForegroundColor DarkBlue -NoNewline
    Write-Host "##   ## #      #      #   #  ##  #" -ForegroundColor Cyan -NoNewline
    Write-Host "     |" -ForegroundColor DarkBlue
    Write-Host "    |     " -ForegroundColor DarkBlue -NoNewline
    Write-Host "####### ###### #      #####  # # #" -ForegroundColor White -NoNewline
    Write-Host "     |" -ForegroundColor DarkBlue
    Write-Host "    |     " -ForegroundColor DarkBlue -NoNewline
    Write-Host "##   ## #      #      #   #  #  ##" -ForegroundColor White -NoNewline
    Write-Host "     |" -ForegroundColor DarkBlue
    Write-Host "    |     " -ForegroundColor DarkBlue -NoNewline
    Write-Host "##   ## #####  ###### #   #  #   #" -ForegroundColor Blue -NoNewline
    Write-Host "     |" -ForegroundColor DarkBlue
    Write-Host "    |                                                              |" -ForegroundColor DarkBlue
    Write-Host "    |             " -ForegroundColor DarkBlue -NoNewline
    Write-Host ">> " -ForegroundColor Yellow -NoNewline
    Write-Host "HASH SCANNER & MONITOR" -ForegroundColor White -NoNewline
    Write-Host " <<" -ForegroundColor Yellow -NoNewline
    Write-Host "             |" -ForegroundColor DarkBlue
    Write-Host "    |               " -ForegroundColor DarkBlue -NoNewline
    Write-Host "<< " -ForegroundColor Cyan -NoNewline
    Write-Host "File Integrity Forensic" -ForegroundColor Gray -NoNewline
    Write-Host " >>" -ForegroundColor Cyan -NoNewline
    Write-Host "               |" -ForegroundColor DarkBlue
    Write-Host "    |                                                              |" -ForegroundColor DarkBlue
    Write-Host "    |         " -ForegroundColor DarkBlue -NoNewline
    Write-Host "*" -ForegroundColor Yellow -NoNewline
    Write-Host " Build " -ForegroundColor White -NoNewline
    Write-Host "*" -ForegroundColor Yellow -NoNewline
    Write-Host " Scan " -ForegroundColor White -NoNewline
    Write-Host "*" -ForegroundColor Yellow -NoNewline
    Write-Host " Monitor " -ForegroundColor White -NoNewline
    Write-Host "*" -ForegroundColor Yellow -NoNewline
    Write-Host " Protect " -ForegroundColor White -NoNewline
    Write-Host "*" -ForegroundColor Yellow -NoNewline
    Write-Host "         |" -ForegroundColor DarkBlue
    Write-Host "    |                                                              |" -ForegroundColor DarkBlue
    Write-Host "    |     " -ForegroundColor DarkBlue -NoNewline
    Write-Host "> " -ForegroundColor Cyan -NoNewline
    Write-Host "Author: " -ForegroundColor Gray -NoNewline
    Write-Host "P. Berra" -ForegroundColor White -NoNewline
    Write-Host " | " -ForegroundColor DarkGray -NoNewline
    Write-Host "For: " -ForegroundColor Gray -NoNewline
    Write-Host "Département de la Gironde" -ForegroundColor White -NoNewline
    Write-Host " <" -ForegroundColor Cyan -NoNewline
    Write-Host "     |" -ForegroundColor DarkBlue
    Write-Host "    |     " -ForegroundColor DarkBlue -NoNewline
    Write-Host "> " -ForegroundColor Cyan -NoNewline
    Write-Host "Version: " -ForegroundColor Gray -NoNewline
    Write-Host "v1.0.0" -ForegroundColor Green -NoNewline
    Write-Host " | " -ForegroundColor DarkGray -NoNewline
    Write-Host "Build: " -ForegroundColor Gray -NoNewline
    Write-Host "2025.07.16" -ForegroundColor Green -NoNewline
    Write-Host " | " -ForegroundColor DarkGray -NoNewline
    Write-Host "Github: " -ForegroundColor Gray -NoNewline
    Write-Host "PaulBerra" -ForegroundColor Green -NoNewline
    Write-Host " <" -ForegroundColor Cyan -NoNewline
    Write-Host "     |" -ForegroundColor DarkBlue
    Write-Host "    |                                                              |" -ForegroundColor DarkBlue
    Write-Host "    +==============================================================+" -ForegroundColor DarkBlue
    Write-Host ""
}

function Show-hScanBannerAnimated {
    <#
    .SYNOPSIS
        Displays animated hScan banner with loading progression.

    .DESCRIPTION
        Shows initialization sequence followed by animated loading bar, then
        displays the complete hScan banner. Creates engaging user experience
        with smooth animation and visual feedback.

    .EXAMPLE
        Show-hScanBannerAnimated
        Displays animated initialization and loading sequence.

    .NOTES
        - Shows "INITIALIZING..." message first
        - Animated progress bar with 100ms intervals
        - Clears screen between animation frames
        - Calls Show-hScanBanner after animation completes
        - Total animation duration approximately 1 second

    .OUTPUTS
        Animated loading sequence followed by complete hScan banner
    #>

    # Init animation
    Write-Host ""
    Write-Host "    +==============================================================+" -ForegroundColor DarkBlue
    Write-Host "    |                                                              |" -ForegroundColor DarkBlue
    Write-Host "    |                     " -ForegroundColor DarkBlue -NoNewline
    Write-Host "INITIALIZING..." -ForegroundColor Yellow -NoNewline
    Write-Host "                     |" -ForegroundColor DarkBlue
    Write-Host "    |                                                              |" -ForegroundColor DarkBlue
    Write-Host "    +==============================================================+" -ForegroundColor DarkBlue
    
    # Progression animation
    $progress = "################################################"
    for ($i = 0; $i -lt $progress.Length; $i += 7) {
        Clear-Host
        Write-Host ""
        Write-Host "    +==============================================================+" -ForegroundColor DarkBlue
        Write-Host "    |                                                              |" -ForegroundColor DarkBlue
        Write-Host "    |                     " -ForegroundColor DarkBlue -NoNewline
        Write-Host "LOADING hScan..." -ForegroundColor Yellow -NoNewline
        Write-Host "                     |" -ForegroundColor DarkBlue
        Write-Host "    |                                                              |" -ForegroundColor DarkBlue
        Write-Host "    |     " -ForegroundColor DarkBlue -NoNewline
        Write-Host $progress.Substring(0, [Math]::Min($i + 7, $progress.Length)) -ForegroundColor Cyan -NoNewline
        Write-Host $progress.Substring([Math]::Min($i + 7, $progress.Length)) -ForegroundColor DarkGray -NoNewline
        Write-Host "     |" -ForegroundColor DarkBlue
        Write-Host "    |                                                              |" -ForegroundColor DarkBlue
        Write-Host "    +==============================================================+" -ForegroundColor DarkBlue
        Start-Sleep -Milliseconds 100
    }
    
    Start-Sleep -Milliseconds 300
    Clear-Host
    Show-hScanBanner
}



function ConvertTo-DateTime {
    param([string]$DateString)
    
    # Si c'est déjà un DateTime, le retourner tel quel
    if ($DateString -is [DateTime]) {
        return $DateString
    }
    
    # Formats de date possibles
    $formats = @(
        "dd/MM/yyyy HH:mm:ss",     # Format français
        "MM/dd/yyyy HH:mm:ss",     # Format américain
        "yyyy-MM-dd HH:mm:ss",     # Format ISO
        "dd/MM/yyyy H:mm:ss",      # Sans zéro initial sur l'heure
        "MM/dd/yyyy H:mm:ss"       # Sans zéro initial sur l'heure
    )
    
    # Essayer chaque format
    foreach ($format in $formats) {
        try {
            return [DateTime]::ParseExact($DateString, $format, $null)
        } catch {
            # Continuer avec le format suivant
        }
    }
    
    # Si aucun format ne fonctionne, essayer la conversion automatique
    try {
        return [DateTime]::Parse($DateString, [System.Globalization.CultureInfo]::InvariantCulture)
    } catch {
        # En dernier recours, essayer avec la culture française
        try {
            $frenchCulture = [System.Globalization.CultureInfo]::new("fr-FR")
            return [DateTime]::Parse($DateString, $frenchCulture)
        } catch {
            throw "Unable to convert datetime : $DateString"
        }
    }
}


function PrintDiff {
    param (
        [Parameter(Mandatory)]
        [object]$Differences
    )
    
    $Differences | ForEach-Object {
        # Vérifier que Status n'est pas null
        if ($_.Status) {
            $color = switch ($_.Status) {
                'new' { 'Green' }
                'modified' { 'Yellow' }
                'deleted' { 'Red' }
                default { 'White' }
            }
            Write-Host "[$($_.Status.ToUpper())] $($_.Path)" -ForegroundColor $color
        } else {
            Write-Host "[UNKNOWN] $($_.Path)" -ForegroundColor White
        }
    }
}



function BuildReport {
    param(
        [Parameter(Mandatory)]
        [object]$Differences,
        [object]$YaraResults = @(),
        [object]$VtResults = @(),
        [object]$Config,
        [string]$OutputPath,
        [ValidateSet('standard', 'detailed', 'minimal')]
        [string]$ReportType = 'standard'
    )


    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $templatesPath = Resolve-Path ("$PSScriptRoot\..\lib\Invoke\templates\report_csv_summary.ps1")   

    # Construire le rapport de base
    $report = [PSCustomObject]@{
        Metadata = [PSCustomObject]@{
            GeneratedAt = $timestamp
            ScanPaths = $Config.DefaultPaths -join '; '
            TotalDifferences = $Differences.Count
            TotalYaraScans = $YaraResults.Count
            TotalVtScans = $VtResults.Count
            ReportType = $ReportType
        }
        Summary = [PSCustomObject]@{
            NewFiles = ($Differences | Where-Object { $_.Status -eq 'new' }).Count
            ModifiedFiles = ($Differences | Where-Object { $_.Status -eq 'modified' }).Count
            DeletedFiles = ($Differences | Where-Object { $_.Status -eq 'deleted' }).Count
            YaraDetections = ($YaraResults | Where-Object { $_.HasDetections }).Count
            YaraErrors = ($YaraResults | Where-Object { $_.Errors.Count -gt 0 }).Count
            VtDetections = ($VtResults | Where-Object { $_.Positives -gt 0 }).Count
            VtErrors = ($VtResults | Where-Object { $_.Errors.Count -gt 0 }).Count
        }
        FileChanges = $Differences
        YaraDetections = $YaraResults | Where-Object { $_.HasDetections }
        YaraErrors = $YaraResults | Where-Object { $_.Errors.Count -gt 0 }
        VtResults = $VtResults
        VtDetections = $VtResults | Where-Object { $_.Positives -gt 0 }
        VtErrors = $VtResults | Where-Object { $_.Errors.Count -gt 0 }
    }
   
    # Filtrer selon le type de rapport
    switch ($ReportType) {
        'minimal' {
            $report.FileChanges = $Differences | Where-Object { $_.Status -in @('new', 'modified') }
            $report.YaraDetections = $YaraResults | Where-Object { $_.HasDetections -and $_.Detections.Count -gt 0 }
            $report.VtDetections = $VtResults | Where-Object { $_.Positives -gt 3 }  # Seulement haute détection
        }
        'detailed' {
            # Inclure toutes les données + métadonnées supplémentaires
            $report | Add-Member -NotePropertyName "DetailedStats" -NotePropertyValue ([PSCustomObject]@{
                LargestFiles = ($Differences | Where-Object { $_.Status -eq 'new' -and (Test-Path $_.Path -ErrorAction SilentlyContinue) } | 
                              ForEach-Object { [PSCustomObject]@{ Path = $_.Path; Size = (Get-Item $_.Path -ErrorAction SilentlyContinue).Length } } |
                              Sort-Object Size -Descending | Select-Object -First 5)
                RecentChanges = ($Differences | Sort-Object LastModified -Descending | Select-Object -First 10)
            })
        }
    }
   
    # Générer selon l'extension
    $extension = [System.IO.Path]::GetExtension($OutputPath).ToLower()
   
    try {
        switch ($extension) {
            '.json' {
                $template = & (Join-Path $templatesPath "report_json.ps1") -report $report
                $template | Out-File -FilePath $OutputPath -Encoding UTF8
            }
            '.csv' {
                # CSV des changements
                $Differences | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
            
                # Fichier résumé avec template
                $summaryPath = $OutputPath -replace '\.csv$', '_summary.txt'
                $templateFile = $templatesPath
                
                if (Test-Path $templateFile) {
                    $template = . $templateFile $report
                    $template | Out-File -FilePath $summaryPath -Encoding UTF8 
                } else {
                    Write-Warning "Can't find template : $templateFile"
                    "Simple report - $($report.Metadata.GeneratedAt)" | Out-File -FilePath $summaryPath -Encoding UTF8
                }
            
                Write-Host "CSV Report: $OutputPath" -ForegroundColor Green
                Write-Host "Summary: $summaryPath" -ForegroundColor Green
            }
            '.xml' {
                $report | Export-Clixml -Path $OutputPath
            }
            default {
                # Format texte avec template
                $template = & (Join-Path $templatesPath "report_text.ps1") -report $report
                $template | Out-File -FilePath $OutputPath -Encoding UTF8
            }
        }
       
        Write-Host "Report [$ReportType] saved: $OutputPath" -ForegroundColor Green
       
    } catch {
        Write-Error "Erreur building report: $($_.Exception.Message)"
        # Fallback - rapport simple
        $report | ConvertTo-Json -Depth 2 | Out-File -FilePath "$OutputPath.backup.json" -Encoding UTF8
    }
   
    return $report
}