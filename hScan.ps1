#===========================================================
# hScan.ps1 - Hash Scanner & Monitor
#===========================================================

[CmdletBinding(DefaultParameterSetName='help')]
param(
    [Parameter(Position=0)]
    [string]$Action, # default = help

    [Parameter(ParameterSetName='Build', Mandatory)]
    [Parameter(ParameterSetName='Scan', Mandatory)]
    [string]$Out,

    [Parameter(ParameterSetName='Scan', Mandatory)]
    [string]$In,

    [Parameter(ParameterSetName='Scan')]
    [switch]$YaraScan = $false,

    [Parameter(ParameterSetName='Scan')]
    [switch]$Vt,

    # under developpment
    [Parameter(ParameterSetName='Scan')]
    [switch]$optimize = $false # default dont try to calcul entropy
)

 # if -vt, we gonna need the report of yara, so yara = $true
if ($Vt) { $YaraScan = $true}

# modules dot sourcing (not definitiv)
. "lib\Functions\Utils.ps1"
. "lib\Invoke\Invoke-Build.ps1"
. "lib\Actions\Action-Build.ps1"    
. "lib\Invoke\Invoke-Scan.ps1"      

#load config in gVar
$global:ConfigObject = LoadConfig -configPath ".\config.ps1"

# toggle action
switch ($Action.ToLower()) {
    'build' {
        Show-hScanBannerAnimated
        Write-Host "=> BUILD : Baseline generation in '$Out'"  -NoNewline-ForegroundColor Green
        Start-Sleep 2

        Invoke-Build -Out $Out -Config $ConfigObject
        break
    }
    'scan' {
        Show-hScanBannerAnimated
        Write-Host "=> SCAN : Reading of '$In'" -NoNewline -ForegroundColor Green
        Start-Sleep 2

        if ($YaraScan -eq $true -and $Vt -eq $false) { 
            Write-Host "`r[+] YaraScan turned on                                      " -NoNewline -ForegroundColor Green # if yara, print yara turned on 
            Start-Sleep 2
        } 
        if ($Vt -eq $true) { 
            Write-Host "`r[+] VirusTotal submission turned on (YaraScan auto-enabled)" -NoNewline -ForegroundColor Green # if virustotal, print virustotal
            Start-Sleep 2
        } 
        Invoke-Scan -In $In -Out $Out -Config $ConfigObject -YaraScan $YaraScan -Vt $Vt -Report $ConfigObject.ReportsTemplate
        break
    }
    default { # wrong action switch
        Show-Help
        exit 1
    }
}
