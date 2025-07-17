# Template JSON
param($report)

return $report | ConvertTo-Json -Depth 4