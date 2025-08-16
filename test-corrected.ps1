# Test script for employee creation with corrected data
Write-Host "Testing Employee Management System..." -ForegroundColor Green

# Step 1: Login to get admin token
Write-Host "`n1. Logging in as admin..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/auth/signin" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username": "admin", "password": "admin123"}' | ConvertFrom-Json
    $adminToken = $loginResponse.accessToken
    Write-Host "✅ Login successful! Token retrieved." -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Test GET employees (should work)
Write-Host "`n2. Testing GET /api/employees..." -ForegroundColor Yellow
try {
    $getResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method GET -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "✅ GET request successful! Status: $($getResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($getResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ GET request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Test POST employee creation (with position field)
Write-Host "`n3. Testing POST /api/employees (with position field)..." -ForegroundColor Yellow
$employeeData = @{
    firstName = "Jane"
    lastName = "Doe"
    email = "jane.doe@example.com"
    position = "Software Engineer"
    department = "Engineering"
    salary = 75000
} | ConvertTo-Json

try {
    $postResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method POST -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $adminToken"} -Body $employeeData
    Write-Host "✅ POST request successful! Status: $($postResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($postResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ POST request failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorContent = $reader.ReadToEnd()
        Write-Host "Error details: $errorContent" -ForegroundColor Red
    }
}

# Step 4: Verify the employee was created by getting all employees again
Write-Host "`n4. Verifying employee creation..." -ForegroundColor Yellow
try {
    $verifyResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method GET -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "✅ Verification successful! Status: $($verifyResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Updated employee list: $($verifyResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Verification failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTest completed!" -ForegroundColor Green 