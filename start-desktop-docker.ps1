param (
    [switch]$Web
)

# Start AFFiNE Desktop with Docker Backend

Write-Host "Starting Docker Environment..."
docker-compose -f docker-compose.desktop.yml up -d

Write-Host "Waiting for Backend to be ready..."
Start-Sleep -Seconds 10

# Check if backend is reachable
try {
    Invoke-WebRequest -Uri "http://localhost:3010/api/health" -UseBasicParsing | Out-Null
    Write-Host "Backend is up!"
} catch {
    Write-Host "Backend might still be starting..."
}

Write-Host "Starting Web Frontend (in background)..."
# We need the web frontend for the Electron app to load resources
# Using cmd /c yarn for maximum Windows compatibility
Start-Process -FilePath "cmd" -ArgumentList "/c yarn dev" -WorkingDirectory "packages/frontend/apps/web"

Write-Host "Waiting for Web Frontend (port 8080)..."
$retries = 0
while ($retries -lt 60) {
    $conn = Test-NetConnection -ComputerName localhost -Port 8080 -InformationLevel Quiet
    if ($conn) {
        Write-Host "Web Frontend is ready!"
        break
    }
    Start-Sleep -Seconds 2
    $retries++
    Write-Host "." -NoNewline
}
Write-Host ""

if ($Web) {
    Write-Host "Opening Web Version in Browser..."
    Start-Process "http://localhost:8080"
} else {
    Write-Host "Starting Electron App..."
    Set-Location "packages/frontend/apps/electron"
    yarn dev
}
