# Simple test to check if the application is responding
Write-Host "Testing if application is responding..."

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/api/auth/signin" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username": "admin", "password": "admin123"}' -TimeoutSec 10
    Write-Host "Application is responding! Status: $($response.StatusCode)"
    Write-Host "Response: $($response.Content)"
} catch {
    Write-Host "Application is not responding or there's an error: $($_.Exception.Message)"
} 