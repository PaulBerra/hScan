# Template CSV Summary
param($report)

return @"
=== SCAN REPORT - $($report.Metadata.GeneratedAt) ===
Chemins surveillés: $($report.Metadata.ScanPaths)

RÉSUMÉ:
- Nouveaux fichiers: $($report.Summary.NewFiles)
- Fichiers modifiés: $($report.Summary.ModifiedFiles)  
- Fichiers supprimés: $($report.Summary.DeletedFiles)
- Détections Yara: $($report.Summary.YaraDetections)
- Erreurs Yara: $($report.Summary.YaraErrors)
$(if ($report.VtResults) {
"- Détections VirusTotal: $($report.Summary.VtDetections)
- Erreurs VirusTotal: $($report.Summary.VtErrors)"
})

DÉTECTIONS YARA:
$($report.YaraDetections | ForEach-Object {
    "- $([System.IO.Path]::GetFileName($_.TargetPath)): $($_.RuleMatches.Rule -join ', ')"
} | Out-String)

$(if ($report.VtResults) {
"DÉTECTIONS VIRUSTOTAL:
$($report.VtDetections | ForEach-Object {
    "- $([System.IO.Path]::GetFileName($_.Input)): $($_.Positives)/$($_.Total)"
} | Out-String)"
})
"@