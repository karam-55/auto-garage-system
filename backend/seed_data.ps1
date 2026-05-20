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
        [hashtable]$Data,
        [string]$Method = "Post"
    )
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
    }
    
    try {
        $body = $Data | ConvertTo-Json -Depth 10
        $response = Invoke-RestMethod -Uri "${baseUrl}${Endpoint}" -Method $Method -Headers $headers -Body $body
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
    @{ code = "1000"; name_ar = "Cash"; name_en = "Cash"; parent_id = $null; account_type = "asset"; is_active = $true },
    @{ code = "1100"; name_ar = "Bank"; name_en = "Bank"; parent_id = $null; account_type = "asset"; is_active = $true },
    @{ code = "1200"; name_ar = "Accounts Receivable"; name_en = "Accounts Receivable"; parent_id = $null; account_type = "asset"; is_active = $true },
    @{ code = "1300"; name_ar = "Inventory"; name_en = "Inventory"; parent_id = $null; account_type = "asset"; is_active = $true },
    @{ code = "1400"; name_ar = "Fixed Assets"; name_en = "Fixed Assets"; parent_id = $null; account_type = "asset"; is_active = $true },
    @{ code = "2000"; name_ar = "Accounts Payable"; name_en = "Accounts Payable"; parent_id = $null; account_type = "liability"; is_active = $true },
    @{ code = "2100"; name_ar = "Accrued Salaries"; name_en = "Accrued Salaries"; parent_id = $null; account_type = "liability"; is_active = $true },
    @{ code = "2200"; name_ar = "Sales Tax Payable"; name_en = "Sales Tax Payable"; parent_id = $null; account_type = "liability"; is_active = $true },
    @{ code = "3000"; name_ar = "Capital"; name_en = "Capital"; parent_id = $null; account_type = "equity"; is_active = $true },
    @{ code = "3100"; name_ar = "Retained Earnings"; name_en = "Retained Earnings"; parent_id = $null; account_type = "equity"; is_active = $true },
    @{ code = "4000"; name_ar = "Service Revenue"; name_en = "Service Revenue"; parent_id = $null; account_type = "revenue"; is_active = $true },
    @{ code = "4100"; name_ar = "Parts Revenue"; name_en = "Parts Revenue"; parent_id = $null; account_type = "revenue"; is_active = $true },
    @{ code = "4200"; name_ar = "Other Revenue"; name_en = "Other Revenue"; parent_id = $null; account_type = "revenue"; is_active = $true },
    @{ code = "5000"; name_ar = "COGS - Parts"; name_en = "COGS - Parts"; parent_id = $null; account_type = "cogs"; is_active = $true },
    @{ code = "5100"; name_ar = "COGS - Services"; name_en = "COGS - Services"; parent_id = $null; account_type = "cogs"; is_active = $true },
    @{ code = "5200"; name_ar = "Salaries Expense"; name_en = "Salaries Expense"; parent_id = $null; account_type = "expense"; is_active = $true },
    @{ code = "5300"; name_ar = "Rent Expense"; name_en = "Rent Expense"; parent_id = $null; account_type = "expense"; is_active = $true },
    @{ code = "5400"; name_ar = "Utilities Expense"; name_en = "Utilities Expense"; parent_id = $null; account_type = "expense"; is_active = $true },
    @{ code = "5500"; name_ar = "Other Expenses"; name_en = "Other Expenses"; parent_id = $null; account_type = "expense"; is_active = $true }
)

foreach ($account in $accounts) {
    $result = Add-Data -Endpoint "/api/accounts" -Token $token -Data $account
    if ($result) {
        Write-Host "Added account: $($account.code) - $($account.name_en)"
    }
}

# Add vendors
Write-Host "Adding vendors..."
$vendors = @(
    @{ name = "Vendor A - Original Parts"; phone = "0911123456"; address = "Damascus, Jobar"; tax_number = "123456789" },
    @{ name = "Vendor B - Commercial Parts"; phone = "0922345678"; address = "Rif Dimashq, Adra"; tax_number = "987654321" },
    @{ name = "Vendor C - Oils"; phone = "0933456789"; address = "Homs, Station"; tax_number = "456789123" }
)

foreach ($vendor in $vendors) {
    $result = Add-Data -Endpoint "/vendors" -Token $token -Data $vendor
    if ($result) {
        Write-Host "Added vendor: $($vendor.name)"
    }
}

# Skip inventory - it's created automatically
Write-Host "Skipping inventory (created automatically)"

# Add expenses
Write-Host "Adding expenses..."
$expenses = @(
    @{ expense_date = "2024-05-15"; account_id = 5300; amount = 300000; description = "Garage rent for May"; payment_method = "cash" },
    @{ expense_date = "2024-05-18"; account_id = 5400; amount = 85000; description = "Electricity bill"; payment_method = "cash" },
    @{ expense_date = "2024-05-20"; account_id = 5400; amount = 45000; description = "Water bill"; payment_method = "cash" }
)

foreach ($expense in $expenses) {
    $result = Add-Data -Endpoint "/expenses" -Token $token -Data $expense
    if ($result) {
        Write-Host "Added expense: $($expense.description)"
    }
}

# Skip fiscal periods - endpoint not implemented
Write-Host "Skipping fiscal periods (endpoint not implemented)"

# Add bank accounts
Write-Host "Adding bank accounts..."
$bankAccounts = @(
    @{ account_name = "Syrian Arab Bank"; account_number = "1234567890"; bank_name = "Syrian Arab Bank"; initial_balance = 5000000; account_id = 1100 },
    @{ account_name = "Bank of Syria and Overseas"; account_number = "0987654321"; bank_name = "Bank of Syria and Overseas"; initial_balance = 3000000; account_id = 1100 },
    @{ account_name = "Garage Cash"; account_number = "CASH001"; bank_name = "Cash"; initial_balance = 1000000; account_id = 1000 }
)

foreach ($account in $bankAccounts) {
    $result = Add-Data -Endpoint "/bank-accounts" -Token $token -Data $account
    if ($result) {
        Write-Host "Added bank account: $($account.account_name)"
    }
}

# Add payroll settings
Write-Host "Adding payroll settings..."
$payrollSettings = @{
    monthly_work_days = 22
    salary_payment_day = 1
}

# Use PUT instead of POST for payroll/settings
$result = Add-Data -Endpoint "/payroll/settings" -Token $token -Data $payrollSettings -Method "PUT"
if ($result) {
    Write-Host "Added payroll settings"
}

Write-Host "Data seeding completed!"
