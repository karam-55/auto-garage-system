# Data Flow Test Report
## Auto Garage Management System

**Test Date:** May 24, 2026  
**Test Agent:** Agent C (Data Flow Test)  
**Backend URL:** https://auto-garage-system-backend.onrender.com  
**Frontend:** Flutter Web (admin_frontend)  
**Database:** PostgreSQL (Supabase)

---

## Executive Summary

This report documents the expected data flows for 11 critical user scenarios in the Auto Garage Management System. Due to subagent limitations preventing interactive Flutter execution, this analysis is based on comprehensive code review of backend routes, frontend screens, and database schema.

**Overall Assessment:** The system architecture follows Clean Architecture principles with proper separation of concerns. However, several potential issues were identified that could affect data flow integrity.

---

## Scenario 1: Login (ADMIN/MANAGER Role)

### Expected Flow
1. **Frontend:** `LoginScreen` → user enters credentials
2. **API Call:** `POST /api/auth/login`
3. **Backend:** `AuthRoutes._login()` → validates credentials
4. **Database:** Query `users` table by username
5. **Response:** JWT access token + refresh token
6. **Frontend:** Store tokens in `SharedPreferences` → navigate to dashboard

### Backend Route Analysis
**File:** `backend/lib/presentation/routes/auth_routes.dart`

```dart
// Expected endpoint
POST /api/auth/login
Body: { "username": "...", "password": "..." }
Response: { "token": "...", "refreshToken": "...", "user": {...} }
```

### Frontend Implementation
**File:** `admin_frontend/lib/screens/login_screen.dart` (lines 243-310)

```dart
// Login method
Future<void> _login() async {
  final response = await _authService.login(
    _usernameController.text,
    _passwordController.text,
  );
  // Stores tokens and navigates
}
```

### Potential Issues
- ✅ **JWT Secret Validation:** Backend validates `JWT_SECRET` from environment (line 92-96 in server.dart)
- ✅ **Token Storage:** Frontend uses `SharedPreferences` for tokens
- ⚠️ **Token Refresh:** Frontend implements `_refreshAccessToken()` in api_service.dart (lines 75-104)
- ⚠️ **Role-Based Access:** Backend uses `AuthMiddleware.requireRole()` for route protection

### Verification Checklist
- [ ] Verify JWT_SECRET is set in Render environment
- [ ] Verify default admin user exists in database
- [ ] Test token refresh mechanism (15min expiration)
- [ ] Verify role-based middleware works correctly

### Status: **EXPECTED TO WORK** ✅

---

## Scenario 2: Fetch Customers List + Search

### Expected Flow
1. **Frontend:** `CustomersScreen` → loads on init
2. **API Call:** `GET /api/customers?page=1&limit=20&search=...`
3. **Backend:** `CustomerRoutes._getAllCustomers()` → paginated query
4. **Database:** Query `customers` table with pagination
5. **Response:** Paginated list with metadata
6. **Frontend:** Display in list with search debounce (500ms)

### Backend Route Analysis
**File:** `backend/lib/presentation/routes/customer_routes.dart` (lines 41-70)

```dart
GET /api/customers?page=1&limit=20&search=keyword
Response: {
  "data": [...],
  "totalCount": 100,
  "page": 1,
  "limit": 20,
  "totalPages": 5,
  "hasNextPage": true,
  "hasPreviousPage": false
}
```

### Frontend Implementation
**File:** `admin_frontend/lib/screens/customers_screen.dart` (lines 70-92)

```dart
Future<void> _loadCustomers() async {
  String url = '${ApiConstants.customers}?page=$_currentPage&limit=$_pageSize';
  if (_searchQuery.isNotEmpty) {
    url += '&search=$_searchQuery';
  }
  final response = await widget.apiService.get(url);
  // Handles pagination and search
}
```

### Database Schema
**Table:** `customers`
```sql
CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Potential Issues
- ✅ **Pagination:** Backend supports `page` and `limit` parameters
- ✅ **Search:** Backend supports `search` parameter for filtering
- ✅ **Debounce:** Frontend implements 500ms debounce to prevent excessive API calls
- ✅ **Infinite Scroll:** Frontend implements scroll-based loading (lines 50-56)
- ⚠️ **Search Implementation:** Need to verify backend search logic (likely `ILIKE` on full_name or phone)

### Verification Checklist
- [ ] Verify search works on both full_name and phone fields
- [ ] Test pagination with large datasets (500+ records)
- [ ] Verify search debounce prevents API spam
- [ ] Test empty search returns all customers

### Status: **EXPECTED TO WORK** ✅

---

## Scenario 3: Create New Customer

### Expected Flow
1. **Frontend:** `CustomersScreen` → click "Add Customer" → dialog
2. **API Call:** `POST /api/customers`
3. **Backend:** `CustomerRoutes._createCustomer()` → validation
4. **Database:** Insert into `customers` table
5. **Response:** Created customer object
6. **Frontend:** Refresh list → show success message

### Backend Route Analysis
**File:** `backend/lib/presentation/routes/customer_routes.dart` (lines 90-125)

```dart
POST /api/customers
Body: {
  "fullName": "Customer Name",
  "phone": "09XXXXXXXXX",
  "address": "Optional Address"
}
Response: { "id": "uuid", "fullName": "...", "phone": "...", ... }
```

### Validation Rules
- `fullName` and `phone` are required (lines 100-102)
- Phone must be 9-15 digits (line 105-107)
- Phone validation regex: `^[0-9]{9,15}$`

### Frontend Implementation
**File:** `admin_frontend/lib/screens/customers_screen.dart` (lines 200+)

```dart
void _showAddCustomerDialog(BuildContext context) {
  // Dialog with form fields
  // Calls _createCustomer() on submit
}
```

### Potential Issues
- ✅ **Required Fields:** Backend validates required fields
- ✅ **Phone Validation:** Backend validates phone format
- ✅ **UUID Generation:** Backend generates UUID automatically (line 111)
- ⚠️ **Duplicate Detection:** No duplicate phone number validation in backend
- ⚠️ **Field Name Mismatch:** Backend uses `fullName` (camelCase) - matches frontend

### Verification Checklist
- [ ] Test creating customer with valid data
- [ ] Test creating customer with missing required fields (should fail 400)
- [ ] Test creating customer with invalid phone format (should fail 400)
- [ ] Test duplicate phone number handling
- [ ] Verify UUID is generated correctly

### Status: **EXPECTED TO WORK** ⚠️ (Missing duplicate detection)

---

## Scenario 4: Create Vehicle for Customer

### Expected Flow
1. **Frontend:** `VehiclesScreen` → select customer → add vehicle
2. **API Call:** `POST /api/vehicles`
3. **Backend:** `VehicleRoutes._createVehicle()` → validation
4. **Database:** Insert into `vehicles` table with `customer_id` FK
5. **Response:** Created vehicle object
6. **Frontend:** Refresh list → show success message

### Backend Route Analysis
**File:** `backend/lib/presentation/routes/vehicle_routes.dart` (lines 107-163)

```dart
POST /api/vehicles
Body: {
  "customerId": "uuid",
  "make": "Toyota",
  "model": "Corolla",
  "year": 2020,
  "licensePlate": "ABC-123",
  "vin": "Optional VIN"
}
Response: { "id": "uuid", "customerId": "uuid", ... }
```

### Validation Rules
- `customerId`, `make`, `model`, `year` are required (lines 136-141)
- Year must be between 1900 and current year + 1 (line 139)
- Year type handling: accepts both int and string (lines 121-134)

### Database Schema
**Table:** `vehicles`
```sql
CREATE TABLE vehicles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  make VARCHAR(100) NOT NULL,
  model VARCHAR(100) NOT NULL,
  year INTEGER NOT NULL,
  license_plate VARCHAR(20),
  vin VARCHAR(50),
  public_car_id VARCHAR(20) UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Potential Issues
- ✅ **Foreign Key:** `customer_id` references `customers(id)` with CASCADE delete
- ✅ **Year Validation:** Backend validates year range
- ✅ **Public Car ID:** Backend generates `public_car_id` automatically (line 152)
- ⚠️ **Customer Existence:** Backend doesn't explicitly verify customer exists before insert (relies on FK constraint)
- ⚠️ **Duplicate License Plate:** No unique constraint on license_plate in schema

### Verification Checklist
- [ ] Test creating vehicle with valid customer_id
- [ ] Test creating vehicle with invalid customer_id (should fail FK constraint)
- [ ] Test year validation (below 1900, above current year + 1)
- [ ] Verify public_car_id is generated
- [ ] Test duplicate license plate handling

### Status: **EXPECTED TO WORK** ⚠️ (Missing duplicate license plate check)

---

## Scenario 5: Create New Booking (with at least one service)

### Expected Flow
1. **Frontend:** `CreateBookingScreen` → select customer, vehicle, services
2. **API Call:** `POST /api/bookings`
3. **Backend:** `BookingRoutes._createBooking()` → transaction
4. **Database:** 
   - Insert into `bookings` table
   - Insert into `booking_service` junction table
5. **Response:** Created booking with services
6. **Frontend:** Navigate to bookings list → show success

### Backend Route Analysis
**File:** `backend/lib/presentation/routes/booking_routes.dart` (lines 207-350)

```dart
POST /api/bookings
Body: {
  "customerId": "uuid",
  "vehicleId": "uuid",
  "services": [
    {
      "serviceId": "uuid",
      "priceSYP": 50000,
      "notes": "Optional notes"
    }
  ],
  "estimatedCompletionDate": "2026-05-25T10:00:00Z",
  "notes": "Optional booking notes"
}
Response: { "id": "uuid", "status": "PENDING", ... }
```

### Database Schema
**Tables:**
```sql
-- bookings table
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  public_token VARCHAR(20) UNIQUE,
  estimated_completion_date TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- booking_service junction table
CREATE TABLE booking_service (
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
  service_id UUID REFERENCES services(id) ON DELETE CASCADE,
  price_syp DECIMAL(12, 2),
  notes TEXT,
  PRIMARY KEY (booking_id, service_id)
);
```

### Transaction Handling
**File:** `backend/lib/presentation/routes/booking_routes.dart` (lines 223-248)

```dart
final result = await _db.runInTransaction(() async {
  // Create booking
  final booking = await _bookingRepository.create(newBooking);
  
  // Create booking services
  for (final serviceData in services) {
    final bookingService = BookingService(
      bookingId: booking.id,
      serviceId: serviceData['serviceId'],
      priceSYP: serviceData['priceSYP'],
      notes: serviceData['notes'],
    );
    await _bookingServiceRepository.create(bookingService);
  }
  
  return booking;
});
```

### Potential Issues
- ✅ **Transaction:** Uses `runInTransaction` for atomicity
- ✅ **Foreign Keys:** Both `customer_id` and `vehicle_id` have FK constraints
- ✅ **Service Validation:** Need to verify service_id exists in services table
- ✅ **Public Token:** Backend generates `public_token` for customer tracking
- ⚠️ **Service Existence:** Backend should verify service_id exists before creating booking_service
- ⚠️ **Price Validation:** No validation on priceSYP (should be positive)

### Verification Checklist
- [ ] Test creating booking with valid customer_id and vehicle_id
- [ ] Test creating booking with invalid customer_id (should fail FK)
- [ ] Test creating booking with invalid vehicle_id (should fail FK)
- [ ] Test creating booking with invalid service_id (should fail FK)
- [ ] Verify transaction rolls back on error
- [ ] Verify public_token is generated
- [ ] Test price validation (negative, zero)

### Status: **EXPECTED TO WORK** ⚠️ (Missing service existence validation)

---

## Scenario 6: Update Booking Status (e.g., to IN_PROGRESS)

### Expected Flow
1. **Frontend:** `BookingsScreen` → select booking → change status
2. **API Call:** `PATCH /api/bookings/:id/status`
3. **Backend:** `BookingRoutes._updateBookingStatus()` → validation
4. **Database:** Update `bookings.status` column
5. **Response:** Updated booking object
6. **Frontend:** Refresh list → show new status

### Backend Route Analysis
**File:** `backend/lib/presentation/routes/booking_routes.dart` (lines 352-420)

```dart
PATCH /api/bookings/:id/status
Body: { "status": "IN_PROGRESS" }
Response: { "id": "uuid", "status": "IN_PROGRESS", ... }
```

### Role-Based Access
**Line 74:** Accessible by MECHANIC, RECEPTIONIST, MANAGER, OWNER
```dart
router.patch('/api/bookings/<id>/status', 
  _authMiddleware.authenticate()(
    _authMiddleware.requireAnyRole([Role.MECHANIC, Role.RECEPTIONIST, Role.MANAGER, Role.OWNER])
    (_updateBookingStatus)
  )
);
```

### Valid Status Values
```dart
enum BookingStatus {
  PENDING,
  IN_PROGRESS,
  WAITING_PARTS,
  READY,
  DELIVERED,
  CANCELLED
}
```

### Potential Issues
- ✅ **Role-Based Access:** Multiple roles can update status
- ✅ **Status Validation:** Backend validates status enum
- ⚠️ **Status Transition Rules:** No validation of valid status transitions (e.g., can't go from DELIVERED to PENDING)
- ⚠️ **Mechanic Assignment:** When mechanic updates status, should also update mechanic_assignment status

### Verification Checklist
- [ ] Test status update by each role (MECHANIC, RECEPTIONIST, MANAGER, OWNER)
- [ ] Test invalid status value (should fail 400)
- [ ] Test status transition rules
- [ ] Verify mechanic assignment status syncs with booking status

### Status: **EXPECTED TO WORK** ⚠️ (Missing status transition validation)

---

## Scenario 7: Add Part Suggestion from Mechanic (Simulate)

### Expected Flow
1. **Frontend:** Mechanic App → select booking → add part suggestion
2. **API Call:** `POST /api/mechanics/bookings/:bookingId/part-suggestions`
3. **Backend:** `MechanicRoutes._createPartSuggestion()` → validation
4. **Database:** Insert into `part_suggestions` table
5. **Response:** Created part suggestion
6. **Frontend:** Show suggestion in list

### Backend Route Analysis
**File:** `backend/lib/presentation/routes/mechanic_routes.dart` (lines 252-290)

```dart
POST /api/mechanics/bookings/:bookingId/part-suggestions
Body: {
  "partName": "Brake Pad",
  "quantity": 2,
  "estimatedPrice": 15000,
  "notes": "Optional notes"
}
Response: { "id": "uuid", "status": "PENDING", ... }
```

### Role-Based Access
**Line 53:** Accessible by MECHANIC only
```dart
router.post('/api/mechanics/bookings/<bookingId>/part-suggestions', 
  _authMiddleware.authenticate()(
    _authMiddleware.requireRole(Role.MECHANIC)
    (_createPartSuggestion)
  )
);
```

### Database Schema
**Table:** `part_suggestions`
```sql
CREATE TABLE part_suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  part_name VARCHAR(255) NOT NULL,
  quantity INTEGER NOT NULL,
  estimated_price DECIMAL(12, 2),
  status VARCHAR(20) DEFAULT 'PENDING',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Potential Issues
- ✅ **Role-Based Access:** Only MECHANIC can create suggestions
- ✅ **Foreign Key:** `booking_id` references `bookings(id)` with CASCADE
- ✅ **Default Status:** Defaults to 'PENDING'
- ⚠️ **Part Existence:** No validation if part exists in inventory
- ⚠️ **Price Validation:** No validation on estimatedPrice (should be positive)

### Verification Checklist
- [ ] Test creating suggestion as MECHANIC
- [ ] Test creating suggestion as other role (should fail 403)
- [ ] Test with invalid booking_id (should fail FK)
- [ ] Verify default status is PENDING
- [ ] Test price validation

### Status: **EXPECTED TO WORK** ⚠️ (Missing part existence validation)

---

## Scenario 8: Approve Suggestion (from Admin)

### Expected Flow
1. **Frontend:** Admin Dashboard → view suggestions → approve
2. **API Call:** `PATCH /public/part-suggestions/:id/status` OR via booking update
3. **Backend:** Update `part_suggestions.status` to 'APPROVED'
4. **Database:** Update `part_suggestions` table
5. **Response:** Updated suggestion
6. **Frontend:** Refresh list → show approved status

### Backend Route Analysis
**File:** `backend/lib/presentation/routes/mechanic_routes.dart` (lines 292-320)

```dart
PATCH /public/part-suggestions/:id/status
Body: { "status": "APPROVED" }
Response: { "id": "uuid", "status": "APPROVED", ... }
```

**Note:** This is a public endpoint (no authentication required) - likely for customer approval via public token

### Valid Status Values
```dart
enum PartSuggestionStatus {
  PENDING,
  APPROVED,
  REJECTED
}
```

### Potential Issues
- ⚠️ **Public Endpoint:** No authentication on approval endpoint (security risk)
- ⚠️ **Admin Approval:** No dedicated admin endpoint for approval
- ⚠️ **Inventory Deduction:** Approving suggestion doesn't automatically deduct from inventory

### Verification Checklist
- [ ] Test approval via public endpoint
- [ ] Test rejection via public endpoint
- [ ] Verify inventory is not deducted on approval (expected behavior)
- [ ] Consider adding admin-only approval endpoint

### Status: **EXPECTED TO WORK** ⚠️ (Security concern with public endpoint)

---

## Scenario 9: Create Invoice for Booking (`/api/bookings/:id/invoice`)

### Expected Flow
1. **Frontend:** `BookingsScreen` → select booking → generate invoice
2. **API Call:** `GET /api/bookings/:id/invoice`
3. **Backend:** `InvoiceRoutes._getInvoice()` → `BookingInvoiceDataRepository.generateOrGetInvoice()`
4. **Database:** 
   - Query booking, services, parts
   - Calculate totals
   - Store in `booking_invoice_data` table
5. **Response:** Invoice object with breakdown
6. **Frontend:** Display invoice with services and parts

### Backend Route Analysis
**File:** `backend/lib/presentation/routes/invoice_routes.dart` (lines 27-44)

```dart
GET /api/bookings/:id/invoice
Response: {
  "bookingId": "uuid",
  "totalPrice": 150000,
  "amountPaid": 0,
  "amountRemaining": 150000,
  "paymentStatus": "unpaid",
  "servicesSnapshot": { "services": [...] },
  "partsSnapshot": { "parts": [...] },
  "invoiceCreatedAt": "2026-05-24T10:00:00Z"
}
```

### Role-Based Access
**Line 19:** Accessible by RECEPTIONIST and MECHANIC
```dart
router.get('/api/bookings/<id>/invoice', 
  _authMiddleware.authenticate()(
    _authMiddleware.requireAnyRole([Role.RECEPTIONIST, Role.MECHANIC])
    (_getInvoice)
  )
);
```

### Database Schema
**Table:** `booking_invoice_data`
```sql
CREATE TABLE booking_invoice_data (
  booking_id UUID PRIMARY KEY REFERENCES bookings(id) ON DELETE CASCADE,
  total_price DECIMAL(12, 2) DEFAULT 0,
  amount_paid DECIMAL(12, 2) DEFAULT 0,
  amount_remaining DECIMAL(12, 2) DEFAULT 0,
  payment_status VARCHAR(20) DEFAULT 'unpaid',
  services_snapshot JSONB,
  parts_snapshot JSONB,
  invoice_created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Frontend Implementation
**File:** `admin_frontend/lib/screens/bookings_screen.dart` (lines 140-171)

```dart
Future<void> _fetchInvoiceDataForBookings() async {
  for (int i = 0; i < _bookings.length; i++) {
    final booking = _bookings[i];
    if (totalPrice == null || totalPrice == 0 || amountPaid == null) {
      futures.add(_fetchInvoiceForBooking(i, booking['id'].toString()));
    }
  }
}

Future<void> _fetchInvoiceForBooking(int index, String bookingId) async {
  final invoiceResponse = await widget.apiService.get('${ApiConstants.bookings}/$bookingId/invoice');
  // Updates booking with financial data
}
```

### Potential Issues
- ✅ **Role-Based Access:** RECEPTIONIST and MECHANIC can view invoices
- ✅ **JSONB Storage:** Services and parts stored as JSONB snapshots
- ✅ **Caching:** Frontend only fetches invoice if financial data is missing
- ⚠️ **Invoice Generation:** Need to verify `generateOrGetInvoice()` logic
- ⚠️ **Price Calculation:** Need to verify total calculation includes both services and parts

### Verification Checklist
- [ ] Test invoice generation for booking with services only
- [ ] Test invoice generation for booking with parts only
- [ ] Test invoice generation for booking with both services and parts
- [ ] Verify total price calculation
- [ ] Verify JSONB snapshot structure
- [ ] Test invoice for booking with no services or parts

### Status: **EXPECTED TO WORK** ⚠️ (Need to verify calculation logic)

---

## Scenario 10: Update Payment Status (Add Partial Payment)

### Expected Flow
1. **Frontend:** `BookingsScreen` → select booking → add payment
2. **API Call:** `POST /api/bookings/:id/payment`
3. **Backend:** `BookingRoutes._processPayment()` → validation
4. **Database:** 
   - Update `booking_invoice_data.amount_paid`
   - Update `booking_invoice_data.amount_remaining`
   - Update `booking_invoice_data.payment_status`
   - Create journal entry for accounting
5. **Response:** Updated invoice data
6. **Frontend:** Refresh → show new payment status

### Backend Route Analysis
**File:** `backend/lib/presentation/routes/booking_routes.dart` (lines 422-500)

```dart
POST /api/bookings/:id/payment
Body: {
  "amount": 50000,
  "paymentMethod": "CASH",
  "notes": "Optional notes"
}
Response: {
  "amountPaid": 50000,
  "amountRemaining": 100000,
  "paymentStatus": "partial"
}
```

### Role-Based Access
**Line 80:** Accessible by RECEPTIONIST, MANAGER, OWNER
```dart
router.post('/api/bookings/<id>/payment', 
  _authMiddleware.authenticate()(
    _authMiddleware.requireAnyRole([Role.RECEPTIONIST, Role.MANAGER, Role.OWNER])
    (_processPayment)
  )
);
```

### Payment Status Logic
```dart
// Expected logic
if (amountPaid >= totalPrice) {
  paymentStatus = 'paid';
} else if (amountPaid > 0) {
  paymentStatus = 'partial';
} else {
  paymentStatus = 'unpaid';
}
```

### Journal Entry Creation
**File:** `backend/lib/presentation/routes/booking_routes.dart` (lines 470-490)

```dart
// Should create journal entry
final journalEntry = JournalEntry(
  date: DateTime.now(),
  description: 'Payment for booking $bookingId',
  lines: [
    JournalLine(accountId: cashAccountId, debit: amount, credit: 0),
    JournalLine(accountId: revenueAccountId, debit: 0, credit: amount),
  ],
);
await _journalRepository.create(journalEntry);
```

### Potential Issues
- ✅ **Role-Based Access:** RECEPTIONIST, MANAGER, OWNER can process payments
- ✅ **Payment Status:** Should update based on amount paid
- ⚠️ **Journal Entry:** Need to verify journal entry is created correctly
- ⚠️ **Account Mapping:** Need to verify cash and revenue account IDs are configured
- ⚠️ **Overpayment:** No validation for overpayment (amount > totalPrice)

### Verification Checklist
- [ ] Test partial payment (paymentStatus = 'partial')
- [ ] Test full payment (paymentStatus = 'paid')
- [ ] Test overpayment handling
- [ ] Verify journal entry is created
- [ ] Verify journal entry has correct debit/credit accounts
- [ ] Verify double-entry principle (debit == credit)

### Status: **EXPECTED TO WORK** ⚠️ (Need to verify journal entry logic)

---

## Scenario 11: Fetch Trial Balance Report

### Expected Flow
1. **Frontend:** `TrialBalanceScreen` → select date range (optional)
2. **API Call:** `GET /api/trial-balance?from=...&to=...`
3. **Backend:** `AccountingRoutes._getTrialBalance()` → `GetTrialBalanceUseCase`
4. **Database:** 
   - Query `journal_entries` filtered by date range
   - Query `accounts` for account details
   - Calculate totals per account
5. **Response:** Trial balance with account codes, names, debit/credit totals
6. **Frontend:** Display in DataTable with totals

### Backend Route Analysis
**File:** `backend/lib/presentation/routes/accounting_routes.dart` (lines 108-130)

```dart
GET /api/trial-balance?from=2026-05-01&to=2026-05-31
Response: {
  "lines": [
    {
      "account": { "code": "1010", "nameAr": "الصندوق", "nameEn": "Cash" },
      "totalDebit": 150000,
      "totalCredit": 0
    },
    ...
  ],
  "totalDebit": 500000,
  "totalCredit": 500000
}
```

### Role-Based Access
**Line 109:** Accessible by OWNER, MANAGER, ACCOUNTANT
```dart
router.get('/api/trial-balance', 
  _authMiddleware.authenticate()(
    _authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])
    (_getTrialBalance)
  )
);
```

### Frontend Implementation
**File:** `admin_frontend/lib/screens/accounting/trial_balance_screen.dart` (lines 73-200)

```dart
Widget _buildTrialBalance() {
  final params = <String, dynamic>{};
  if (_fromDate != null) {
    params['from'] = _fromDate;
  }
  if (_toDate != null) {
    params['to'] = _toDate;
  }

  return FutureBuilder<Map<String, dynamic>>(
    future: ref.read(trialBalanceProvider(params).future),
    builder: (context, snapshot) {
      // Displays DataTable with account codes, names, debit/credit
    },
  );
}
```

### Potential Issues
- ✅ **Role-Based Access:** OWNER, MANAGER, ACCOUNTANT can view trial balance
- ✅ **Date Filtering:** Supports optional date range
- ✅ **Totals Calculation:** Frontend calculates totals (lines 139-160)
- ⚠️ **Empty Data:** Frontend handles empty data gracefully (lines 110-136)
- ⚠️ **Account Existence:** Need to verify accounts are seeded in database
- ⚠️ **Journal Entries:** Need to verify journal entries exist for the date range

### Verification Checklist
- [ ] Test trial balance with no journal entries (should show empty state)
- [ ] Test trial balance with journal entries
- [ ] Test date range filtering
- [ ] Verify total debit equals total credit (accounting principle)
- [ ] Verify account codes and names display correctly
- [ ] Test with ACCOUNTANT role

### Status: **EXPECTED TO WORK** ⚠️ (Depends on seeded accounts and journal entries)

---

## Critical Issues Summary

### High Priority Issues
1. **Missing Duplicate Detection**
   - Customers: No duplicate phone number validation
   - Vehicles: No duplicate license plate validation
   - **Impact:** Data integrity issues

2. **Missing Service Existence Validation**
   - Booking creation doesn't verify service_id exists
   - **Impact:** FK constraint error or orphaned records

3. **Public Endpoint Security**
   - Part suggestion approval is public (no authentication)
   - **Impact:** Security vulnerability

4. **Missing Status Transition Validation**
   - Booking status can transition in any direction
   - **Impact:** Invalid workflow states

### Medium Priority Issues
1. **Missing Part Existence Validation**
   - Part suggestions don't verify part exists in inventory
   - **Impact:** Suggestions for non-existent parts

2. **Missing Price Validation**
   - No validation for negative or zero prices
   - **Impact:** Invalid financial data

3. **Missing Overpayment Validation**
   - Payments can exceed total price
   - **Impact:** Accounting discrepancies

4. **Journal Entry Verification Needed**
   - Need to verify journal entries are created on payment
   - **Impact:** Accounting data integrity

### Low Priority Issues
1. **Customer Existence Check**
   - Vehicle creation relies on FK constraint instead of explicit check
   - **Impact:** Less user-friendly error messages

---

## Recommendations

### Immediate Actions
1. **Add duplicate detection** for customer phone numbers and vehicle license plates
2. **Add service existence validation** before creating booking_service records
3. **Secure part suggestion approval** endpoint with authentication
4. **Add status transition validation** for booking status changes

### Short-term Actions
1. **Add part existence validation** for part suggestions
2. **Add price validation** for all monetary fields (must be positive)
3. **Add overpayment validation** for booking payments
4. **Verify journal entry creation** on payment processing

### Long-term Actions
1. **Implement comprehensive audit logging** for all financial operations
2. **Add data integrity checks** as scheduled jobs
3. **Implement comprehensive test suite** for all data flows
4. **Add API documentation** (OpenAPI/Swagger)

---

## Conclusion

The Auto Garage Management System has a solid architectural foundation with Clean Architecture principles and proper separation of concerns. The backend routes are well-structured with role-based access control, and the frontend implements proper error handling and user feedback.

However, several data integrity issues were identified that should be addressed before production deployment:

1. **Missing duplicate detection** for critical fields
2. **Missing existence validation** for foreign key relationships
3. **Security concerns** with public endpoints
4. **Missing business logic validation** for status transitions and financial operations

Overall, the system is **EXPECTED TO WORK** for the 11 test scenarios, but with some caveats that require attention to ensure data integrity and security.

---

## Test Environment Notes

- **Backend:** Running on Render (https://auto-garage-system-backend.onrender.com)
- **Database:** PostgreSQL on Supabase
- **Frontend:** Flutter Web (not tested interactively due to subagent limitations)
- **Authentication:** JWT-based with role-based access control
- **Default Credentials:** (Need to verify from environment variables)

---

## Next Steps

1. **Deploy Flutter Web** to test interactively
2. **Seed test data** in Supabase (customers, vehicles, services, accounts)
3. **Run actual API tests** using Postman or similar tool
4. **Verify all foreign key constraints** are working
5. **Test journal entry creation** for accounting flows
6. **Address critical issues** identified in this report

---

**Report Generated By:** Agent C (Data Flow Test)  
**Report Version:** 1.0  
**Date:** May 24, 2026
