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

 # if -vt, we gonna need the report of yara & the optimisation, so yara = $true & optimize = $true
if ($Vt) { $YaraScan = $true}

# modules dot sourcing (not definitiv)
. "$PSScriptRoot\lib\Utils.ps1"
. "$PSScriptRoot\lib\Invoke\Functions\Invoke-Build.ps1"
. "$PSScriptRoot\lib\Invoke\Actions\Action-Build.ps1"
. "$PSScriptRoot\lib\Invoke\Functions\Invoke-Scan.ps1"

#load config in gVar
$global:ConfigObject = LoadConfig -configPath ".\config.ps1"

# toggle action
switch ($Action.ToLower()) {
    'build' {
        Show-hScanBannerAnimated
        Write-Host "=> BUILD : Baseline generation in '$Out'"
        Invoke-Build -Out $Out -Config $ConfigObject
        break
    }
    'scan' {
        Show-hScanBannerAnimated
        Write-Host "→ SCAN : Reading of '$In'"
        if ($YaraScan -eq $true -and $Vt -eq $false) { Write-Host " [+] YaraScan turned on" } # if yara, print yara turned on
        if ($Vt -eq $true)       { Write-Host " [+] VirusTotal submission turned on(YaraScan auto-enabled)" } # if virustotal, print virustotal
        Invoke-Scan -In $In -Out $Out -Config $ConfigObject -YaraScan $YaraScan -Vt $Vt -Report $ConfigObject.ReportsTemplate
        break
    }
    default { # wrong action switch
        Show-Help
        exit 1
    }
}
