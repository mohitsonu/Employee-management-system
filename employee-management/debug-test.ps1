# Debug test to understand the authentication issue
Write-Host "Debugging authentication issue..."

# Test 1: Try to access a public endpoint (if any)
Write-Host "Test 1: Checking if application is accessible..."
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/api/auth/signin" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username": "admin", "password": "admin123"}' -TimeoutSec 10
    Write-Host "Response Status: $($response.StatusCode)"
    Write-Host "Response Headers: $($response.Headers)"
    Write-Host "Response Content: $($response.Content)"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    Write-Host "Error Details: $($_.Exception.Response)"
}

# Test 2: Try with different credentials
Write-Host "`nTest 2: Trying with wrong password..."
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/api/auth/signin" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username": "admin", "password": "wrongpassword"}' -TimeoutSec 10
    Write-Host "Response Status: $($response.StatusCode)"
    Write-Host "Response Content: $($response.Content)"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}

# Test 3: Try with non-existent user
Write-Host "`nTest 3: Trying with non-existent user..."
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/api/auth/signin" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username": "nonexistent", "password": "admin123"}' -TimeoutSec 10
    Write-Host "Response Status: $($response.StatusCode)"
    Write-Host "Response Content: $($response.Content)"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} 