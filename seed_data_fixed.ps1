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
        parent_id = $parentId
        is_active = $true
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/accounts" -Method Post -Body $body -Headers $headers
        Write-Host "âœ“ Account created: $code - $nameAr" -ForegroundColor Green
    } catch {
        Write-Host "âœ— Failed to create account: $code - $_" -ForegroundColor Red
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
        Write-Host "âœ“ Customer created: $fullName" -ForegroundColor Green
    } catch {
        Write-Host "âœ— Failed to create customer: $fullName - $_" -ForegroundColor Red
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
        Write-Host "âœ“ Service created: $name" -ForegroundColor Green
    } catch {
        Write-Host "âœ— Failed to create service: $name - $_" -ForegroundColor Red
    }
}

Write-Host "`n=== Adding Chart of Accounts ===" -ForegroundColor Cyan

# Assets
Add-Account -code "1000" -nameAr "ط§ظ„ط£طµظˆظ„" -nameEn "Assets" -accountType "asset"
Add-Account -code "1100" -nameAr "ط§ظ„طµظ†ط¯ظˆظ‚ ظˆط§ظ„ط¨ظ†ظƒ" -nameEn "Cash and Bank" -accountType "asset"
Add-Account -code "1101" -nameAr "ط§ظ„طµظ†ط¯ظˆظ‚" -nameEn "Cash" -accountType "asset" -parentId 2
Add-Account -code "1200" -nameAr "ط§ظ„ط¹ظ…ظ„ط§ط،" -nameEn "Accounts Receivable" -accountType "asset"
Add-Account -code "1300" -nameAr "ط§ظ„ظ…ط®ط²ظˆظ†" -nameEn "Inventory" -accountType "asset"

# Liabilities
Add-Account -code "2000" -nameAr "ط§ظ„ط®طµظˆظ…" -nameEn "Liabilities" -accountType "liability"
Add-Account -code "2100" -nameAr "ط§ظ„ظ…ظˆط±ط¯ظٹظ†" -nameEn "Accounts Payable" -accountType "liability"

# Equity
Add-Account -code "3000" -nameAr "ط­ظ‚ظˆظ‚ ط§ظ„ظ…ظ„ظƒظٹط©" -nameEn "Equity" -accountType "equity"

# Revenue
Add-Account -code "4000" -nameAr "ط§ظ„ط¥ظٹط±ط§ط¯ط§طھ" -nameEn "Revenue" -accountType "revenue"
Add-Account -code "4100" -nameAr "ط¥ظٹط±ط§ط¯ط§طھ ط§ظ„ط®ط¯ظ…ط§طھ" -nameEn "Service Revenue" -accountType "revenue"
Add-Account -code "4200" -nameAr "ط¥ظٹط±ط§ط¯ط§طھ ظ‚ط·ط¹ ط§ظ„ط؛ظٹط§ط±" -nameEn "Parts Revenue" -accountType "revenue"

# COGS
Add-Account -code "5000" -nameAr "طھظƒظ„ظپط© ط§ظ„ط¨ط¶ط§ط¹ط© ط§ظ„ظ…ط¨ط§ط¹ط©" -nameEn "Cost of Goods Sold" -accountType "cogs"
Add-Account -code "5100" -nameAr "طھظƒظ„ظپط© ظ‚ط·ط¹ ط§ظ„ط؛ظٹط§ط±" -nameEn "Parts COGS" -accountType "cogs"

# Expenses
Add-Account -code "6000" -nameAr "ط§ظ„ظ…طµط±ظˆظپط§طھ" -nameEn "Expenses" -accountType "expense"
Add-Account -code "6100" -nameAr "ظ…طµط±ظˆظپط§طھ ط§ظ„ط±ظˆط§طھط¨" -nameEn "Salary Expenses" -accountType "expense"
Add-Account -code "6200" -nameAr "ظ…طµط±ظˆظپط§طھ ط£ط®ط±ظ‰" -nameEn "Other Expenses" -accountType "expense"

# Additional accounts needed for accounting settings
Add-Account -code "1400" -nameAr "WIP" -nameEn "Work in Progress" -accountType "asset"
Add-Account -code "1501" -nameAr "ظ…ط¬ظ…ط¹ ط§ظ„ط¥ظ‡ظ„ط§ظƒ" -nameEn "Accumulated Depreciation" -accountType "asset"
Add-Account -code "2200" -nameAr "ط¶ط±ظٹط¨ط© ط§ظ„ظ…ط¨ظٹط¹ط§طھ" -nameEn "Sales Tax" -accountType "liability"

Write-Host "`n=== Adding Customers ===" -ForegroundColor Cyan

$customers = @(
    @{fullName = "Ahmed Mohamed"; phone = "0501234567"; address = "Riyadh - Al Nakhil"},
    @{fullName = "Fahad Abdullah"; phone = "0502345678"; address = "Riyadh - Al Malaz"},
    @{fullName = "Khaled Saud"; phone = "0503456789"; address = "Riyadh - Al Olaya"},
    @{fullName = "Mohammed Ali"; phone = "0504567890"; address = "Riyadh - Al Rabwah"},
    @{fullName = "Abdulrahman Ahmed"; phone = "0505678901"; address = "Riyadh - Al Naseem"}
)

foreach ($customer in $customers) {
    Add-Customer -fullName $customer.fullName -phone $customer.phone -address $customer.address
}

Write-Host "`n=== Adding Services ===" -ForegroundColor Cyan

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

Write-Host "`n=== Seeding Complete ===" -ForegroundColor Cyan
