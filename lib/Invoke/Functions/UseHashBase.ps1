# sauvegarde la abse de hash en focntion de lextension
# detecte extension

. "$PSScriptRoot\..\..\..\lib\Utils.ps1" #import date converter

function Save-HashBase {
    param(
        [Parameter(Mandatory)]
        [object[]]$Results,

        [Parameter(Mandatory)]
        [string]$OutPath
    )

    if ([string]::IsNullOrEmpty($OutPath)) {
        throw "Le chemin de sortie est vide"
    }

    $extension = [IO.Path]::GetExtension($OutPath).ToLower()

    Write-Host "Sauvegarde de la baseline au format $extension dans : $OutPath"

    switch ($extension) {
        '.csv' { $Results | Export-Csv -Path $OutPath -NoTypeInformation -Encoding UTF8 }
        '.json' { $Results | ConvertTo-Json -Depth 3 | Out-File -FilePath $OutPath -Encoding UTF8 }
        '.xml' { $Results | Export-Clixml -Path $OutPath }
        default { throw "Extension $extension non supportée" }
    }
}

function LoadHashBase {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath
    )
   
    if (-not (Test-Path $FilePath)) {
        throw "Le fichier '$FilePath' n'existe pas"
    }
   
    $extension = [IO.Path]::GetExtension($FilePath).ToLower()
    Write-Host "Chargement de la baseline depuis : $FilePath (format $extension)"
   
    try {
        switch ($extension) {
            '.csv' {
                $Results = Import-Csv -Path $FilePath -Encoding UTF8
                # Convertir LastModified en DateTime avec gestion des formats
                $Results | ForEach-Object {
                    $_.LastModified = ConvertTo-DateTime -DateString $_.LastModified
                    $_
                }
            }
            '.json' {
                $Results = Get-Content -Path $FilePath -Encoding UTF8 | ConvertFrom-Json
                # Convertir LastModified en DateTime si nécessaire
                $Results | ForEach-Object {
                    $_.LastModified = ConvertTo-DateTime -DateString $_.LastModified
                    $_
                }
            }
            '.xml' {
                $Results = Import-Clixml -Path $FilePath
            }
            default {
                throw "Extension $extension non supportée. Formats supportés : .csv, .json, .xml"
            }
        }
       
        Write-Host "Baseline chargée : $($Results.Count) fichiers"
        return $Results
       
    } catch {
        throw "Erreur lors du chargement du fichier : $($_.Exception.Message)"
    }
}
