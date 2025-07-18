# Template CSV Summary
param($report)

return @"
=== SCAN REPORT - $($report.Metadata.GeneratedAt) ===
Chemins surveilles: $($report.Metadata.ScanPaths)

RESUMe:
- Nouveaux fichiers: $($report.Summary.NewFiles)
- Fichiers modifies: $($report.Summary.ModifiedFiles)  
- Fichiers supprimes: $($report.Summary.DeletedFiles)
- Detections Yara: $($report.Summary.YaraDetections)
- Erreurs Yara: $($report.Summary.YaraErrors)
$(if ($report.VtResults) {
"- Detections VirusTotal: $($report.Summary.VtDetections)
- Erreurs VirusTotal: $($report.Summary.VtErrors)"
})

DETECTIONS YARA:
$($report.YaraDetections | ForEach-Object {
    "- $([System.IO.Path]::GetFileName($_.TargetPath)): $($_.RuleMatches.Rule -join ', ')"
} | Out-String)

$(if ($report.VtResults) {
"DETECTIONS VIRUSTOTAL:
$($report.VtDetections | ForEach-Object {
    "- $([System.IO.Path]::GetFileName($_.Input)): $($_.Positives)/$($_.Total)"
} | Out-String)"
})
"@