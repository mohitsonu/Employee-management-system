# Debug Authentication Issues
Write-Host "Debugging Authentication Issues..." -ForegroundColor Green

# Step 1: Login and get token
Write-Host "`nStep 1: Logging in..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/api/auth/signin" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username": "admin", "password": "admin123"}' | ConvertFrom-Json
    $adminToken = $response.accessToken
    Write-Host "✅ Login successful!" -ForegroundColor Green
    Write-Host "Token: $adminToken" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Test GET employees (should work)
Write-Host "`nStep 2: Testing GET /api/employees..." -ForegroundColor Yellow
try {
    $getResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method GET -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "✅ GET /api/employees: SUCCESS (Status: $($getResponse.StatusCode))" -ForegroundColor Green
    Write-Host "Response: $($getResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ GET /api/employees: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Test POST employee with detailed error
Write-Host "`nStep 3: Testing POST /api/employees..." -ForegroundColor Yellow
try {
    $postResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method POST -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $adminToken"} -Body '{"firstName": "Jane", "lastName": "Doe", "email": "jane.doe@example.com"}'
    Write-Host "✅ POST /api/employees: SUCCESS (Status: $($postResponse.StatusCode))" -ForegroundColor Green
    Write-Host "Response: $($postResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ POST /api/employees: FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    # Try to get more details about the error
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error Response: $errorBody" -ForegroundColor Red
    }
}

# Step 4: Test with different role combinations
Write-Host "`nStep 4: Testing different endpoints..." -ForegroundColor Yellow

# Test PUT endpoint
try {
    $putResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees/1" -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $adminToken"} -Body '{"firstName": "John", "lastName": "Doe", "email": "john.doe@example.com"}'
    Write-Host "✅ PUT /api/employees/1: SUCCESS (Status: $($putResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ PUT /api/employees/1: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

# Test DELETE endpoint
try {
    $deleteResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees/1" -Method DELETE -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "✅ DELETE /api/employees/1: SUCCESS (Status: $($deleteResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ DELETE /api/employees/1: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nDebug complete!" -ForegroundColor Green 