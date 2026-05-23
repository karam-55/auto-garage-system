# PowerShell Script to Seed Data via API
# Auto Garage System

$baseUrl = "https://auto-garage-system-backend.onrender.com"
$authUrl = "$baseUrl/api/auth/login"

# Login to get JWT token
$loginBody = @{
    username = "admin"
    password = "admin123"
} | ConvertTo-Json

Write-Host "Logging in..." -ForegroundColor Yellow
$loginResponse = Invoke-RestMethod -Uri $authUrl -Method Post -Body $loginBody -ContentType "application/json"
$token = $loginResponse.token

if (-not $token) {
    Write-Host "Failed to login" -ForegroundColor Red
    exit 1
}

Write-Host "Login successful!" -ForegroundColor Green

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Function to add Account
function Add-Account {
    param($code, $nameAr, $nameEn, $accountType, $parentId = $null)
    
    $body = @{
        code = $code
        name_ar = $nameAr
        name_en = $nameEn
        account_type = $accountType
        is_active = $true
    }
    
    if ($parentId -ne $null) {
        $body.parent_id = $parentId
    }
    
    $bodyJson = $body | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/accounts" -Method Post -Body $bodyJson -Headers $headers
        Write-Host "Account created: $code - $nameAr (ID: $($response.id))" -ForegroundColor Green
        return $response.id
    } catch {
        Write-Host "Failed to create account: $code - $_" -ForegroundColor Red
        return $null
    }
}

# Function to add Customer
function Add-Customer {
    param($fullName, $phone, $address)
    
    $body = @{
        fullName = $fullName
        phone = $phone
        address = $address
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/customers" -Method Post -Body $body -Headers $headers
        Write-Host "Customer created: $fullName" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create customer: $fullName - $_" -ForegroundColor Red
    }
}

# Function to add Service
function Add-Service {
    param($name, $description, $priceSYP)
    
    $body = @{
        name = $name
        description = $description
        priceSYP = $priceSYP
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/services" -Method Post -Body $body -Headers $headers
        Write-Host "Service created: $name" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create service: $name - $_" -ForegroundColor Red
    }
}

Write-Host "Adding Chart of Accounts" -ForegroundColor Cyan

# Assets - Create parent first, then children
$assetsParentId = Add-Account -code "1000" -nameAr "Assets" -nameEn "Assets" -accountType "asset"
if ($assetsParentId) {
    Add-Account -code "1001" -nameAr "Cash" -nameEn "Cash" -accountType "asset" -parentId $assetsParentId
    Add-Account -code "1002" -nameAr "Bank" -nameEn "Bank" -accountType "asset" -parentId $assetsParentId
    Add-Account -code "1003" -nameAr "Accounts Receivable" -nameEn "Accounts Receivable" -accountType "asset" -parentId $assetsParentId
    Add-Account -code "1004" -nameAr "Inventory" -nameEn "Inventory" -accountType "asset" -parentId $assetsParentId
}

# Liabilities
$liabilitiesParentId = Add-Account -code "2000" -nameAr "Liabilities" -nameEn "Liabilities" -accountType "liability"
if ($liabilitiesParentId) {
    Add-Account -code "2001" -nameAr "Accounts Payable" -nameEn "Accounts Payable" -accountType "liability" -parentId $liabilitiesParentId
    Add-Account -code "2002" -nameAr "Vendors" -nameEn "Vendors" -accountType "liability" -parentId $liabilitiesParentId
}

# Equity
$equityParentId = Add-Account -code "3000" -nameAr "Equity" -nameEn "Equity" -accountType "equity"
if ($equityParentId) {
    Add-Account -code "3001" -nameAr "Capital" -nameEn "Capital" -accountType "equity" -parentId $equityParentId
}

# Revenue
$revenueParentId = Add-Account -code "4000" -nameAr "Revenue" -nameEn "Revenue" -accountType "revenue"
if ($revenueParentId) {
    Add-Account -code "4001" -nameAr "Service Revenue" -nameEn "Service Revenue" -accountType "revenue" -parentId $revenueParentId
    Add-Account -code "4002" -nameAr "Parts Revenue" -nameEn "Parts Revenue" -accountType "revenue" -parentId $revenueParentId
}

# Expenses
$expensesParentId = Add-Account -code "5000" -nameAr "Expenses" -nameEn "Expenses" -accountType "expense"
if ($expensesParentId) {
    Add-Account -code "5001" -nameAr "Salary Expenses" -nameEn "Salary Expenses" -accountType "expense" -parentId $expensesParentId
    Add-Account -code "5002" -nameAr "Depreciation Expenses" -nameEn "Depreciation Expenses" -accountType "expense" -parentId $expensesParentId
    Add-Account -code "5003" -nameAr "Other Expenses" -nameEn "Other Expenses" -accountType "expense" -parentId $expensesParentId
}

Write-Host "Adding Customers" -ForegroundColor Cyan

$customers = @(
    @{fullName = "Ahmed Mohamed"; phone = "0501234567"; address = "Riyadh"},
    @{fullName = "Fahad Abdullah"; phone = "0502345678"; address = "Riyadh"},
    @{fullName = "Khaled Saud"; phone = "0503456789"; address = "Riyadh"},
    @{fullName = "Mohammed Ali"; phone = "0504567890"; address = "Riyadh"},
    @{fullName = "Abdulrahman Ahmed"; phone = "0505678901"; address = "Riyadh"}
)

foreach ($customer in $customers) {
    Add-Customer -fullName $customer.fullName -phone $customer.phone -address $customer.address
}

Write-Host "Adding Services" -ForegroundColor Cyan

$services = @(
    @{name = "Oil Change"; description = "Engine oil and filter change"; priceSYP = 150},
    @{name = "Brake Service"; description = "Brake inspection and replacement"; priceSYP = 300},
    @{name = "Battery Replacement"; description = "Battery inspection and replacement"; priceSYP = 400},
    @{name = "AC Service"; description = "AC inspection and refill"; priceSYP = 200},
    @{name = "Tire Replacement"; description = "Tire inspection and replacement"; priceSYP = 500}
)

foreach ($service in $services) {
    Add-Service -name $service.name -description $service.description -priceSYP $service.priceSYP
}

Write-Host "Seeding Complete" -ForegroundColor Cyan
