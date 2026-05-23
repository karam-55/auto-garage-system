# Garage Go - Knowledge Base Management

**Generated:** May 24, 2026  
**Project:** Auto Garage Management System (Garage Go)  
**Purpose:** Architectural patterns, best practices, and knowledge entries  
**Status:** Active

---

## 📋 Overview

هذا الملف يدير قاعدة المعرفة لمشروع Garage Go، موثقاً الأنماط المعمارية الناشئة، أفضل الممارسات، وإدخالات المعرفة الجديدة. الهدف هو الحفاظ على قاعدة معرفة محددة وموثوقة يمكن الرجوع إليها في المستقبل.

---

## 🎯 Existing Knowledge Entries

### 1. Clean Architecture Principles

**الوصف:** المشروع يتبع Clean Architecture مع 4 طبقات منفصلة

**الطبقات:**
- **Domain Layer:** Entities و Repository Interfaces
- **Application Layer:** Use Cases و Services
- **Infrastructure Layer:** Repository Implementations و Database
- **Presentation Layer:** Routes و Middlewares

**القواعد:**
- Dependencies ت指向 inward فقط
- Domain Layer لا يعتمد على أي طبقة أخرى
- Business logic في Application Layer
- External concerns في Infrastructure Layer

**المراجع:**
- `backend/lib/domain/`
- `backend/lib/application/`
- `backend/lib/infrastructure/`
- `backend/lib/presentation/`

---

### 2. Field Name Mapping Conventions

**الوصف:** كيفية mapping field names بين Database و Backend و Frontend

**القواعد:**
- **Database:** snake_case (`entry_date`, `account_type`)
- **Backend Entities:** camelCase (`entryDate`, `accountType`)
- **Backend JSON:** snake_case (`entry_date`, `account_type`)
- **Frontend Models:** camelCase (`entryDate`, `accountType`)
- **Frontend JSON Parsing:** handle snake_case from API

**مثال:**
```dart
// Backend Entity
class JournalEntry {
  final DateTime entryDate;  // camelCase
  final String accountType;  // camelCase
  
  Map<String, dynamic> toJson() {
    return {
      'entry_date': entryDate.toIso8601String(),  // snake_case in JSON
      'account_type': accountType,  // snake_case in JSON
    };
  }
  
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      entryDate: DateTime.parse(json['entry_date'] as String),  // parse snake_case
      accountType: json['account_type'] as String,  // parse snake_case
    );
  }
}
```

**المراجع:**
- `.cursorrules` - Field Name Consistency section
- `AGENTS.md` - Known Issues section

---

### 3. Null Safety Patterns

**الوصف:** كيفية استخدام null safety في المشروع

**القواعد:**
- استخدم `String?` للحقول الاختيارية
- استخدم `String` للحقول المطلوبة
- تحقق من null قبل الاستخدام
- استخدم `??` operator للقيم الافتراضية

**مثال:**
```dart
class Booking {
  final String id;  // Required
  final String? notes;  // Optional
  final DateTime createdAt;  // Required
  
  Booking({
    required this.id,
    this.notes,  // Optional
    required this.createdAt,
  });
  
  void printNotes() {
    print(notes ?? 'No notes');  // Use default if null
  }
}
```

**المراجع:**
- `.cursorrules` - Null Safety section
- `AGENTS.md` - Known Issues section

---

### 4. Pagination Implementation

**الوصف:** كيفية تنفيذ pagination في Backend و Frontend

**Backend:**
```dart
Future<PaginationResult<T>> findAllPaginated({
  int page = 1,
  int limit = 20,
}) async {
  final offset = (page - 1) * limit;
  final data = await _db.query(
    'SELECT * FROM table ORDER BY created_at DESC LIMIT $1 OFFSET $2',
    [limit, offset],
  );
  final totalCount = await _db.query('SELECT COUNT(*) FROM table');
  
  return PaginationResult(
    data: data,
    totalCount: totalCount.first['count'] as int,
    page: page,
    limit: limit,
  );
}
```

**Frontend:**
```dart
final bookingsProvider = FutureProvider.autoDispose.family<PaginationResult<Booking>, PaginationParams>(
  (ref, params) async {
    final apiService = ref.watch(apiServiceProvider);
    return await apiService.getBookings(
      page: params.page,
      limit: params.limit,
    );
  },
);
```

**المراجع:**
- `backend/lib/core/utils/pagination_result.dart`
- `PLAYBOOKS.md` - Playbook 12: Fixing Pagination Bug

---

### 5. Authentication Flow

**الوصف:** كيفية عمل JWT authentication في المشروع

**الخطوات:**
1. User sends credentials to `/api/auth/login`
2. Backend validates credentials
3. Backend generates JWT tokens (access + refresh)
4. Frontend stores tokens in SharedPreferences
5. Frontend sends access token in `Authorization: Bearer {token}` header
6. Backend validates token via AuthMiddleware
7. If token expired, Frontend uses refresh token

**Token Expiry:**
- Access Token: 15 minutes
- Refresh Token: 7 days

**المراجع:**
- `backend/lib/core/utils/jwt_service.dart`
- `backend/lib/presentation/middlewares/auth_middleware.dart`
- `backend/lib/application/services/auth_service.dart`

---

### 6. Authorization Flow

**الوصف:** كيفية عمل role-based access control

**Role Hierarchy:**
```
OWNER (Level 5) > MANAGER (Level 4) > ACCOUNTANT (Level 3) > RECEPTIONIST (Level 2) > MECHANIC (Level 1)
```

**Implementation:**
```dart
// In AuthMiddleware
Middleware requireRole(Role requiredRole) {
  return (Handler innerHandler) {
    return (Request request) {
      final user = request.context['user'] as User;
      if (user.role.level < requiredRole.level) {
        return Response.forbidden('Insufficient permissions');
      }
      return innerHandler(request);
    };
  };
}
```

**المراجع:**
- `backend/lib/presentation/middlewares/auth_middleware.dart`
- `backend/lib/domain/entities/role.dart`

---

### 7. Journal Entry Creation

**الوصف:** كيفية إنشاء journal entry في نظام المحاسبة

**الخطوات:**
1. Validate debit == credit
2. Validate all accounts exist
3. Validate fiscal period is open
4. Create journal_entries record
5. Create journal_lines records
6. Update account balances
7. Generate audit trail

**Validation:**
```dart
if (totalDebit != totalCredit) {
  throw ValidationFailure('Debit must equal credit');
}
```

**Automatic Journal Entries:**
- **Booking Payment:**
  - Debit: Cash/Bank Account
  - Credit: Service Revenue
- **Part Consumption:**
  - Debit: Cost of Goods Sold
  - Credit: Inventory
- **Salary Payment:**
  - Debit: Salary Expense
  - Credit: Cash/Bank Account

**المراجع:**
- `backend/lib/application/services/journal_service.dart`
- `backend/lib/domain/entities/journal_entry.dart`
- `.cursorrules` - Accounting Guidelines section

---

### 8. Payment Processing

**الوصف:** كيفية معالجة الدفع في المشروع

**الخطوات:**
1. User confirms payment (amount, method)
2. Frontend sends POST to `/api/bookings/:id/payment`
3. Backend validates payment
4. Backend updates booking_invoice_data
5. Backend creates journal entries
6. Backend updates booking status to DELIVERED
7. Backend returns updated invoice

**Database Updates:**
```sql
UPDATE booking_invoice_data
SET payment_status = 'PAID',
    paid_amount = paid_amount + ?,
    payment_date = NOW()
WHERE booking_id = ?;
```

**المراجع:**
- `backend/lib/application/usecases/process_booking_payment_usecase.dart`
- `backend/lib/presentation/routes/booking_routes.dart`

---

## 🆕 Proposed New Knowledge Entries

### 9. How to Add a New Feature (End-to-End)

**الوصف:** دليل شامل لإضافة ميزة جديدة من البداية للنهاية

**الخطوات:**
1. **Domain Layer:** Create Entity and Repository Interface
2. **Application Layer:** Create Use Case and Service
3. **Infrastructure Layer:** Create Repository Implementation and Migration
4. **Presentation Layer:** Create Route Handler
5. **Frontend Models:** Create Model and Provider
6. **Frontend UI:** Create Screen and Widgets
7. **Testing:** Write Unit, Integration, and Widget Tests
8. **Documentation:** Update relevant documentation

**المراجع:**
- `TASK_BREAKDOWN_PLAN.md` - Task Category 1: New Feature
- `PLAYBOOKS.md` - Playbooks 1-7

**الحالة:** ✅ Approved - Add to Knowledge Base

---

### 10. How to Refactor Existing Code

**الوصف:** دليل شامل لإعادة هيكلة الكود الموجود

**الخطوات:**
1. **Analysis:** Analyze current code and identify problems
2. **Planning:** Design new structure and create plan
3. **Domain Layer Refactoring:** Refactor Entities and Repository Interfaces
4. **Application Layer Refactoring:** Refactor Use Cases and Services
5. **Infrastructure Layer Refactoring:** Refactor Repository Implementations
6. **Presentation Layer Refactoring:** Refactor Routes and Middlewares
7. **Frontend Refactoring:** Refactor Models, Providers, and Screens
8. **Testing:** Update tests and run regression testing
9. **Documentation:** Update documentation

**المراجع:**
- `TASK_BREAKDOWN_PLAN.md` - Task Category 2: Refactoring

**الحالة:** ✅ Approved - Add to Knowledge Base

---

### 11. How to Write Comprehensive Tests

**الوصف:** دليل شامل لكتابة اختبارات شاملة

**الخطوات:**
1. **Backend Unit Tests:** Test Entities, Use Cases, Services
2. **Backend Integration Tests:** Test Repositories, Routes
3. **Frontend Unit Tests:** Test Models, Providers
4. **Frontend Widget Tests:** Test Screens, Widgets
5. **E2E Tests:** Test user flows end-to-end

**Coverage Targets:**
- Backend: > 80%
- Frontend: > 70%

**المراجع:**
- `TASK_BREAKDOWN_PLAN.md` - Task Category 3: Testing
- `PLAYBOOKS.md` - Playbooks 10-11

**الحالة:** ✅ Approved - Add to Knowledge Base

---

### 12. How to Optimize Database Queries

**الوصف:** دليل شامل لتحسين استعلامات قاعدة البيانات

**الاستراتيجيات:**
1. **Use Indexes:** Create indexes on frequently queried columns
2. **Avoid N+1 Queries:** Use joins instead of multiple queries
3. **Use Pagination:** Always use LIMIT and OFFSET for large datasets
4. **Use Connection Pooling:** Reuse database connections
5. **Use Prepared Statements:** Prevent SQL injection and improve performance

**مثال:**
```sql
-- Bad: N+1 queries
SELECT * FROM bookings;
-- Then for each booking:
SELECT * FROM customers WHERE id = ?;

-- Good: Single query with join
SELECT b.*, c.* 
FROM bookings b
JOIN customers c ON b.customer_id = c.id;
```

**المراجع:**
- `backend/lib/infrastructure/database/database_connection.dart`
- `supabase-schema.sql` - Indexes section

**الحالة:** ✅ Approved - Add to Knowledge Base

---

### 13. How to Implement Caching

**الوصف:** دليل شامل لتنفيذ caching في المشروع

**الاستراتيجيات:**
1. **Frontend Caching:** Use SharedPreferences for frequently accessed data
2. **Backend Caching:** Use in-memory cache for expensive operations
3. **API Caching:** Cache API responses with TTL
4. **Database Caching:** Use database query caching

**مثال (Frontend):**
```dart
// Cache company settings
final cachedSettings = await sharedPreferences.getString('company_settings');
if (cachedSettings != null) {
  return CompanySettings.fromJson(jsonDecode(cachedSettings));
}
final settings = await apiService.getCompanySettings();
await sharedPreferences.setString('company_settings', jsonEncode(settings.toJson()));
return settings;
```

**المراجع:**
- `admin_frontend/lib/core/services/api_service.dart`
- `mechanic_app_new/lib/data/datasources/local/cache_datasource.dart`

**الحالة:** ✅ Approved - Add to Knowledge Base

---

### 14. How to Add Real-time Notifications

**الوصف:** دليل شامل لإضافة إشعارات real-time

**الاستراتيجيات:**
1. **WebSocket:** Use WebSocket for real-time updates
2. **Server-Sent Events:** Use SSE for one-way updates
3. **Push Notifications:** Use push notifications for mobile apps

**مثال (WebSocket):**
```dart
// Backend
final webSocketHandler = webSocketHandler((webSocket) {
  webSocket.stream.listen((message) {
    // Handle message
  });
});

// Frontend
final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8080/ws'));
channel.stream.listen((message) {
  // Handle update
});
```

**المراجع:**
- `backend/lib/presentation/websocket/`
- `admin_frontend/lib/core/services/websocket_service.dart`

**الحالة:** ✅ Approved - Add to Knowledge Base

---

### 15. How to Implement File Uploads

**الوصف:** دليل شامل لتنفيذ رفع الملفات

**الاستراتيجيات:**
1. **Multipart Form Data:** Use multipart/form-data for file uploads
2. **Cloud Storage:** Use cloud storage (S3, Cloudinary) for file storage
3. **Validation:** Validate file type, size, and content

**مثال (Backend):**
```dart
// Backend Route
router.post('/api/upload', (Request request) async {
  final multipart = request.asMultipartFormData();
  final file = await multipart.files.first;
  final bytes = await file.readAsBytes();
  // Save to cloud storage
  // Return file URL
});
```

**مثال (Frontend):**
```dart
// Frontend
final result = await FilePicker.platform.pickFiles();
if (result != null) {
  final file = File(result.files.single.path!);
  final request = http.MultipartRequest('POST', Uri.parse('/api/upload'));
  request.files.add(await http.MultipartFile.fromPath('file', file.path));
  final response = await request.send();
}
```

**المراجع:**
- `backend/pubspec.yaml` - shelf_multipart
- `admin_frontend/pubspec.yaml` - file_picker

**الحالة:** ✅ Approved - Add to Knowledge Base

---

### 16. How to Add Export Functionality

**الوصف:** دليل شامل لإضافة وظيفة التصدير

**الاستراتيجيات:**
1. **PDF Export:** Use PDF library for PDF generation
2. **Excel Export:** Use Excel library for Excel generation
3. **CSV Export:** Use CSV format for simple exports

**مثال (PDF):**
```dart
// Backend
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

final pdf = Document();
pdf.addPage(Page(
  build: (Context context) {
    return Text('Hello World');
  },
));
final bytes = await pdf.save();
```

**مثال (Excel):**
```dart
// Backend
import 'package:excel/excel.dart';

final excel = Excel.createExcel();
final sheet = excel['Sheet1'];
sheet.cell(CellIndex.indexByColumnRow(column: 0, row: 0)).value = 'Hello';
final bytes = excel.encode();
```

**المراجع:**
- `backend/pubspec.yaml` - pdf, excel
- `admin_frontend/pubspec.yaml` - printing

**الحالة:** ✅ Approved - Add to Knowledge Base

---

## 🗑️ Outdated Knowledge Entries

### None Identified

في الوقت الحالي، لا توجد إدخالات معرفة قديمة تحتاج إلى إزالة. جميع الإدخالات الحالية لا تزال صالحة وذات صلة.

---

## 📊 Knowledge Base Statistics

| Category | Count |
|----------|-------|
| Existing Entries | 8 |
| Proposed New Entries | 8 |
| Outdated Entries | 0 |
| Total Entries | 16 |

---

## 🔄 Knowledge Base Maintenance

### Update Frequency

- **Weekly:** Review and update after each major task
- **Monthly:** Comprehensive review of all entries
- **Quarterly:** Remove outdated entries, add new patterns

### Update Process

1. **After Each Task:**
   - Identify new patterns discovered
   - Document new best practices
   - Update existing entries if needed

2. **Before Each Task:**
   - Review relevant knowledge entries
   - Ensure patterns are still valid
   - Identify potential improvements

3. **Knowledge Base Review:**
   - Remove outdated entries
   - Merge duplicate entries
   - Improve clarity of existing entries
   - Add missing entries

---

## 🎯 Knowledge Base Usage

### How to Use

1. **Before Starting a Task:**
   - Review relevant knowledge entries
   - Understand patterns and conventions
   - Identify potential pitfalls

2. **During a Task:**
   - Reference knowledge entries for guidance
   - Follow established patterns
   - Document new patterns discovered

3. **After Completing a Task:**
   - Update knowledge base with new patterns
   - Improve existing entries
   - Remove outdated entries

### Search Strategy

```
For Backend Development:
- Search: "Clean Architecture", "Field Name Mapping", "Pagination"

For Frontend Development:
- Search: "Null Safety", "Authentication", "Authorization"

For Database Operations:
- Search: "Pagination", "Database Queries", "Optimization"

For Testing:
- Search: "Unit Tests", "Integration Tests", "Widget Tests"
```

---

## 📝 Knowledge Base Quality Metrics

### Quality Criteria

- **Accuracy:** Information must be accurate and up-to-date
- **Clarity:** Information must be clear and easy to understand
- **Completeness:** Information must be complete and comprehensive
- **Relevance:** Information must be relevant to the project
- **Actionability:** Information must be actionable

### Quality Score

- **Current Score:** 9/10
- **Target Score:** 10/10
- **Improvement Areas:** Add more examples, improve clarity

---

## 🔗 Related Files

- `.cursorrules` - Project rules & guidelines
- `AGENTS.md` - AI memory documentation
- `PROJECT_ANALYSIS.md` - Project analysis report
- `TASK_BREAKDOWN_PLAN.md` - Task breakdown plan
- `PLAYBOOKS.md` - Reusable playbooks

---

**Knowledge Base Created:** May 24, 2026  
**Status:** Active  
**Next Update:** After first task execution
