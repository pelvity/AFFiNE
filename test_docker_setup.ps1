Write-Host "🔍 Testing Docker Setup..." -ForegroundColor Cyan

# 1. Check Containers
Write-Host "`n📦 Checking Containers..." -ForegroundColor Yellow
docker-compose ps

# 2. Check Bridge Health
Write-Host "`nbridge Checking Gemini Bridge Health (http://localhost:8765/health)..." -ForegroundColor Yellow
try {
    $bridgeHealth = Invoke-RestMethod -Uri "http://localhost:8765/health" -Method Get -ErrorAction Stop
    Write-Host "✅ Bridge is Healthy!" -ForegroundColor Green
    Write-Host "   Status: $($bridgeHealth.status)"
    Write-Host "   Cookies Valid: $($bridgeHealth.cookies_valid)"
} catch {
    Write-Host "❌ Bridge Health Check Failed: $_" -ForegroundColor Red
}

# 3. Check AFFiNE Health (if available)
# AFFiNE usually exposes /api/health or similar, or just check if port is open
Write-Host "`n🏢 Checking AFFiNE Server..." -ForegroundColor Yellow
$tcp = New-Object System.Net.Sockets.TcpClient
try {
    $tcp.Connect("localhost", 3010)
    Write-Host "✅ AFFiNE Port 3010 is Open!" -ForegroundColor Green
    $tcp.Close()
} catch {
    Write-Host "❌ AFFiNE Port 3010 is Closed" -ForegroundColor Red
}

Write-Host "`n✨ Test Complete" -ForegroundColor Cyan
