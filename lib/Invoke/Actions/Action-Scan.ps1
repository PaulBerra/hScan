

. "C:\dev\hScan\lib\Invoke\Functions\UseHashBase.ps1"


function CompareHashesRecursive {
    param(
        [Parameter(Mandatory)]
        [object[]]$OldHashes,
        [Parameter(Mandatory)]
        [object[]]$NewHashes
    )
    
    $Differences = @()
    
    # Créer des hashtables pour les recherches rapides
    $OldHashesHash = @{}
    $NewHashesHash = @{}
    
    $OldHashes | ForEach-Object { $OldHashesHash[$_.Path] = $_ }
    $NewHashes | ForEach-Object { $NewHashesHash[$_.Path] = $_ }
    
    # 1. NOUVEAUX : dans Current mais pas dans Baseline
    $NewHashes | ForEach-Object {
        if (-not $OldHashesHash.ContainsKey($_.Path)) {
            $Differences += [PSCustomObject]@{
                Path         = $_.Path
                Hash         = $_.Hash
                Status       = 'new'
                LastModified = $_.LastModified
                PreviousHash = $null
            }
        }
    }
    
    # 2. SUPPRIMÉS : dans Baseline mais pas dans Current
    $OldHashes | ForEach-Object {
        if (-not $NewHashesHash.ContainsKey($_.Path)) {
            $Differences += [PSCustomObject]@{
                Path         = $_.Path
                Hash         = $_.Hash
                Status       = 'deleted'
                LastModified = $_.LastModified
                PreviousHash = $null
            }
        }
    }
    
    # 3. MODIFIÉS : dans les deux MAIS hashs différents
    $NewHashes | ForEach-Object {
        if ($OldHashesHash.ContainsKey($_.Path)) {
            $oldFile = $OldHashesHash[$_.Path]
            if ($_.Hash -ne $oldFile.Hash) {
                $Differences += [PSCustomObject]@{
                    Path         = $_.Path
                    Hash         = $_.Hash
                    Status       = 'modified'
                    LastModified = $_.LastModified
                    PreviousHash = $oldFile.Hash
                }
            }
        }
    }
    
    Write-Host "Comparaison terminée : $($Differences.Count) différences trouvées"
    return $Differences
}