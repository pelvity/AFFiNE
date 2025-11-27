# Test AFFiNE Copilot Chat API Directly
# This script tests the backend chat endpoint without using the frontend

$baseUrl = "http://localhost:3010"

Write-Host "🧪 Testing AFFiNE Copilot Chat API" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Step 1: Create a chat session
Write-Host "`n1️⃣ Creating chat session..." -ForegroundColor Yellow
$createSessionResponse = Invoke-WebRequest -Uri "$baseUrl/api/copilot/chat" `
    -Method POST `
    -ContentType "application/json" `
    -Body '{"workspaceId":"d9f57c30-d800-4790-bbef-75f7ef19f1f5"}' `
    -UseBasicParsing

$session = $createSessionResponse.Content | ConvertFrom-Json
$sessionId = $session.sessionId
Write-Host "✅ Session created: $sessionId" -ForegroundColor Green

# Step 2: Send a chat message
Write-Host "`n2️⃣ Sending chat message..." -ForegroundColor Yellow
$chatUrl = "$baseUrl/api/copilot/chat/$sessionId"
Write-Host "Chat URL: $chatUrl" -ForegroundColor Gray

try {
    $response = Invoke-WebRequest -Uri $chatUrl `
        -Method GET `
        -UseBasicParsing
    
    Write-Host "✅ Response received!" -ForegroundColor Green
    Write-Host "`n📝 Response:" -ForegroundColor Cyan
    Write-Host $response.Content -ForegroundColor White
    
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host "`nStatus Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Yellow
}

# Step 3: Check logs
Write-Host "`n3️⃣ Checking AFFiNE server logs..." -ForegroundColor Yellow
docker logs affine_server --tail 20 --since 1m | Select-String -Pattern "🔍|🚀|✅|💾"

Write-Host "`n4️⃣ Checking Gemini bridge logs..." -ForegroundColor Yellow
docker logs gemini_bridge --tail 20 --since 1m | Select-String -Pattern "📥|✅|200 OK"
