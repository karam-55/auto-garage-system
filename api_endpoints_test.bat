@echo off
REM API Endpoints Test Script for Auto Garage Management System
REM This script tests all core API endpoints with Supabase
REM Run this from the project root directory

setlocal enabledelayedexpansion

set BASE_URL=http://localhost:8080
set RESULTS_FILE=api_endpoints_report.md

echo ========================================
echo API Endpoints Test - Auto Garage System
echo ========================================
echo.

REM Check if server is running
echo Checking if backend server is running...
curl -s -o nul -w "%%{http_code}" %BASE_URL%/api/health
if errorlevel 1 (
    echo.
    echo [ERROR] Backend server is not running or not accessible!
    echo Please start the backend server first:
    echo   cd backend ^&^& dart bin/server.dart
    echo   OR
    echo   docker-compose up -d backend
    echo.
    pause
    exit /b 1
)

echo Backend server is running. Starting endpoint tests...
echo.

REM Test 1: Health Check
echo [1/21] Testing GET /api/health
curl -s -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n" %BASE_URL%/api/health
echo.

REM Test 2: Login
echo [2/21] Testing POST /api/auth/login
curl -s -X POST %BASE_URL%/api/auth/login -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"admin123\"}" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Note: The following tests require a valid JWT token from the login response
REM You'll need to extract the token and set it as AUTH_TOKEN
REM For now, these will likely fail with 401 Unauthorized

REM Test 3: Get Current User
echo [3/21] Testing GET /api/auth/me
curl -s -X GET %BASE_URL%/api/auth/me -H "Authorization: Bearer YOUR_TOKEN_HERE" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 4: Refresh Token
echo [4/21] Testing POST /api/auth/refresh
curl -s -X POST %BASE_URL%/api/auth/refresh -H "Authorization: Bearer YOUR_TOKEN_HERE" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 5: List Bookings
echo [5/21] Testing GET /api/bookings
curl -s -X GET "%BASE_URL%/api/bookings?page=1&limit=10" -H "Authorization: Bearer YOUR_TOKEN_HERE" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 6: Create Booking
echo [6/21] Testing POST /api/bookings
curl -s -X POST %BASE_URL%/api/bookings -H "Authorization: Bearer YOUR_TOKEN_HERE" -H "Content-Type: application/json" -d "{\"customerId\":\"00000000-0000-0000-0000-000000000001\",\"vehicleId\":\"00000000-0000-0000-0000-000000000001\",\"serviceIds\":[\"00000000-0000-0000-0000-000000000001\"],\"scheduledDate\":\"2026-05-24\",\"notes\":\"API Test Booking\"}" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 7: Get Booking Details
echo [7/21] Testing GET /api/bookings/:id
curl -s -X GET %BASE_URL%/api/bookings/00000000-0000-0000-0000-000000000001 -H "Authorization: Bearer YOUR_TOKEN_HERE" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 8: Update Booking Status
echo [8/21] Testing PATCH /api/bookings/:id/status
curl -s -X PATCH %BASE_URL%/api/bookings/00000000-0000-0000-0000-000000000001/status -H "Authorization: Bearer YOUR_TOKEN_HERE" -H "Content-Type: application/json" -d "{\"status\":\"IN_PROGRESS\"}" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 9: List Customers
echo [9/21] Testing GET /api/customers
curl -s -X GET %BASE_URL%/api/customers -H "Authorization: Bearer YOUR_TOKEN_HERE" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 10: Create Customer
echo [10/21] Testing POST /api/customers
curl -s -X POST %BASE_URL%/api/customers -H "Authorization: Bearer YOUR_TOKEN_HERE" -H "Content-Type: application/json" -d "{\"name\":\"API Test Customer\",\"phone\":\"1234567890\",\"email\":\"apitest@example.com\",\"address\":\"Test Address\"}" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 11: List Vehicles
echo [11/21] Testing GET /api/vehicles
curl -s -X GET %BASE_URL%/api/vehicles -H "Authorization: Bearer YOUR_TOKEN_HERE" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 12: Create Vehicle
echo [12/21] Testing POST /api/vehicles
curl -s -X POST %BASE_URL%/api/vehicles -H "Authorization: Bearer YOUR_TOKEN_HERE" -H "Content-Type: application/json" -d "{\"customerId\":\"00000000-0000-0000-0000-000000000001\",\"make\":\"Toyota\",\"model\":\"Camry\",\"year\":2024,\"licensePlate\":\"TEST-1234\",\"vin\":\"TESTVIN123456789\"}" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 13: List Services
echo [13/21] Testing GET /api/services
curl -s -X GET %BASE_URL%/api/services -H "Authorization: Bearer YOUR_TOKEN_HERE" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 14: Create Service
echo [14/21] Testing POST /api/services
curl -s -X POST %BASE_URL%/api/services -H "Authorization: Bearer YOUR_TOKEN_HERE" -H "Content-Type: application/json" -d "{\"name\":\"API Test Service\",\"description\":\"Test service description\",\"price\":100.00,\"duration\":60}" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 15: Dashboard Stats
echo [15/21] Testing GET /api/dashboard/stats
curl -s -X GET %BASE_URL%/api/dashboard/stats -H "Authorization: Bearer YOUR_TOKEN_HERE" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 16: Dashboard Revenue
echo [16/21] Testing GET /api/dashboard/revenue
curl -s -X GET %BASE_URL%/api/dashboard/revenue -H "Authorization: Bearer YOUR_TOKEN_HERE" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 17: Chart of Accounts
echo [17/21] Testing GET /api/accounts
curl -s -X GET %BASE_URL%/api/accounts -H "Authorization: Bearer YOUR_TOKEN_HERE" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 18: Create Journal Entry
echo [18/21] Testing POST /api/journal-entries
curl -s -X POST %BASE_URL%/api/journal-entries -H "Authorization: Bearer YOUR_TOKEN_HERE" -H "Content-Type: application/json" -d "{\"entryDate\":\"2026-05-23\",\"reference\":\"API-TEST-001\",\"description\":\"API Test Journal Entry\",\"lines\":[{\"accountId\":\"00000000-0000-0000-0000-000000000001\",\"debit\":100.00,\"credit\":0.00,\"description\":\"Test debit line\"},{\"accountId\":\"00000000-0000-0000-0000-000000000002\",\"debit\":0.00,\"credit\":100.00,\"description\":\"Test credit line\"}]}" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 19: Trial Balance
echo [19/21] Testing GET /api/trial-balance
curl -s -X GET %BASE_URL%/api/trial-balance -H "Authorization: Bearer YOUR_TOKEN_HERE" -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

REM Test 20: Public Booking
echo [20/21] Testing GET /public/bookings/:token
curl -s -X GET %BASE_URL%/public/bookings/TEST-TOKEN-PLACEHOLDER -w "\nHTTP Status: %%{http_code}\nTime: %%{time_total}s\n"
echo.

echo ========================================
echo Test Complete
echo ========================================
echo.
echo NOTE: Most tests require a valid JWT token.
echo Please extract the token from the login response
echo and replace "YOUR_TOKEN_HERE" in the script.
echo.
pause
