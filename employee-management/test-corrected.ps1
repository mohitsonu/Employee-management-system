# Corrected Test Script with Position Field
Write-Host "Testing Employee Creation with Correct Data..." -ForegroundColor Green

# Step 1: Login and get token
Write-Host "`nStep 1: Logging in..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/api/auth/signin" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username": "admin", "password": "admin123"}' | ConvertFrom-Json
    $adminToken = $response.accessToken
    Write-Host "✅ Login successful!" -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Test employee creation with ALL required fields
Write-Host "`nStep 2: Testing employee creation with position field..." -ForegroundColor Yellow
try {
    $employeeData = @{
        firstName = "Jane"
        lastName = "Doe"
        email = "jane.doe@example.com"
        position = "Software Engineer"
    } | ConvertTo-Json

    $createResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method POST -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $adminToken"} -Body $employeeData
    Write-Host "✅ Employee created successfully!" -ForegroundColor Green
    Write-Host "Status: $($createResponse.StatusCode)" -ForegroundColor Cyan
    Write-Host "Response: $($createResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Employee creation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Test getting all employees
Write-Host "`nStep 3: Testing get all employees..." -ForegroundColor Yellow
try {
    $getResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method GET -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "✅ Employees retrieved successfully!" -ForegroundColor Green
    Write-Host "Status: $($getResponse.StatusCode)" -ForegroundColor Cyan
    Write-Host "Employees: $($getResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Get employees failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTest complete!" -ForegroundColor Green 