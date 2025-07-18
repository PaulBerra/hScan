function Invoke-YaraScan {
    param(
        [Parameter(Mandatory)]
        [string]$YaraBinary,
        [Parameter(Mandatory)]
        [string]$RulesDirectory,
        [Parameter(Mandatory)]
        [string]$TargetPath
    )
   
    # Objet de résultat
    $result = [PSCustomObject]@{
        TargetPath = $TargetPath
        Success = $false
        HasDetections = $false
        Detections = @()
        Errors = @()
        RuleMatches = @()
    }
   
    # Vérifications de base
    if (-not (Test-Path $YaraBinary)) {
        $result.Errors += "Binary Yara not found : $YaraBinary"
        return $result
    }
   
    $indexYar = Join-Path $RulesDirectory "index.yar"
    if (-not (Test-Path $indexYar)) {
        $result.Errors += "Index.yar file not found : $indexYar"
        return $result
    }
   
    if (-not (Test-Path $TargetPath)) {
        $result.Errors += "File inaccessible : $TargetPath"
        return $result
    }
   
    try {
        $arguments = @(
            '--no-warnings',
            #'-s',     show matched strings (debug)
            $indexYar,
            $TargetPath
        )
       
        $yaraOutput = & $YaraBinary $arguments 2>&1

        if ($LASTEXITCODE -eq 0) {
            $result.Success = $true
            
            if ($yaraOutput) {
                $result.HasDetections = $true
                $result.Detections = $yaraOutput
                
                # Parse matching rules
                $yaraOutput | ForEach-Object {
                    if ($_ -match '^(\w+)\s+(.+)$') {
                        $result.RuleMatches += [PSCustomObject]@{
                            Rule = $matches[1]
                            File = $matches[2]
                        }
                    }
                }
            }
        } else {
            $result.Errors += "Error Yara (code $LASTEXITCODE) : $yaraOutput"
        }
       
    } catch {
        $result.Errors += "Exception : $($_.Exception.Message)"
    }
   
    return $result
}