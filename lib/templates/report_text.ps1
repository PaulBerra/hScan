# Template Text
param($report)

return @"
=== HSCAN REPORT - $($report.Metadata.GeneratedAt) ===

MÉTADONNÉES:
- Généré le: $($report.Metadata.GeneratedAt)
- Chemins surveillés: $($report.Metadata.ScanPaths)
- Total différences: $($report.Metadata.TotalDifferences)

RÉSUMÉ:
- Nouveaux: $($report.Summary.NewFiles)
- Modifiés: $($report.Summary.ModifiedFiles)
- Supprimés: $($report.Summary.DeletedFiles)
- Détections Yara: $($report.Summary.YaraDetections)
- Erreurs Yara: $($report.Summary.YaraErrors)
$(if ($report.VtResults) {
"- Détections VirusTotal: $($report.Summary.VtDetections)
- Erreurs VirusTotal: $($report.Summary.VtErrors)"
})

CHANGEMENTS DE FICHIERS:
$($report.FileChanges | ForEach-Object { "[$($_.Status.ToUpper())] $($_.Path)" } | Out-String)

DÉTECTIONS YARA:
$($report.YaraDetections | ForEach-Object {
    "$($_.TargetPath)`n  Règles: $($_.RuleMatches.Rule -join ', ')`n"
} | Out-String)

$(if ($report.VtDetections) {
"DÉTECTIONS VIRUSTOTAL:
$($report.VtDetections | ForEach-Object {
    "$($_.Input) - $($_.Positives)/$($_.Total) détections`n  Permalink: $($_.Permalink)`n"
} | Out-String)"
})
"@