# Invoke-Build.ps1

function Invoke-Build {
    param(
        [Parameter(Mandatory)]
        [object]$Config,

        [Parameter(Mandatory)]
        [string]$Out
    )

    Write-Host "Chemins à explorer : $($Config.DefaultPaths -join ', ')"

    $results = GetFileHashesRecursive -Config $Config

    if (-not $results -or $results.Count -eq 0) {
        Write-Warning "Aucun fichier trouvé."
        return
    }

    Save-HashBase -Results $results -OutPath $Out

    Write-Host "Baseline générée avec $($results.Count) fichiers."
}
