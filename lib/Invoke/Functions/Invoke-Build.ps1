# Invoke-Build.ps1

function Invoke-Build {
    param(
        [Parameter(Mandatory)]
        [object]$Config,

        [Parameter(Mandatory)]
        [string]$Out
    )

    Write-Host "Paths to explore : $($Config.DefaultPaths -join ', ')"

    $results = GetFileHashesRecursive -Config $Config

    if (-not $results -or $results.Count -eq 0) {
        Write-Warning "No files found."
        return
    }

    Save-HashBase -Results $results -OutPath $Out

    Write-Host "Hashbase generated with $($results.Count) files."
}
