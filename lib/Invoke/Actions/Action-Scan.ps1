

. "$PSScriptRoot\..\..\..\lib\Invoke\Functions\UseHashBase.ps1"


function CompareHashesRecursive {
    param(
        [Parameter(Mandatory)]
        [object[]]$OldHashes,
        [Parameter(Mandatory)]
        [object[]]$NewHashes
    )
    
    $Differences = @()
    
    # Create hashtables for quick searches
    $OldHashesHash = @{}
    $NewHashesHash = @{}
    
    $OldHashes | ForEach-Object { $OldHashesHash[$_.Path] = $_ }
    $NewHashes | ForEach-Object { $NewHashesHash[$_.Path] = $_ }
    
    # 1. NEW: in Current but not in Baseline
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
    
    # 2. DELETED: in Baseline but not in Current
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
    
    # 3. CHANGED: in both BUT different hashes
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
    
    Write-Host "`rComparison completed : $($Differences.Count) differences found                             "
    return $Differences
}