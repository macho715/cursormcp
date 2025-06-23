# MCP Server Health Check
Write-Host "Checking MCP Server Status..." -ForegroundColor Cyan
Write-Host "=" * 50

# Check Node.js processes
$nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    Write-Host "Node.js processes found: $($nodeProcesses.Count)" -ForegroundColor Green
    foreach ($proc in $nodeProcesses) {
        $memoryMB = [math]::Round($proc.WorkingSet / 1MB, 2)
        Write-Host "   PID: $($proc.Id) | Memory: $memoryMB MB" -ForegroundColor Gray
    }
} else {
    Write-Host "No Node.js processes found" -ForegroundColor Red
}

Write-Host ""

# Check ports
$ports = @(8090, 8091)
foreach ($port in $ports) {
    try {
        $response = Invoke-WebRequest -UseBasicParsing "http://localhost:$port/health" -TimeoutSec 3 -ErrorAction Stop
        Write-Host "Port $port - OK ($($response.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "Port $port - No response" -ForegroundColor Red
    }
}

Write-Host ""

# Check environment variables
if ($env:BRAVE_API_KEY) {
    Write-Host "BRAVE_API_KEY is set" -ForegroundColor Green
} else {
    Write-Host "BRAVE_API_KEY not found" -ForegroundColor Yellow
}

# Check Cursor settings
$cursorSettings = "$env:APPDATA\Cursor\User\settings.json"
if (Test-Path $cursorSettings) {
    Write-Host "Cursor settings file exists" -ForegroundColor Green
    try {
        $settings = Get-Content $cursorSettings -Raw | ConvertFrom-Json
        if ($settings.mcpServers) {
            $serverCount = ($settings.mcpServers | Get-Member -MemberType NoteProperty).Count
            Write-Host "MCP servers configured: $serverCount" -ForegroundColor Green
        }
    } catch {
        Write-Host "Error reading Cursor settings" -ForegroundColor Yellow
    }
} else {
    Write-Host "Cursor settings file not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "Health check completed!" -ForegroundColor Green 