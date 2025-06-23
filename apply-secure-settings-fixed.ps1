# Cursor IDE Security Enhancement Script
# Date: 2025-06-23
# Purpose: Apply secure MCP settings to Cursor IDE

Write-Host "Applying Cursor IDE Security Enhancements..." -ForegroundColor Green
Write-Host "=" * 50

# 1. Check Cursor settings path
$cursorSettingsPath = "$env:APPDATA\Cursor\User\settings.json"
Write-Host "Cursor settings path: $cursorSettingsPath" -ForegroundColor Yellow

if (-not (Test-Path $cursorSettingsPath)) {
    Write-Host "ERROR: Cursor settings file not found!" -ForegroundColor Red
    Write-Host "Please ensure Cursor IDE is installed and has been run at least once." -ForegroundColor Yellow
    exit 1
}

# 2. Backup existing settings
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupPath = "$cursorSettingsPath.backup.secure.$timestamp"
Copy-Item $cursorSettingsPath $backupPath
Write-Host "Backup completed: $backupPath" -ForegroundColor Green

# 3. Load secure configuration
$secureConfigPath = "cursor-settings-secure.json"
if (-not (Test-Path $secureConfigPath)) {
    Write-Host "ERROR: Secure config file not found: $secureConfigPath" -ForegroundColor Red
    exit 1
}

$secureConfig = Get-Content $secureConfigPath -Raw | ConvertFrom-Json
Write-Host "Secure configuration loaded successfully" -ForegroundColor Green

# 4. Read and merge existing settings
try {
    $existingConfig = Get-Content $cursorSettingsPath -Raw | ConvertFrom-Json
} catch {
    Write-Host "WARNING: Existing settings file is empty or corrupted. Creating new one." -ForegroundColor Yellow
    $existingConfig = @{}
}

# 5. Merge MCP server settings
$existingConfig | Add-Member -Name "mcpServers" -Value $secureConfig.mcpServers -MemberType NoteProperty -Force

# 6. Apply additional security settings
$additionalSecuritySettings = @{
    "security.workspace.trust.enabled" = $true
    "security.workspace.trust.startupPrompt" = "always"
    "extensions.autoCheckUpdates" = $false
    "extensions.autoUpdate" = $false
    "telemetry.telemetryLevel" = "off"
    "update.mode" = "manual"
}

foreach ($key in $additionalSecuritySettings.Keys) {
    $existingConfig | Add-Member -Name $key -Value $additionalSecuritySettings[$key] -MemberType NoteProperty -Force
}

# 7. Save configuration
$mergedConfigJson = $existingConfig | ConvertTo-Json -Depth 10
$mergedConfigJson | Out-File -FilePath $cursorSettingsPath -Encoding UTF8

Write-Host "Security enhancement settings applied successfully!" -ForegroundColor Green

# 8. Display applied settings summary
Write-Host ""
Write-Host "Applied Security Settings Summary:" -ForegroundColor Cyan
Write-Host "MCP Server Security Enhancements:"
Write-Host "  - Filesystem: Read-only operations auto-approved"
Write-Host "  - Playwright: All operations require manual approval"
Write-Host "  - Windows CLI: Safe commands only auto-approved"
Write-Host "  - Context7: Documentation queries only auto-approved"
Write-Host ""
Write-Host "Additional Security Settings:"
Write-Host "  - Workspace trust verification enabled"
Write-Host "  - Extension auto-updates disabled"
Write-Host "  - Telemetry disabled"
Write-Host "  - Manual update mode enabled"
Write-Host ""

# 9. Next steps guidance
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Restart Cursor IDE"
Write-Host "2. Check Settings > MCP for server status"
Write-Host "3. Review security-checklist.md"
Write-Host "4. Run monitoring scripts regularly"
Write-Host ""

Write-Host "Security enhancement application completed!" -ForegroundColor Green
Write-Host "Backup file: $backupPath" -ForegroundColor Gray 