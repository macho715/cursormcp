$svcs = @{ "seq-think" = 8090; "brave-search" = 8091 }
$svcs.GetEnumerator() | %{
  try {
    $r = Invoke-WebRequest -UseBasicParsing "http://localhost:$($_.Value)/health" -TimeoutSec 5
    if ($r.StatusCode -eq 200) { Write-Host "✅ $($_.Key) MCP healthy (port $($_.Value))" }
    else                       { Write-Host "❌ $($_.Key) returned $($r.StatusCode)" }
  } catch { Write-Host "❌ $($_.Key) unreachable on port $($_.Value)" }
} 