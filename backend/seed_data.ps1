# PowerShell script to seed sample data via API
# This script logs in to the backend and adds sample data

$baseUrl = "https://auto-garage-system-backend.onrender.com"

# Login credentials
$username = "admin"
$password = "admin123"

# Function to login and get JWT token
function Get-AuthToken {
    $body = @{
        username = $username
        password = $password
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body $body -ContentType "application/json"
        return $response.token
    }
    catch {
        Write-Error "Login failed: $_"
        return $null
    }
}

# Function to get data via API
function Get-Data {
    param(
        [string]$Endpoint,
        [string]$Token
    )
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
    }
    
    try {
        $response = Invoke-RestMethod -Uri "${baseUrl}${Endpoint}" -Method Get -Headers $headers
        return $response
    }
    catch {
        Write-Error "Failed to get data from ${Endpoint}: $_"
        return $null
    }
}
function Add-Data {
    param(
        [string]$Endpoint,
        [string]$Token,
        [hashtable]$Data
    )
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
    }
    
    try {
        $body = $Data | ConvertTo-Json -Depth 10
        $response = Invoke-RestMethod -Uri "${baseUrl}${Endpoint}" -Method Post -Headers $headers -Body $body
        return $response
    }
    catch {
        Write-Error "Failed to add data to ${Endpoint}: $_"
        return $null
    }
}

# Main script
Write-Host "Starting accounting data seeding..."

# Wait a bit to avoid rate limiting
Start-Sleep -Seconds 5

# Login
$token = Get-AuthToken
if (-not $token) {
    Write-Error "Failed to login. Exiting."
    exit 1
}

Write-Host "Login successful. Token: $token"

# Skip customers and vehicles - they are created automatically
Write-Host "Skipping customers and vehicles (created automatically)"

# Add accounts (Chart of Accounts)
Write-Host "Adding accounts (Chart of Accounts)..."
$accounts = @(
    @{ code = "1000"; nameAr = "Cash"; nameEn = "Cash"; accountType = "asset"; isActive = $true },
    @{ code = "1100"; nameAr = "Bank"; nameEn = "Bank"; accountType = "asset"; isActive = $true },
    @{ code = "1200"; nameAr = "Accounts Receivable"; nameEn = "Accounts Receivable"; accountType = "asset"; isActive = $true },
    @{ code = "1300"; nameAr = "Inventory"; nameEn = "Inventory"; accountType = "asset"; isActive = $true },
    @{ code = "1400"; nameAr = "Fixed Assets"; nameEn = "Fixed Assets"; accountType = "asset"; isActive = $true },
    @{ code = "2000"; nameAr = "Accounts Payable"; nameEn = "Accounts Payable"; accountType = "liability"; isActive = $true },
    @{ code = "2100"; nameAr = "Accrued Salaries"; nameEn = "Accrued Salaries"; accountType = "liability"; isActive = $true },
    @{ code = "2200"; nameAr = "Sales Tax Payable"; nameEn = "Sales Tax Payable"; accountType = "liability"; isActive = $true },
    @{ code = "3000"; nameAr = "Capital"; nameEn = "Capital"; accountType = "equity"; isActive = $true },
    @{ code = "3100"; nameAr = "Retained Earnings"; nameEn = "Retained Earnings"; accountType = "equity"; isActive = $true },
    @{ code = "4000"; nameAr = "Service Revenue"; nameEn = "Service Revenue"; accountType = "revenue"; isActive = $true },
    @{ code = "4100"; nameAr = "Parts Revenue"; nameEn = "Parts Revenue"; accountType = "revenue"; isActive = $true },
    @{ code = "4200"; nameAr = "Other Revenue"; nameEn = "Other Revenue"; accountType = "revenue"; isActive = $true },
    @{ code = "5000"; nameAr = "COGS - Parts"; nameEn = "COGS - Parts"; accountType = "cogs"; isActive = $true },
    @{ code = "5100"; nameAr = "COGS - Services"; nameEn = "COGS - Services"; accountType = "cogs"; isActive = $true },
    @{ code = "5200"; nameAr = "Salaries Expense"; nameEn = "Salaries Expense"; accountType = "expense"; isActive = $true },
    @{ code = "5300"; nameAr = "Rent Expense"; nameEn = "Rent Expense"; accountType = "expense"; isActive = $true },
    @{ code = "5400"; nameAr = "Utilities Expense"; nameEn = "Utilities Expense"; accountType = "expense"; isActive = $true },
    @{ code = "5500"; nameAr = "Other Expenses"; nameEn = "Other Expenses"; accountType = "expense"; isActive = $true }
)

foreach ($account in $accounts) {
    $result = Add-Data -Endpoint "/api/accounts" -Token $token -Data $account
    if ($result) {
        Write-Host "Added account: $($account.code) - $($account.nameEn)"
    }
}

# Add vendors
Write-Host "Adding vendors..."
$vendors = @(
    @{ name = "Vendor A - Original Parts"; phone = "0911123456"; address = "Damascus, Jobar"; taxNumber = "123456789" },
    @{ name = "Vendor B - Commercial Parts"; phone = "0922345678"; address = "Rif Dimashq, Adra"; taxNumber = "987654321" },
    @{ name = "Vendor C - Oils"; phone = "0933456789"; address = "Homs, Station"; taxNumber = "456789123" }
)

foreach ($vendor in $vendors) {
    $result = Add-Data -Endpoint "/api/vendors" -Token $token -Data $vendor
    if ($result) {
        Write-Host "Added vendor: $($vendor.name)"
    }
}

# Skip inventory - it's created automatically
Write-Host "Skipping inventory (created automatically)"

# Add expenses
Write-Host "Adding expenses..."
$expenses = @(
    @{ expenseDate = "2024-05-15"; accountId = "5300"; amount = 300000; description = "Garage rent for May"; paymentMethod = "cash" },
    @{ expenseDate = "2024-05-18"; accountId = "5400"; amount = 85000; description = "Electricity bill"; paymentMethod = "cash" },
    @{ expenseDate = "2024-05-20"; accountId = "5400"; amount = 45000; description = "Water bill"; paymentMethod = "cash" }
)

foreach ($expense in $expenses) {
    $result = Add-Data -Endpoint "/api/expenses" -Token $token -Data $expense
    if ($result) {
        Write-Host "Added expense: $($expense.description)"
    }
}

# Add fiscal periods
Write-Host "Adding fiscal periods..."
$fiscalPeriods = @(
    @{ name = "2024"; startDate = "2024-01-01"; endDate = "2024-12-31"; isClosed = $false },
    @{ name = "Q1 2024"; startDate = "2024-01-01"; endDate = "2024-03-31"; isClosed = $false },
    @{ name = "Q2 2024"; startDate = "2024-04-01"; endDate = "2024-06-30"; isClosed = $false },
    @{ name = "Q3 2024"; startDate = "2024-07-01"; endDate = "2024-09-30"; isClosed = $false },
    @{ name = "Q4 2024"; startDate = "2024-10-01"; endDate = "2024-12-31"; isClosed = $false }
)

foreach ($period in $fiscalPeriods) {
    $result = Add-Data -Endpoint "/api/fiscal-periods" -Token $token -Data $period
    if ($result) {
        Write-Host "Added fiscal period: $($period.name)"
    }
}

# Add bank accounts
Write-Host "Adding bank accounts..."
$bankAccounts = @(
    @{ accountName = "Syrian Arab Bank"; accountNumber = "1234567890"; bankName = "Syrian Arab Bank"; initialBalance = 5000000; currentBalance = 5000000; accountId = "1100"; isActive = $true },
    @{ accountName = "Bank of Syria and Overseas"; accountNumber = "0987654321"; bankName = "Bank of Syria and Overseas"; initialBalance = 3000000; currentBalance = 3000000; accountId = "1100"; isActive = $true },
    @{ accountName = "Garage Cash"; accountNumber = "CASH001"; bankName = "Cash"; initialBalance = 1000000; currentBalance = 1000000; accountId = "1000"; isActive = $true }
)

foreach ($account in $bankAccounts) {
    $result = Add-Data -Endpoint "/api/bank-accounts" -Token $token -Data $account
    if ($result) {
        Write-Host "Added bank account: $($account.accountName)"
    }
}

# Add payroll settings
Write-Host "Adding payroll settings..."
$payrollSettings = @{
    monthlyWorkDays = 22
    salaryPaymentDay = 1
}

$result = Add-Data -Endpoint "/api/payroll-settings" -Token $token -Data $payrollSettings
if ($result) {
    Write-Host "Added payroll settings"
}

Write-Host "Data seeding completed!"
