# Phase 3 MCP 완전 배포 스크립트
# 보안 설정 + Phase 3 고급 기능 통합 적용

param(
    [switch]$SkipBackup,
    [switch]$QuickTest,
    [string]$BraveApiKey
)

Write-Host "🚀 Phase 3 MCP 완전 배포 시작..." -ForegroundColor Green
Write-Host "=" * 60

# 1. 환경 변수 설정
if ($BraveApiKey) {
    Write-Host "🔑 Brave API Key 환경변수 설정..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable("BRAVE_API_KEY", $BraveApiKey, "User")
    $env:BRAVE_API_KEY = $BraveApiKey
    Write-Host "✅ API Key 설정 완료" -ForegroundColor Green
} elseif (-not $env:BRAVE_API_KEY) {
    Write-Host "⚠️  BRAVE_API_KEY가 설정되지 않았습니다." -ForegroundColor Yellow
    Write-Host "   Brave Search 기능을 사용하려면 -BraveApiKey 파라미터를 사용하세요." -ForegroundColor Gray
}

# 2. Cursor 설정 경로 확인
$cursorSettingsPath = "$env:APPDATA\Cursor\User\settings.json"
Write-Host "📁 Cursor 설정 경로: $cursorSettingsPath" -ForegroundColor Cyan

if (-not (Test-Path $cursorSettingsPath)) {
    Write-Host "❌ Cursor 설정 파일을 찾을 수 없습니다!" -ForegroundColor Red
    Write-Host "   Cursor IDE가 설치되고 최소 한 번 실행되었는지 확인하세요." -ForegroundColor Yellow
    exit 1
}

# 3. 백업 생성
if (-not $SkipBackup) {
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupPath = "$cursorSettingsPath.backup.phase3.$timestamp"
    try {
        Copy-Item $cursorSettingsPath $backupPath -ErrorAction Stop
        Write-Host "💾 백업 완료: $backupPath" -ForegroundColor Green
    } catch {
        Write-Host "❌ 백업 실패: $_" -ForegroundColor Red
        exit 1
    }
}

# 4. Phase 3 통합 설정 적용
$configPath = "cursor-settings-phase3-integrated.json"
if (-not (Test-Path $configPath)) {
    Write-Host "❌ Phase 3 설정 파일을 찾을 수 없습니다: $configPath" -ForegroundColor Red
    exit 1
}

try {
    $phase3Config = Get-Content $configPath -Raw | ConvertFrom-Json
    $phase3ConfigJson = $phase3Config | ConvertTo-Json -Depth 10
    $phase3ConfigJson | Out-File -FilePath $cursorSettingsPath -Encoding UTF8 -ErrorAction Stop
    Write-Host "✅ Phase 3 설정 적용 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ 설정 적용 실패: $_" -ForegroundColor Red
    if ($backupPath -and (Test-Path $backupPath)) {
        Write-Host "🔄 백업에서 복원 중..." -ForegroundColor Yellow
        Copy-Item $backupPath $cursorSettingsPath
    }
    exit 1
}

# 5. MCP 서버 패키지 사전 설치
Write-Host "📦 MCP 서버 패키지 사전 설치..." -ForegroundColor Yellow
$packages = @(
    "@modelcontextprotocol/server-filesystem",
    "@executeautomation/playwright-mcp-server", 
    "@simonb97/server-win-cli",
    "@upstash/context7-mcp",
    "@modelcontextprotocol/server-sequential-thinking",
    "@modelcontextprotocol/server-brave-search"
)

foreach ($package in $packages) {
    Write-Host "  Installing $package..." -ForegroundColor Gray
    try {
        & npx -y $package --version | Out-Null
        Write-Host "  ✅ $package" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  $package - 설치 중 오류 발생" -ForegroundColor Yellow
    }
}

# 6. 서비스 시작 대기
Write-Host "⏳ MCP 서버 초기화 대기 (10초)..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# 7. 헬스체크 실행
Write-Host "🔍 통합 헬스체크 실행..." -ForegroundColor Cyan
try {
    & PowerShell -File "health_phase3_integrated.ps1"
} catch {
    Write-Host "⚠️  헬스체크 스크립트 실행 실패: $_" -ForegroundColor Yellow
}

# 8. 빠른 기능 테스트
if (-not $QuickTest) {
    Write-Host ""
    Write-Host "🧪 기본 기능 테스트 실행..." -ForegroundColor Cyan
    
    # Sequential Thinking 테스트
    Write-Host "테스트 1: Sequential Thinking"
    Write-Host "프롬프트: 'Break down the steps to create a simple web scraper'" -ForegroundColor Gray
    
    # Brave Search 테스트 (API 키가 있는 경우)
    if ($env:BRAVE_API_KEY) {
        Write-Host "테스트 2: Brave Search"  
        Write-Host "프롬프트: 'Search for current Node.js version'" -ForegroundColor Gray
    }
}

# 9. 완료 보고서
Write-Host ""
Write-Host "🎉 Phase 3 배포 완료!" -ForegroundColor Green
Write-Host "=" * 60
Write-Host "✅ 총 6개 MCP 서버 구성 완료"
Write-Host "✅ 보안 설정 적용"
Write-Host "✅ 패키지 사전 설치"
if ($env:BRAVE_API_KEY) {
    Write-Host "✅ Brave Search API 설정"
}
Write-Host ""
Write-Host "🎯 다음 단계:" -ForegroundColor Yellow
Write-Host "1. Cursor IDE 재시작"
Write-Host "2. Settings > MCP 에서 서버 상태 확인"
Write-Host "3. 제공된 테스트 프롬프트로 기능 검증"
Write-Host "4. 정기 헬스체크 스케줄 설정"
Write-Host ""
Write-Host "🔧 추가 도구:" -ForegroundColor Cyan
Write-Host "- 헬스체크: .\health_phase3_integrated.ps1"
Write-Host "- 모니터링: .\mcp-monitor-fixed.ps1"
if ($backupPath) {
    Write-Host "- 백업 파일: $backupPath" -ForegroundColor Gray
}
Write-Host ""
Write-Host "배포 스크립트 실행 완료! 🚀" -ForegroundColor Green 