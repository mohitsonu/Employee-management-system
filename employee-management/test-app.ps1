# Test Application Status
Write-Host "Testing Employee Management Application..." -ForegroundColor Green

# Check if Java processes are running
$javaProcesses = Get-Process | Where-Object {$_.ProcessName -like "*java*"}
if ($javaProcesses) {
    Write-Host "✅ Java processes are running: $($javaProcesses.Count) processes" -ForegroundColor Green
} else {
    Write-Host "❌ No Java processes found" -ForegroundColor Red
}

# Check if application is listening on port 8082
$port8082 = netstat -an | findstr :8082
if ($port8082) {
    Write-Host "✅ Application is listening on port 8082" -ForegroundColor Green
} else {
    Write-Host "❌ Application is not listening on port 8082" -ForegroundColor Red
}

# Check if application is listening on port 8080
$port8080 = netstat -an | findstr :8080
if ($port8080) {
    Write-Host "✅ Application is listening on port 8080" -ForegroundColor Green
} else {
    Write-Host "❌ Application is not listening on port 8080" -ForegroundColor Red
}

# Try to test the API
Write-Host "`nTesting API endpoints..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/api/auth/signin" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username": "admin", "password": "admin123"}' -TimeoutSec 5
    Write-Host "✅ API is responding on port 8082! Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ API not responding on port 8082: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/signin" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username": "admin", "password": "admin123"}' -TimeoutSec 5
    Write-Host "✅ API is responding on port 8080! Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ API not responding on port 8080: $($_.Exception.Message)" -ForegroundColor Red
} 