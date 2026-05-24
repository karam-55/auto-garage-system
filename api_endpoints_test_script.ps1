# API Endpoints Test Script for Auto Garage Management System
# This script tests all core API endpoints with Supabase
# Run this from the project root directory

$ErrorActionPreference = "Continue"
$BASE_URL = "http://localhost:8080"
$RESULTS = @()

# Helper function to time requests
function Test-Endpoint {
    param(
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [string]$Description = ""
    )
    
    $url = "$BASE_URL$Endpoint"
    $startTime = Get-Date
    
    try {
        if ($Body) {
            $response = Invoke-RestMethod -Method $Method -Uri $url -Headers $Headers -Body $Body -ContentType "application/json" -ErrorAction Stop
        } else {
            $response = Invoke-RestMethod -Method $Method -Uri $url -Headers $Headers -ErrorAction Stop
        }
        
        $endTime = Get-Date
        $duration = [math]::Round(($endTime - $startTime).TotalMilliseconds, 2)
        
        $result = @{
            Endpoint = $Endpoint
            Method = $Method
            Status = "SUCCESS"
            ResponseTime = "${duration}ms"
            Error = ""
            Description = $Description
        }
        
        Write-Host "✓ $Method $Endpoint - ${duration}ms" -ForegroundColor Green
        return $result
    }
    catch {
        $endTime = Get-Date
        $duration = [math]::Round(($endTime - $startTime).TotalMilliseconds, 2)
        $errorMsg = $_.Exception.Message
        
        $result = @{
            Endpoint = $Endpoint
            Method = $Method
            Status = "FAILED"
            ResponseTime = "${duration}ms"
            Error = $errorMsg
            Description = $Description
        }
        
        Write-Host "✗ $Method $Endpoint - ${duration}ms - $errorMsg" -ForegroundColor Red
        return $result
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "API Endpoints Test - Auto Garage System" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if server is running
Write-Host "Checking if backend server is running..." -ForegroundColor Yellow
$healthCheck = Test-Endpoint -Method "GET" -Endpoint "/api/health"
$RESULTS += $healthCheck

if ($healthCheck.Status -eq "FAILED") {
    Write-Host ""
    Write-Host "❌ Backend server is not running or not accessible!" -ForegroundColor Red
    Write-Host "Please start the backend server first:" -ForegroundColor Yellow
    Write-Host "  cd backend && dart bin/server.dart" -ForegroundColor Yellow
    Write-Host "  OR" -ForegroundColor Yellow
    Write-Host "  docker-compose up -d backend" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "Backend server is running. Starting endpoint tests..." -ForegroundColor Green
Write-Host ""

# ================================
# 1. Authentication Endpoints
# ================================
Write-Host "=== Testing Authentication Endpoints ===" -ForegroundColor Cyan

# Test Login
$loginBody = @{
    username = "admin"
    password = "admin123"
} | ConvertTo-Json
$loginResult = Test-Endpoint -Method "POST" -Endpoint "/api/auth/login" -Body $loginBody -Description "Login as admin"
$RESULTS += $loginResult

if ($loginResult.Status -eq "SUCCESS") {
    # Extract token from response (assuming response has accessToken field)
    # Note: Need to parse actual response structure
    $TOKEN = "Bearer YOUR_TOKEN_HERE"  # Placeholder - will need to extract from actual response
    $AUTH_HEADERS = @{
        "Authorization" = $TOKEN
    }
    
    # Test /api/auth/me
    $meResult = Test-Endpoint -Method "GET" -Endpoint "/api/auth/me" -Headers $AUTH_HEADERS -Description "Get current user"
    $RESULTS += $meResult
    
    # Test Refresh Token
    $refreshResult = Test-Endpoint -Method "POST" -Endpoint "/api/auth/refresh" -Headers $AUTH_HEADERS -Description "Refresh token"
    $RESULTS += $refreshResult
} else {
    Write-Host "⚠ Login failed, skipping auth tests that require token" -ForegroundColor Yellow
    $AUTH_HEADERS = @{}
}

Write-Host ""

# ================================
# 2. Booking Endpoints
# ================================
Write-Host "=== Testing Booking Endpoints ===" -ForegroundColor Cyan

# GET /api/bookings (with pagination)
$bookingsResult = Test-Endpoint -Method "GET" -Endpoint "/api/bookings?page=1&limit=10" -Headers $AUTH_HEADERS -Description "List bookings with pagination"
$RESULTS += $bookingsResult

# POST /api/bookings (create new booking)
$newBookingBody = @{
    customerId = "00000000-0000-0000-0000-000000000001"
    vehicleId = "00000000-0000-0000-0000-000000000001"
    serviceIds = @("00000000-0000-0000-0000-000000000001")
    scheduledDate = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
    notes = "API Test Booking"
} | ConvertTo-Json
$createBookingResult = Test-Endpoint -Method "POST" -Endpoint "/api/bookings" -Headers $AUTH_HEADERS -Body $newBookingBody -Description "Create new booking"
$RESULTS += $createBookingResult

# GET /api/bookings/:id (get booking details)
if ($createBookingResult.Status -eq "SUCCESS") {
    # Extract booking ID from response
    $BOOKING_ID = "PLACEHOLDER_ID"  # Will need to extract from actual response
    $bookingDetailResult = Test-Endpoint -Method "GET" -Endpoint "/api/bookings/$BOOKING_ID" -Headers $AUTH_HEADERS -Description "Get booking details"
    $RESULTS += $bookingDetailResult
    
    # PATCH /api/bookings/:id/status
    $updateStatusBody = @{
        status = "IN_PROGRESS"
    } | ConvertTo-Json
    $updateStatusResult = Test-Endpoint -Method "PATCH" -Endpoint "/api/bookings/$BOOKING_ID/status" -Headers $AUTH_HEADERS -Body $updateStatusBody -Description "Update booking status"
    $RESULTS += $updateStatusResult
}

Write-Host ""

# ================================
# 3. Customer & Vehicle Endpoints
# ================================
Write-Host "=== Testing Customer & Vehicle Endpoints ===" -ForegroundColor Cyan

# GET /api/customers
$customersResult = Test-Endpoint -Method "GET" -Endpoint "/api/customers" -Headers $AUTH_HEADERS -Description "List customers"
$RESULTS += $customersResult

# POST /api/customers
$newCustomerBody = @{
    name = "API Test Customer"
    phone = "1234567890"
    email = "apitest@example.com"
    address = "Test Address"
} | ConvertTo-Json
$createCustomerResult = Test-Endpoint -Method "POST" -Endpoint "/api/customers" -Headers $AUTH_HEADERS -Body $newCustomerBody -Description "Create new customer"
$RESULTS += $createCustomerResult

# GET /api/vehicles
$vehiclesResult = Test-Endpoint -Method "GET" -Endpoint "/api/vehicles" -Headers $AUTH_HEADERS -Description "List vehicles"
$RESULTS += $vehiclesResult

# POST /api/vehicles
$newVehicleBody = @{
    customerId = "00000000-0000-0000-0000-000000000001"
    make = "Toyota"
    model = "Camry"
    year = 2024
    licensePlate = "TEST-1234"
    vin = "TESTVIN123456789"
} | ConvertTo-Json
$createVehicleResult = Test-Endpoint -Method "POST" -Endpoint "/api/vehicles" -Headers $AUTH_HEADERS -Body $newVehicleBody -Description "Create new vehicle"
$RESULTS += $createVehicleResult

Write-Host ""

# ================================
# 4. Service Endpoints
# ================================
Write-Host "=== Testing Service Endpoints ===" -ForegroundColor Cyan

# GET /api/services
$servicesResult = Test-Endpoint -Method "GET" -Endpoint "/api/services" -Headers $AUTH_HEADERS -Description "List services"
$RESULTS += $servicesResult

# POST /api/services
$newServiceBody = @{
    name = "API Test Service"
    description = "Test service description"
    price = 100.00
    duration = 60
} | ConvertTo-Json
$createServiceResult = Test-Endpoint -Method "POST" -Endpoint "/api/services" -Headers $AUTH_HEADERS -Body $newServiceBody -Description "Create new service"
$RESULTS += $createServiceResult

Write-Host ""

# ================================
# 5. Dashboard Endpoints
# ================================
Write-Host "=== Testing Dashboard Endpoints ===" -ForegroundColor Cyan

# GET /api/dashboard/stats
$statsResult = Test-Endpoint -Method "GET" -Endpoint "/api/dashboard/stats" -Headers $AUTH_HEADERS -Description "Get dashboard statistics"
$RESULTS += $statsResult

# GET /api/dashboard/revenue
$revenueResult = Test-Endpoint -Method "GET" -Endpoint "/api/dashboard/revenue" -Headers $AUTH_HEADERS -Description "Get revenue statistics"
$RESULTS += $revenueResult

Write-Host ""

# ================================
# 6. Accounting Endpoints
# ================================
Write-Host "=== Testing Accounting Endpoints ===" -ForegroundColor Cyan

# GET /api/accounts
$accountsResult = Test-Endpoint -Method "GET" -Endpoint "/api/accounts" -Headers $AUTH_HEADERS -Description "Get chart of accounts"
$RESULTS += $accountsResult

# POST /api/journal-entries
$newJournalEntryBody = @{
    entryDate = (Get-Date).ToString("yyyy-MM-dd")
    reference = "API-TEST-001"
    description = "API Test Journal Entry"
    lines = @(
        @{
            accountId = "00000000-0000-0000-0000-000000000001"
            debit = 100.00
            credit = 0.00
            description = "Test debit line"
        },
        @{
            accountId = "00000000-0000-0000-0000-000000000002"
            debit = 0.00
            credit = 100.00
            description = "Test credit line"
        }
    )
} | ConvertTo-Json
$createJournalResult = Test-Endpoint -Method "POST" -Endpoint "/api/journal-entries" -Headers $AUTH_HEADERS -Body $newJournalEntryBody -Description "Create journal entry"
$RESULTS += $createJournalResult

# GET /api/trial-balance
$trialBalanceResult = Test-Endpoint -Method "GET" -Endpoint "/api/trial-balance" -Headers $AUTH_HEADERS -Description "Get trial balance"
$RESULTS += $trialBalanceResult

Write-Host ""

# ================================
# 7. Public Endpoints
# ================================
Write-Host "=== Testing Public Endpoints ===" -ForegroundColor Cyan

# GET /public/bookings/:token (no auth required)
# Need a valid public token from a booking
$publicToken = "TEST-TOKEN-PLACEHOLDER"
$publicBookingResult = Test-Endpoint -Method "GET" -Endpoint "/public/bookings/$publicToken" -Description "Get public booking (no auth)"
$RESULTS += $publicBookingResult

Write-Host ""

# ================================
# Generate Report
# ================================
Write-Host "=== Generating Report ===" -ForegroundColor Cyan

$reportPath = "C:\Users\FIX 11\projects\auto garrage\api_endpoints_report.md"
$reportContent = @"
# API Endpoints Test Report

**Test Date:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Base URL:** $BASE_URL

## Summary

| Metric | Count |
|--------|-------|
| Total Endpoints Tested | $($RESULTS.Count) |
| Successful | @($RESULTS | Where-Object { $_.Status -eq "SUCCESS" }).Count) |
| Failed | @($RESULTS | Where-Object { $_.Status -eq "FAILED" }).Count |
| Success Rate | $([math]::Round((@($RESULTS | Where-Object { $_.Status -eq "SUCCESS" }).Count / $RESULTS.Count) * 100, 2))% |

## Detailed Results

| Endpoint | Method | Status | Response Time | Description | Error |
|----------|--------|--------|---------------|-------------|-------|
"@

foreach ($result in $RESULTS) {
    $reportContent += "`n| $($result.Endpoint) | $($result.Method) | $($result.Status) | $($result.ResponseTime) | $($result.Description) | $($result.Error) |"
}

$reportContent += @"

## Notes

- All tests were run against the backend server running on $BASE_URL
- Response times include connection time + Supabase processing time
- Authentication tests require valid credentials (admin/admin123 by default)
- Some tests may fail if required data (customers, vehicles, services) doesn't exist in the database
- Public endpoint test requires a valid booking public token

## Recommendations

"@

if (@($RESULTS | Where-Object { $_.Status -eq "FAILED" }).Count -gt 0) {
    $reportContent += "- Review failed endpoints and fix any errors"
    $reportContent += "- Ensure database has required seed data"
    $reportContent += "- Check Supabase connection and configuration"
} else {
    $reportContent += "- All endpoints are functioning correctly"
    $reportContent += "- Consider adding more comprehensive test cases"
}

$reportContent | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "Report generated at: $reportPath" -ForegroundColor Green
Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
Write-Host "Total: $($RESULTS.Count) | Success: @($RESULTS | Where-Object { $_.Status -eq "SUCCESS" }).Count) | Failed: @($RESULTS | Where-Object { $_.Status -eq "FAILED" }).Count)" -ForegroundColor Cyan
