# Test API endpoints
Write-Host "Testing Employee Management API..."

# Step 1: Login and get token
Write-Host "Step 1: Logging in..."
$loginResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/auth/signin" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username": "admin", "password": "admin123"}' | ConvertFrom-Json
$adminToken = $loginResponse.accessToken
Write-Host "Successfully retrieved admin token!"

# Step 2: Test GET employees (should work)
Write-Host "Step 2: Testing GET /api/employees..."
try {
    $getResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method GET -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "GET /api/employees: SUCCESS (Status: $($getResponse.StatusCode))"
    Write-Host "Response: $($getResponse.Content)"
} catch {
    Write-Host "GET /api/employees: FAILED - $($_.Exception.Message)"
}

# Step 3: Test POST employee (should work now)
Write-Host "Step 3: Testing POST /api/employees..."
try {
    $postResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method POST -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $adminToken"} -Body '{"firstName": "Jane", "lastName": "Doe", "email": "jane.doe@example.com"}'
    Write-Host "POST /api/employees: SUCCESS (Status: $($postResponse.StatusCode))"
    Write-Host "Response: $($postResponse.Content)"
} catch {
    Write-Host "POST /api/employees: FAILED - $($_.Exception.Message)"
}

Write-Host "API testing complete!" 