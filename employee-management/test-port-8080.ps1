# Test if application is running on port 8080
Write-Host "Testing if application is responding on port 8080..."

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/signin" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username": "admin", "password": "admin123"}' -TimeoutSec 10
    Write-Host "Application is responding on port 8080! Status: $($response.StatusCode)"
    Write-Host "Response: $($response.Content)"
} catch {
    Write-Host "Application is not responding on port 8080: $($_.Exception.Message)"
} 