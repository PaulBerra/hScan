function Invoke-VirusTotalScan {
    param(
        [Parameter(Mandatory, ParameterSetName='File')]
        [string[]]$FilePath,
        
        [Parameter(Mandatory, ParameterSetName='Hash')]
        [string[]]$Hash,
        
        [Parameter(Mandatory)]
        [string]$ApiKey,
        
        [switch]$UploadFile,
        [int]$DelaySeconds = 15  # Rate limit VT API
    )
    
    $baseUrl = "https://www.virustotal.com/vtapi/v2"
    $results = @()
    
    foreach ($item in ($FilePath + $Hash)) {
        if (-not $item) { continue }
        
        try {
            $result = [PSCustomObject]@{
                Input = $item
                Type = if ($FilePath -contains $item) { 'File' } else { 'Hash' }
                Success = $false
                ResponseCode = $null
                Positives = 0
                Total = 0
                ScanDate = $null
                Permalink = $null
                Detections = @()
                Errors = @()
                RawResponse = $null
            }
            
            if ($result.Type -eq 'File') {
                if (-not (Test-Path $item)) {
                    $result.Errors += "Fichier introuvable : $item"
                    $results += $result
                    continue
                }
                
                # Upload file si demandé
                if ($UploadFile) {
                    Write-Host "Upload vers VT: $([System.IO.Path]::GetFileName($item))" -ForegroundColor Gray
                    $uploadResult = Invoke-VirusTotalUpload -FilePath $item -ApiKey $ApiKey
                    if ($uploadResult.Success) {
                        $result.Permalink = $uploadResult.Permalink
                        Write-Host "Upload réussi, attente analyse..." -ForegroundColor Yellow
                        Start-Sleep -Seconds 60  # Attendre l'analyse
                    }
                }
                
                # Obtenir le hash du fichier pour lookup
                $fileHash = (Get-FileHash -Path $item -Algorithm SHA256).Hash
                $queryHash = $fileHash
            } else {
                $queryHash = $item
            }
            
            # Lookup du rapport
            Write-Host "VT Lookup: $queryHash" -ForegroundColor Gray
            $uri = "$baseUrl/file/report"
            $body = @{
                apikey = $ApiKey
                resource = $queryHash
            }
            
            $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -ErrorAction Stop
            $result.RawResponse = $response
            $result.Success = $true
            $result.ResponseCode = $response.response_code
            
            if ($response.response_code -eq 1) {
                # Rapport trouvé
                $result.Positives = $response.positives
                $result.Total = $response.total
                $result.ScanDate = $response.scan_date
                $result.Permalink = $response.permalink
                
                # Parser les détections
                if ($response.scans) {
                    $response.scans.PSObject.Properties | ForEach-Object {
                        if ($_.Value.detected) {
                            $result.Detections += [PSCustomObject]@{
                                Engine = $_.Name
                                Result = $_.Value.result
                                Version = $_.Value.version
                                Update = $_.Value.update
                            }
                        }
                    }
                }
                
                # Affichage résultat
                if ($result.Positives -gt 0) {
                    Write-Host "VT: $($result.Positives)/$($result.Total) détections" -ForegroundColor Red
                } else {
                    Write-Host "VT: Clean ($($result.Total) engines)" -ForegroundColor Green
                }
                
            } elseif ($response.response_code -eq 0) {
                $result.Errors += "Hash non trouvé dans VT"
                Write-Host "VT: Hash inconnu" -ForegroundColor Yellow
            } elseif ($response.response_code -eq -2) {
                $result.Errors += "Analyse en cours"
                Write-Host "VT: Analyse en cours..." -ForegroundColor Yellow
            }
            
        } catch {
            $result.Errors += "Erreur API VT : $($_.Exception.Message)"
            Write-Host "VT Error: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        $results += $result
        
        # Rate limiting
        if ($DelaySeconds -gt 0) {
            Start-Sleep -Seconds $DelaySeconds
        }
    }
    
    return $results
}

function Invoke-VirusTotalUpload {
    param(
        [string]$FilePath,
        [string]$ApiKey
    )
    
    try {
        $uri = "https://www.virustotal.com/vtapi/v2/file/scan"
        
        # Préparer le multipart form
        $boundary = [System.Guid]::NewGuid().ToString()
        $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
        $fileName = [System.IO.Path]::GetFileName($FilePath)
        
        $bodyLines = @(
            "--$boundary",
            "Content-Disposition: form-data; name=`"apikey`"",
            "",
            $ApiKey,
            "--$boundary",
            "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"",
            "Content-Type: application/octet-stream",
            "",
            [System.Text.Encoding]::Latin1.GetString($fileBytes),
            "--$boundary--"
        )
        
        $body = $bodyLines -join "`r`n"
        $contentType = "multipart/form-data; boundary=$boundary"
        
        $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -ContentType $contentType
        
        return [PSCustomObject]@{
            Success = $true
            Resource = $response.resource
            ScanId = $response.scan_id
            Permalink = $response.permalink
            SHA256 = $response.sha256
            Response = $response
        }
        
    } catch {
        return [PSCustomObject]@{
            Success = $false
            Error = $_.Exception.Message
            Response = $null
        }
    }
}