# Start AFFiNE Development Services (DB, Redis, Gemini)
# Run this BEFORE starting `yarn affine server dev` locally.

Write-Host "Starting Development Services..."
docker-compose -f docker-compose.services.yml up -d

Write-Host "Waiting for Services to be ready..."
Start-Sleep -Seconds 5

Write-Host "Services are up!"
Write-Host "You can now run 'yarn affine server dev' in a separate terminal."
