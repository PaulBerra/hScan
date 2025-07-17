
# return object of path/hash/lastmodified

. "C:\dev\hScan\lib\Invoke\Functions\UseHashBase.ps1"
function GetFileHashesRecursive {
    param(
        [Parameter(Mandatory)]
        [object]$Config
    )
    $Results = @()
    foreach ($path in $Config.DefaultPaths) {
        try {
            if (-not (Test-Path $path)) {
                Write-Warning "Chemin invalide : $path"
                continue
            }
            Get-ChildItem -Path $path -File -Recurse | ForEach-Object {
                try {
                    $hashResult = Get-FileHash -Path $_.FullName -Algorithm $Config.HashAlgorithms.Default -ErrorAction Stop
                    $hash = $hashResult.Hash
                } catch {
                    Write-Verbose "Impossible de hasher '$($_.FullName)' : $($_.Exception.Message)"
                    $hash = $null  # ou "ERROR" pour identifier les fichiers problématiques
                }
                
                $Results += [PSCustomObject]@{
                    Path         = $_.FullName
                    Hash         = $hash
                    LastModified = $_.LastWriteTime
                }
            }
        } catch {
            Write-Warning "Erreur d'accès au chemin $path : $($_.Exception.Message)"
        }
    }
    return $Results
}




