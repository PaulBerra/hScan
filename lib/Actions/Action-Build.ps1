
# return object of path/hash/lastmodified
# big spaces avoid print errors between lines with very long filenames
. "lib\Functions\UseHashBase.ps1"
function GetFileHashesRecursive {
    param(
        [Parameter(Mandatory)]
        [object]$Config
    )

    $Results = @()
    $fileCount = 0
    foreach ($path in $Config.DefaultPaths) {
        try {
            if (-not (Test-Path $path)) {
                Write-Warning "Invalid path : $path"
                continue
            }
            Get-ChildItem -Path $path -File -Recurse | ForEach-Object {
                $fileCount++
                Write-Host "`rHashing file $fileCount : $($_.Name)...                                                                                         " -NoNewline -ForegroundColor Green

                try {
                    $hashResult = Get-FileHash -Path $_.FullName -Algorithm $Config.HashAlgorithms.Default -ErrorAction Stop
                    $hash = $hashResult.Hash
                } catch {
                    Write-Verbose "Impossible to hash '$($_.FullName)' : $($_.Exception.Message)"
                    $hash = $null  # or “ERROR” to identify problem files
                }
                
                $Results += [PSCustomObject]@{
                    Path         = $_.FullName
                    Hash         = $hash
                    LastModified = $_.LastWriteTime
                }
            }
        } catch {
            Write-Warning "Path access error $path : $($_.Exception.Message)"
        }
    }
    Write-Host "`rCompleted! Processed $fileCount files                                                                                   " -ForegroundColor Green 
    return $Results
}




