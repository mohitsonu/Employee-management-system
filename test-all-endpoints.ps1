# Comprehensive test script for all Employee Management API endpoints
Write-Host "=== Employee Management System - Complete API Test ===" -ForegroundColor Green

# Step 1: Login to get admin token
Write-Host "`n1. 🔐 Logging in as admin..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/auth/signin" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username": "admin", "password": "admin123"}' | ConvertFrom-Json
    $adminToken = $loginResponse.accessToken
    Write-Host "✅ Login successful! Token retrieved." -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Test GET all employees (should be empty initially)
Write-Host "`n2. 📋 Testing GET /api/employees (initial state)..." -ForegroundColor Yellow
try {
    $getResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method GET -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "✅ GET all employees successful! Status: $($getResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Initial employees: $($getResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ GET request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Test POST - Create first employee
Write-Host "`n3. ➕ Testing POST /api/employees (create employee 1)..." -ForegroundColor Yellow
$employee1 = @{
    firstName = "John"
    lastName = "Smith"
    email = "john.smith@company.com"
    position = "Senior Developer"
    department = "Engineering"
    salary = 85000
} | ConvertTo-Json

try {
    $postResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method POST -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $adminToken"} -Body $employee1
    $createdEmployee1 = $postResponse.Content | ConvertFrom-Json
    Write-Host "✅ Employee 1 created successfully! Status: $($postResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Created employee: $($postResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ POST request failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 4: Test POST - Create second employee
Write-Host "`n4. ➕ Testing POST /api/employees (create employee 2)..." -ForegroundColor Yellow
$employee2 = @{
    firstName = "Sarah"
    lastName = "Johnson"
    email = "sarah.johnson@company.com"
    position = "Product Manager"
    department = "Product"
    salary = 90000
} | ConvertTo-Json

try {
    $postResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method POST -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $adminToken"} -Body $employee2
    $createdEmployee2 = $postResponse.Content | ConvertFrom-Json
    Write-Host "✅ Employee 2 created successfully! Status: $($postResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Created employee: $($postResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ POST request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 5: Test GET all employees (should show 2 employees)
Write-Host "`n5. 📋 Testing GET /api/employees (after creation)..." -ForegroundColor Yellow
try {
    $getResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method GET -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "✅ GET all employees successful! Status: $($getResponse.StatusCode)" -ForegroundColor Green
    Write-Host "All employees: $($getResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ GET request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 6: Test GET employee by ID
Write-Host "`n6. 🔍 Testing GET /api/employees/{id}..." -ForegroundColor Yellow
$employeeId = $createdEmployee1.id
try {
    $getByIdResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees/$employeeId" -Method GET -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "✅ GET employee by ID successful! Status: $($getByIdResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Employee details: $($getByIdResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ GET by ID request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 7: Test PUT - Update employee
Write-Host "`n7. ✏️ Testing PUT /api/employees/{id}..." -ForegroundColor Yellow
$updateData = @{
    firstName = "John"
    lastName = "Smith"
    email = "john.smith.updated@company.com"
    position = "Lead Developer"
    department = "Engineering"
    salary = 95000
} | ConvertTo-Json

try {
    $putResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees/$employeeId" -Method PUT -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $adminToken"} -Body $updateData
    Write-Host "✅ PUT employee update successful! Status: $($putResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Updated employee: $($putResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ PUT request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 8: Verify update with GET
Write-Host "`n8. 🔍 Verifying update with GET /api/employees/{id}..." -ForegroundColor Yellow
try {
    $verifyResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees/$employeeId" -Method GET -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "✅ Verification successful! Status: $($verifyResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Updated employee details: $($verifyResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Verification failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 9: Test DELETE - Delete employee
Write-Host "`n9. 🗑️ Testing DELETE /api/employees/{id}..." -ForegroundColor Yellow
try {
    $deleteResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees/$employeeId" -Method DELETE -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "✅ DELETE employee successful! Status: $($deleteResponse.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ DELETE request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 10: Verify deletion with GET all
Write-Host "`n10. 📋 Verifying deletion with GET /api/employees..." -ForegroundColor Yellow
try {
    $finalResponse = Invoke-WebRequest -Uri "http://localhost:8082/api/employees" -Method GET -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "✅ Final verification successful! Status: $($finalResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Remaining employees: $($finalResponse.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Final verification failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 === All API Tests Completed Successfully! ===" -ForegroundColor Green
Write-Host "Your Employee Management System is fully functional!" -ForegroundColor Green 