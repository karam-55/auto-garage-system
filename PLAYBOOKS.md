# Garage Go - Playbooks (قوائم التشغيل)

**Generated:** May 24, 2026  
**Project:** Auto Garage Management System (Garage Go)  
**Purpose:** Reusable step-by-step guides for common development tasks  
**Status:** Ready for Use

---

## 📋 Overview

هذا الملف يحتوي على قوائم تشغيل (Playbooks) قابلة لإعادة الاستخدام للمهام المتكررة في مشروع Garage Go. كل playbook يوفر خطوات مفصلة، معايير نجاح، ومشاكل شائعة لتجنبها.

---

## 🎯 Playbook Categories

1. **Backend Development** - تطوير Backend
2. **Frontend Development** - تطوير Frontend
3. **Database Operations** - عمليات قاعدة البيانات
4. **Testing** - الاختبار
5. **Refactoring** - إعادة الهيكلة
6. **Bug Fixing** - إصلاح الأخطاء
7. **Deployment** - النشر

---

## 🔧 Backend Development Playbooks

### Playbook 1: إضافة Entity جديد

**الاستخدام:** عندما تحتاج إلى إضافة كيان (Entity) جديد في Domain Layer

#### الخطوات

1. **إنشاء ملف Entity**
   ```bash
   # المسار: backend/lib/domain/entities/
   touch new_entity.dart
   ```

2. **تعريف Entity**
   ```dart
   class NewEntity {
     final String id;
     final String name;
     final DateTime createdAt;
     
     NewEntity({
       required this.id,
       required this.name,
       required this.createdAt,
     });
     
     // fromJson method
     factory NewEntity.fromJson(Map<String, dynamic> json) {
       return NewEntity(
         id: json['id'] as String,
         name: json['name'] as String,
         createdAt: DateTime.parse(json['created_at'] as String),
       );
     }
     
     // toJson method
     Map<String, dynamic> toJson() {
       return {
         'id': id,
         'name': name,
         'created_at': createdAt.toIso8601String(),
       };
     }
   }
   ```

3. **إضافة Validation Logic**
   ```dart
   // في backend/lib/domain/validators/ أو في Entity نفسه
   String? validate() {
     if (name.isEmpty) return 'Name is required';
     return null;
   }
   ```

4. **كتابة Unit Tests**
   ```dart
   // في backend/test/domain/entities/
   test('NewEntity should create from json', () {
     final json = {'id': '123', 'name': 'Test', 'created_at': '2026-05-24'};
     final entity = NewEntity.fromJson(json);
     expect(entity.name, 'Test');
   });
   ```

#### معايير النجاح

- ✅ Entity يُنشأ في المسار الصحيح
- ✅ جميع الحقول مُعرفة بشكل صحيح
- ✅ fromJson/toJson methods تعمل بشكل صحيح
- ✅ Null safety مُطبق
- ✅ Unit tests تمر

#### المشاكل الشائعة

- ❌ **Missing null safety:** استخدم `String?` للحقول الاختيارية
- ❌ **Incorrect field naming:** استخدم camelCase في Entity، snake_case في JSON
- ❌ **Missing validation:** أضيف validation logic للحقول المطلوبة
- ❌ **No tests:** اكتب unit tests لكل Entity

#### الوقت المقدر

30-45 دقيقة

---

### Playbook 2: إضافة Repository جديد

**الاستخدام:** عندما تحتاج إلى إضافة Repository جديد للوصول إلى البيانات

#### الخطوات

1. **إنشاء Repository Interface**
   ```bash
   # المسار: backend/lib/domain/repositories/
   touch new_entity_repository.dart
   ```

2. **تعريف Repository Interface**
   ```dart
   abstract class NewEntityRepository {
     Future<NewEntity> create(NewEntity entity);
     Future<NewEntity?> findById(String id);
     Future<List<NewEntity>> findAll();
     Future<NewEntity> update(NewEntity entity);
     Future<void> delete(String id);
   }
   ```

3. **إنشاء Repository Implementation**
   ```bash
   # المسار: backend/lib/infrastructure/repositories/
   touch new_entity_repository_impl.dart
   ```

4. **تنفيذ Repository Implementation**
   ```dart
   class NewEntityRepositoryImpl implements NewEntityRepository {
     final DatabaseConnection _db;
     
     NewEntityRepositoryImpl(this._db);
     
     @override
     Future<NewEntity> create(NewEntity entity) async {
       final result = await _db.query(
         'INSERT INTO new_entities (id, name, created_at) VALUES ($1, $2, $3) RETURNING *',
         [entity.id, entity.name, entity.createdAt],
       );
       return NewEntity.fromJson(result.first);
     }
     
     @override
     Future<NewEntity?> findById(String id) async {
       final result = await _db.query(
         'SELECT * FROM new_entities WHERE id = $1',
         [id],
       );
       if (result.isEmpty) return null;
       return NewEntity.fromJson(result.first);
     }
     
     // ... implement other methods
   }
   ```

5. **كتابة Integration Tests**
   ```dart
   // في backend/test/infrastructure/repositories/
   test('NewEntityRepository should create entity', () async {
     final repository = NewEntityRepositoryImpl(testDb);
     final entity = await repository.create(testEntity);
     expect(entity.id, isNotNull);
   });
   ```

#### معايير النجاح

- ✅ Repository Interface مُعرف بشكل صحيح
- ✅ Repository Implementation يحقق Interface
- ✅ Database queries محسنة (استخدم indexes)
- ✅ Error Handling مُطبق
- ✅ Integration tests تمر

#### المشاكل الشائعة

- ❌ **Incomplete implementation:** تأكد من تنفيذ جميع methods
- ❌ **Inefficient queries:** استخدم proper indexes و joins
- ❌ **Missing error handling:** أضف try-catch blocks
- ❌ **No tests:** اكتب integration tests

#### الوقت المقدر

60-90 دقيقة

---

### Playbook 3: إضافة Use Case جديد

**الاستخدام:** عندما تحتاج إلى إضافة Use Case جديد في Application Layer

#### الخطوات

1. **إنشاء Use Case**
   ```bash
   # المسار: backend/lib/application/usecases/
   touch create_new_entity_usecase.dart
   ```

2. **تعريف Use Case**
   ```dart
   class CreateNewEntityUseCase {
     final NewEntityRepository _repository;
     
     CreateNewEntityUseCase(this._repository);
     
     Future<NewEntity> call(CreateNewEntityParams params) async {
       // Validation
       if (params.name.isEmpty) {
         throw ValidationFailure('Name is required');
       }
       
       // Business logic
       final entity = NewEntity(
         id: const Uuid().v4(),
         name: params.name,
         createdAt: DateTime.now(),
       );
       
       // Execution
       return await _repository.create(entity);
     }
   }
   
   class CreateNewEntityParams {
     final String name;
     CreateNewEntityParams({required this.name});
   }
   ```

3. **كتابة Unit Tests**
   ```dart
   // في backend/test/application/usecases/
   test('CreateNewEntityUseCase should create entity', () async {
     final useCase = CreateNewEntityUseCase(mockRepository);
     final result = await useCase(CreateNewEntityParams(name: 'Test'));
     expect(result.name, 'Test');
   });
   ```

#### معايير النجاح

- ✅ Use Case يفصل منطق العمل بشكل صحيح
- ✅ Validation مُطبق
- ✅ Error Handling مُطبق
- ✅ Unit tests تمر

#### المشاكل الشائعة

- ❌ **Business logic in repository:** ضع business logic في Use Case
- ❌ **Missing validation:** أضف validation للمدخلات
- ❌ **No error handling:** أضف proper error handling
- ❌ **No tests:** اكتب unit tests

#### الوقت المقدر

30-45 دقيقة

---

### Playbook 4: إضافة Route Handler جديد

**الاستخدام:** عندما تحتاج إلى إضافة API endpoint جديد

#### الخطوات

1. **إنشاء Route File**
   ```bash
   # المسار: backend/lib/presentation/routes/
   touch new_entity_routes.dart
   ```

2. **تعريف Routes**
   ```dart
   import 'package:shelf/shelf.dart';
   import 'package:shelf_router/shelf_router.dart';
   
   class NewEntityRoutes {
     final NewEntityRepository _repository;
     final AuthMiddleware _authMiddleware;
     
     NewEntityRoutes(this._repository, this._authMiddleware);
     
     Router get router {
       final router = Router();
     
     // GET /api/new-entities
     router.get('/api/new-entities', 
       _authMiddleware.authenticate()(
         _authMiddleware.requireRole(Role.RECEPTIONIST)(_getAllNewEntities)
       )
     );
     
     // POST /api/new-entities
     router.post('/api/new-entities',
       _authMiddleware.authenticate()(
         _authMiddleware.requireRole(Role.RECEPTIONIST)(_createNewEntity)
       )
     );
     
     return router;
   }
     
     Future<Response> _getAllNewEntities(Request request) async {
       try {
         final entities = await _repository.findAll();
         return Response.ok(jsonEncode(entities));
       } catch (e) {
         throw ServerFailure('Failed to fetch entities');
       }
     }
     
     Future<Response> _createNewEntity(Request request) async {
       try {
         final body = await JsonMiddleware.parseJsonBody(request);
         final entity = NewEntity.fromJson(body);
         final created = await _repository.create(entity);
         return Response.ok(jsonEncode(created));
       } catch (e) {
         throw ValidationFailure('Invalid request body');
       }
     }
   }
   ```

3. **تسجيل Routes في server.dart**
   ```dart
   // في backend/bin/server.dart
   final newEntityRoutes = NewEntityRoutes(newEntityRepository, authMiddleware);
   
   final handler = Cascade()
     .add(newEntityRoutes.router)
     .add(otherRoutes.router)
     .handler;
   ```

4. **كتابة API Tests**
   ```dart
   // في backend/test/presentation/routes/
   test('GET /api/new-entities should return entities', () async {
     final response = await request.get('/api/new-entities');
     expect(response.statusCode, 200);
   });
   ```

#### معايير النجاح

- ✅ Route handler يعمل بشكل صحيح
- ✅ Authentication/Authorization مُطبق
- ✅ Error responses متسقة
- ✅ API tests تمر

#### المشاكل الشائعة

- ❌ **Missing authentication:** أضف auth middleware
- ❌ **Incorrect HTTP methods:** استخدم methods الصحيحة
- ❌ **No error handling:** أضف proper error handling
- ❌ **No tests:** اكتب API tests

#### الوقت المقدر

45-60 دقيقة

---

## 🎨 Frontend Development Playbooks

### Playbook 5: إضافة Model جديد (Admin Frontend)

**الاستخدام:** عندما تحتاج إلى إضافة Model جديد في Admin Frontend

#### الخطوات

1. **إنشاء Model**
   ```bash
   # المسار: admin_frontend/lib/core/models/
   touch new_entity.dart
   ```

2. **تعريف Model**
   ```dart
   class NewEntity {
     final String id;
     final String name;
     final DateTime createdAt;
     
     NewEntity({
       required this.id,
     required this.name,
     required this.createdAt,
   });
     
     factory NewEntity.fromJson(Map<String, dynamic> json) {
       return NewEntity(
         id: json['id'] as String,
         name: json['name'] as String,
         createdAt: DateTime.parse(json['created_at'] as String),
       );
     }
     
     Map<String, dynamic> toJson() {
       return {
         'id': id,
         'name': name,
         'created_at': createdAt.toIso8601String(),
       };
     }
   }
   ```

3. **كتابة Unit Tests**
   ```dart
   // في admin_frontend/test/core/models/
   test('NewEntity should parse from json', () {
     final json = {'id': '123', 'name': 'Test', 'created_at': '2026-05-24'};
     final entity = NewEntity.fromJson(json);
     expect(entity.name, 'Test');
   });
   ```

#### معايير النجاح

- ✅ Model يطابق API response
- ✅ fromJson/toJson methods تعمل بشكل صحيح
- ✅ Null safety مُطبق
- ✅ Unit tests تمر

#### المشاكل الشائعة

- ❌ **Field name mismatch:** تأكد من field names تطابق API
- ❌ **Missing null safety:** استخدم `String?` للحقول الاختيارية
- ❌ **No tests:** اكتب unit tests

#### الوقت المقدر

30-45 دقيقة

---

### Playbook 6: إضافة Provider جديد (Admin Frontend)

**الاستخدام:** عندما تحتاج إلى إضافة Provider جديد لإدارة الحالة

#### الخطوات

1. **إنشاء Provider**
   ```bash
   # المسار: admin_frontend/lib/core/providers/
   touch new_entity_provider.dart
   ```

2. **تعريف Provider**
   ```dart
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   
   final newEntityProvider = FutureProvider.autoDispose<List<NewEntity>>((ref) async {
     final apiService = ref.watch(apiServiceProvider);
     return await apiService.getNewEntities();
   });
   
   final newEntityDetailProvider = FutureProvider.autoDispose.family<NewEntity, String>(
   (ref, id) async {
     final apiService = ref.watch(apiServiceProvider);
     return await apiService.getNewEntityById(id);
   },
   );
   ```

3. **كتابة Provider Tests**
   ```dart
   // في admin_frontend/test/core/providers/
   test('newEntityProvider should fetch entities', () async {
     final container = ProviderContainer(
       overrides: [
         apiServiceProvider.overrideWithValue(mockApiService),
       ],
     );
     final result = await container.read(newEntityProvider.future);
     expect(result, isNotEmpty);
   });
   ```

#### معايير النجاح

- ✅ Provider يدير الحالة بشكل صحيح
- ✅ Error Handling مُطبق
- ✅ AutoDispose مُطبق (للـ FutureProviders)
- ✅ Provider tests تمر

#### المشاكل الشائعة

- ❌ **No error handling:** أضف proper error handling
- ❌ **Not using autoDispose:** استخدم autoDispose للـ FutureProviders
- ❌ **No tests:** اكتب provider tests

#### الوقت المقدر

30-45 دقيقة

---

### Playbook 7: إضافة Screen جديد (Admin Frontend)

**الاستخدام:** عندما تحتاج إلى إضافة Screen جديد في Admin Frontend

#### الخطوات

1. **إنشاء Screen**
   ```bash
   # المسار: admin_frontend/lib/screens/
   mkdir new_module
   touch new_module/new_entities_screen.dart
   ```

2. **تعريف Screen**
   ```dart
   class NewEntitiesScreen extends ConsumerWidget {
     const NewEntitiesScreen({super.key});
     
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final entitiesAsync = ref.watch(newEntityProvider);
     
       return Scaffold(
         appBar: AppBar(
           title: Text(AppLocalizations.of(context)!.newEntities),
         ),
         body: entitiesAsync.when(
           data: (entities) {
             return ListView.builder(
               itemCount: entities.length,
               itemBuilder: (context, index) {
                 return ListTile(
                   title: Text(entities[index].name),
                   subtitle: Text(entities[index].createdAt.toString()),
                 );
               },
             );
           },
           loading: () => const Center(child: CircularProgressIndicator()),
           error: (error, stack) => Center(
             child: Text('Error: $error'),
           ),
         ),
       );
     }
   }
   ```

3. **إضافة Navigation**
   ```dart
   // في الـ sidebar أو menu
   ListTile(
     title: Text(AppLocalizations.of(context)!.newEntities),
     onTap: () {
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => const NewEntitiesScreen()),
       );
     },
   )
   ```

4. **كتابة Widget Tests**
   ```dart
   // في admin_frontend/test/screens/
   testWidgets('NewEntitiesScreen displays entities', (tester) async {
     await tester.pumpWidget(
       ProviderScope(
         overrides: [
           newEntityProvider.overrideWithValue(AsyncValue.data(testEntities)),
         ],
         child: MaterialApp(home: NewEntitiesScreen()),
       ),
     );
     expect(find.text('Test Entity'), findsOneWidget);
   });
   ```

#### معايير النجاح

- ✅ Screen يعرض بشكل صحيح
- ✅ Loading states مُطبقة
- ✅ Error handling مُطبق
- ✅ Arabic localization مُطبق
- ✅ Widget tests تمر

#### المشاكل الشائعة

- ❌ **No loading state:** أضف loading indicator
- ❌ **No error handling:** أضف error display
- ❌ **No localization:** استخدم AppLocalizations
- ❌ **No tests:** اكتب widget tests

#### الوقت المقدر

60-120 دقيقة

---

## 🗄️ Database Operations Playbooks

### Playbook 8: إضافة Table جديد

**الاستخدام:** عندما تحتاج إلى إضافة table جديد في قاعدة البيانات

#### الخطوات

1. **إنشاء Migration SQL**
   ```sql
   -- في backend/lib/infrastructure/database/migrations/
   CREATE TABLE IF NOT EXISTS new_entities (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     name VARCHAR(255) NOT NULL,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP WITH TIME ZONE
   );
   
   -- Indexes
   CREATE INDEX IF NOT EXISTS idx_new_entities_name ON new_entities(name);
   CREATE INDEX IF NOT EXISTS idx_new_entities_created_at ON new_entities(created_at);
   ```

2. **تنفيذ Migration**
   ```dart
   // في backend/lib/infrastructure/database/database_connection.dart
   Future<void> executeMigration() async {
     await execute('migrations/create_new_entities.sql');
   }
   ```

3. **كتابة Database Tests**
   ```dart
   // في backend/test/infrastructure/database/
   test('Migration should create table', () async {
     await db.executeMigration();
     final tables = await db.query('SELECT table_name FROM information_schema.tables WHERE table_name = \'new_entities\'');
     expect(tables, isNotEmpty);
   });
   ```

#### معايير النجاح

- ✅ Table يُنشأ بشكل صحيح
- ✅ Indexes مُضافة
- ✅ Constraints مُضافة
- ✅ Database tests تمر

#### المشاكل الشائعة

- ❌ **Missing indexes:** أضف indexes للأعمدة المُستخدمة بشكل متكرر
- ❌ **No constraints:** أضف constraints (NOT NULL, UNIQUE, CHECK)
- ❌ **No tests:** اكتب database tests

#### الوقت المقدر

30-45 دقيقة

---

### Playbook 9: إضافة Column جديد

**الاستخدام:** عندما تحتاج إلى إضافة column جديد لـ table موجود

#### الخطوات

1. **إنشاء Migration SQL**
   ```sql
   -- في backend/lib/infrastructure/database/migrations/
   ALTER TABLE new_entities ADD COLUMN IF NOT EXISTS description TEXT;
   ALTER TABLE new_entities ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
   ```

2. **تنفيذ Migration**
   ```dart
   // في backend/lib/infrastructure/database/database_connection.dart
   Future<void> executeMigration() async {
     await execute('migrations/add_columns_new_entities.sql');
   }
   ```

3. **تحديث Entity**
   ```dart
   // في backend/lib/domain/entities/new_entity.dart
   class NewEntity {
     final String id;
     final String name;
     final String? description;  // New field
     final bool isActive;  // New field
     final DateTime createdAt;
     
     NewEntity({
       required this.id,
       required this.name,
       this.description,
     this.isActive = true,
       required this.createdAt,
     });
     
     // Update fromJson/toJson
   }
   ```

#### معايير النجاح

- ✅ Column يُضاف بشكل صحيح
- ✅ Entity مُحدث
- ✅ Default values مُضافة
- ✅ Database tests تمر

#### المشاكل الشائعة

- ❌ **No default value:** أضف default value للحقول الجديدة
- ❌ **Not nullable:** استخدم nullable إذا الـ table يحتوي بيانات
- ❌ **Entity not updated:** حدّث Entity ليشمل الحقل الجديد

#### الوقت المقدر

20-30 دقيقة

---

## 🧪 Testing Playbooks

### Playbook 10: كتابة Unit Test (Backend)

**الاستخدام:** عندما تحتاج إلى كتابة unit test لـ backend code

#### الخطوات

1. **إنشاء Test File**
   ```bash
   # المسار: backend/test/domain/entities/ أو backend/test/application/usecases/
   touch new_entity_test.dart
   ```

2. **كتابة Test**
   ```dart
   import 'package:flutter_test/flutter_test.dart';
   
   void main() {
     group('NewEntity', () {
       test('should create from json', () {
         final json = {
           'id': '123',
           'name': 'Test',
           'created_at': '2026-05-24T10:00:00Z',
         };
         final entity = NewEntity.fromJson(json);
         expect(entity.id, '123');
         expect(entity.name, 'Test');
       });
       
       test('should validate name', () {
         final entity = NewEntity(
           id: '123',
           name: '',
           createdAt: DateTime.now(),
         );
         final error = entity.validate();
         expect(error, isNotNull);
       });
     });
   }
   ```

3. **تشغيل Test**
   ```bash
   cd backend
   dart test test/domain/entities/new_entity_test.dart
   ```

#### معايير النجاح

- ✅ Test يمر
- ✅ Test يغطي الحالات المختلفة
- ✅ Test يستخدم proper assertions

#### المشاكل الشائعة

- ❌ **No assertions:** تأكد من وجود assertions
- ❌ **Not testing edge cases:** أضف tests للـ edge cases
- ❌ **Hardcoded values:** استخدم test data fixtures

#### الوقت المقدر

15-30 دقيقة

---

### Playbook 11: كتابة Widget Test (Frontend)

**الاستخدام:** عندما تحتاج إلى كتابة widget test لـ frontend code

#### الخطوات

1. **إنشاء Test File**
   ```bash
   # المسار: admin_frontend/test/screens/
   touch new_entities_screen_test.dart
   ```

2. **كتابة Test**
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   
   void main() {
     testWidgets('NewEntitiesScreen displays entities', (tester) async {
       await tester.pumpWidget(
         ProviderScope(
           overrides: [
             newEntityProvider.overrideWithValue(
               AsyncValue.data([testEntity]),
             ),
           ],
           child: MaterialApp(home: NewEntitiesScreen()),
         ),
       );
     
       expect(find.text('Test Entity'), findsOneWidget);
     });
   }
   ```

3. **تشغيل Test**
   ```bash
   cd admin_frontend
   flutter test test/screens/new_entities_screen_test.dart
   ```

#### معايير النجاح

- ✅ Test يمر
- ✅ Test يغطي UI interactions
- ✅ Test يستخدم proper providers

#### المشاكل الشائعة

- ❌ **No provider override:** استخدم provider override للـ mock data
- ❌ **Not pumping widget:** استخدم pump/pumpAndSettle
- ❌ **No assertions:** تأكد من وجود assertions

#### الوقت المقدر

30-45 دقيقة

---

## 🐛 Bug Fixing Playbooks

### Playbook 12: إصلاح خطأ في Pagination

**الاستخدام:** عندما تواجه مشكلة في pagination

#### الخطوات

1. **تشخيص المشكلة**
   ```dart
   // تحقق من:
   // - هل page و limit parameters تُرسل؟
   // - هل Backend يستقبلها بشكل صحيح؟
   // - هل Database query يستخدم OFFSET/LIMIT؟
   ```

2. **إصلاح Backend**
   ```dart
   // في backend/lib/infrastructure/repositories/
   Future<PaginationResult<Booking>> findAllPaginated({
     int page = 1,
     int limit = 20,
   }) async {
     final offset = (page - 1) * limit;
     final result = await _db.query(
       'SELECT * FROM bookings ORDER BY created_at DESC LIMIT $1 OFFSET $2',
       [limit, offset],
     );
     // ...
   }
   ```

3. **إصلاح Frontend**
   ```dart
   // في admin_frontend/lib/core/providers/
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

4. **Verification**
   ```bash
   # تشغيل tests
   cd backend && dart test
   cd admin_frontend && flutter test
   
   # Manual testing
   # اختبر pagination في UI
   ```

#### معايير النجاح

- ✅ Pagination يعمل بشكل صحيح
- ✅ page و limit parameters تُرسل
- ✅ Database query يستخدم OFFSET/LIMIT
- ✅ UI يعرض الصفحات بشكل صحيح

#### المشاكل الشائعة

- ❌ **Not sending parameters:** تأكد من إرسال page و limit
- ❌ **Incorrect offset calculation:** offset = (page - 1) * limit
- ❌ **No limit in query:** أضف LIMIT و OFFSET في query

#### الوقت المقدر

30-60 دقيقة

---

### Playbook 13: إصلاح خطأ في Field Name Mapping

**الاستخدام:** عندما تواجه مشكلة في field name mapping بين Backend و Frontend

#### الخطوات

1. **تشخيص المشكلة**
   ```dart
   // تحقق من:
   // - Backend API response field names
   // - Frontend Model field names
   // - fromJson/toJson methods
   ```

2. **إصلاح Backend**
   ```dart
   // تأكد من استخدام snake_case في JSON
   Map<String, dynamic> toJson() {
     return {
       'entry_date': entryDate.toIso8601String(),  // snake_case
       'account_type': accountType,  // snake_case
     };
   }
   ```

3. **إصلاح Frontend**
   ```dart
   // تأكد من معالجة snake_case في fromJson
   factory NewEntity.fromJson(Map<String, dynamic> json) {
     return NewEntity(
       entryDate: DateTime.parse(json['entry_date'] as String),  // snake_case
       accountType: json['account_type'] as String,  // snake_case
     );
   }
   ```

4. **Verification**
   ```bash
   # تشغيل tests
   cd backend && dart test
   cd admin_frontend && flutter test
   ```

#### معايير النجاح

- ✅ Field names تطابق بين Backend و Frontend
- ✅ fromJson/toJson methods تعمل بشكل صحيح
- ✅ Tests تمر

#### المشاكل الشائعة

- ❌ **Inconsistent naming:** استخدم snake_case في JSON، camelCase في code
- ❌ **Missing fields:** تأكد من جميع الحقول موجودة
- ❌ **Type mismatch:** تأكد من types تطابق

#### الوقت المقدر

20-30 دقيقة

---

## 🚀 Deployment Playbooks

### Playbook 14: نشر Backend إلى Render

**الاستخدام:** عندما تحتاج إلى نشر Backend إلى Render

#### الخطوات

1. **تحقق من Environment Variables**
   ```bash
   # في Render Dashboard
   DATABASE_URL=postgresql://...
   JWT_SECRET=...
   JWT_REFRESH_SECRET=...
   PORT=8080
   CORS_ORIGIN=...
   ```

2. **بناء Docker Image**
   ```bash
   docker build -t garage-backend ./backend
   ```

3. **دفع إلى Render**
   ```bash
   # عبر Render Dashboard أو CLI
   render deploy
   ```

4. **Verification**
   ```bash
   # اختبر API
   curl https://your-backend.onrender.com/api/health
   ```

#### معايير النجاح

- ✅ Backend يعمل على Render
- ✅ Environment variables مُضبطة
- ✅ API endpoints تعمل
- ✅ Database connection يعمل

#### المشاكل الشائعة

- ❌ **Missing environment variables:** تأكد من جميع variables مُضبطة
- ❌ **Database connection failed:** تحقق من DATABASE_URL
- ❌ **Build failed:** تحقق من Dockerfile

#### الوقت المقدر

30-60 دقيقة

---

### Playbook 15: نشر Admin Frontend إلى Cloudflare Pages

**الاستخدام:** عندما تحتاج إلى نشر Admin Frontend إلى Cloudflare Pages

#### الخطوات

1. **بناء Flutter Web**
   ```bash
   cd admin_frontend
   flutter build web
   ```

2. **رفع إلى Cloudflare Pages**
   ```bash
   # عبر Cloudflare Dashboard أو CLI
   wrangler pages deploy build/web
   ```

3. **إعدادات Environment**
   ```bash
   # في Cloudflare Pages Settings
   API_URL=https://your-backend.onrender.com
   ```

4. **Verification**
   ```bash
   # افتح URL في المتصفح
   # اختبر login
   # اختبر main features
   ```

#### معايير النجاح

- ✅ Frontend يعمل على Cloudflare Pages
- ✅ API URL مُضبوط بشكل صحيح
- ✅ Login يعمل
- ✅ Main features تعمل

#### المشاكل الشائعة

- ❌ **Wrong API URL:** تأكد من API URL صحيح
- ❌ **Build failed:** تحقق من flutter build web
- ❌ **CORS errors:** تأكد من CORS مُضبوط في Backend

#### الوقت المقدر

30-45 دقيقة

---

## 📊 Playbook Maintenance

### تحديث Playbooks

بعد كل مهمة:

1. **تحليل النتائج**
   - ما الذي نجح؟
   - ما الذي فشل؟
   - ما الذي يمكن تحسينه؟

2. **تحديث Playbook**
   - أضف خطوات جديدة إذا لزم الأمر
   - حدّث المشاكل الشائعة
   - حدّث الوقت المقدر

3. **إنشاء Playbook جديد**
   - إذا كانت المهمة متكررة
   - إذا كانت المهمة معقدة
   - إذا كانت المهمة تستغرق وقتاً طويلاً

---

**Playbooks Created:** May 24, 2026  
**Status:** Ready for Use  
**Next Update:** After first task execution
