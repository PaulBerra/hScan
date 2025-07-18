
# return object of path/hash/lastmodified

. "$PSScriptRoot\..\..\..\lib\Invoke\Functions\UseHashBase.ps1"
function GetFileHashesRecursive {
    param(
        [Parameter(Mandatory)]
        [object]$Config
    )
    $Results = @()
    foreach ($path in $Config.DefaultPaths) {
        try {
            if (-not (Test-Path $path)) {
                Write-Warning "Invalid path : $path"
                continue
            }
            Get-ChildItem -Path $path -File -Recurse | ForEach-Object {
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
    return $Results
}




