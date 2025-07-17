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

    [Parameter(ParameterSetName='Scan')]
    [switch]$optimize = $false # default dont try to calcul entropy
)



 # if -vt, we gonna need the report of yara & the optimisation, so yara = $true & optimize = $true
if ($Vt) { $YaraScan = $true}


Write-Verbose "Dot-sourcing modules"
. "$PSScriptRoot\lib\Utils.ps1"
. "$PSScriptRoot\lib\Invoke\Functions\Invoke-Build.ps1"
. "$PSScriptRoot\lib\Invoke\Actions\Action-Build.ps1"
. "$PSScriptRoot\lib\Invoke\Functions\Invoke-Scan.ps1"


$global:ConfigObject = LoadConfig -configPath ".\config.ps1"

switch ($Action.ToLower()) {
    'build' {
        Write-Host "=> BUILD : generation de la baseline dans '$Out'"
        Invoke-Build -Out $Out -Config $ConfigObject
        break
    }
    'scan' {
        Write-Host "→ SCAN : lecture de '$In'"
        if ($YaraScan) { Write-Host " [+] YaraScan activé" }
        if ($Vt)       { Write-Host " [+] VirusTotal activé (YaraScan auto-enabled)" }
        #Invoke-Scan -In $In -YaraScan:$YaraScan -Vt:$Vt
        Invoke-Scan -In $In -Config $ConfigObject -YaraScan $YaraScan
        break
    }
    default { # wrong action switch
        Show-Help
        exit 1
    }
}
