# تقرير مقارنة الفرونت والباك (Frontend-Backend Comparison)

## تاريخ التحديث
19 مايو 2026 (تحديث شامل)

---

## 1. الجداول في قاعدة البيانات (schema.sql)

### ✅ الجداول الموجودة:

#### Accounting Tables:
- fiscal_periods
- accounts
- journal_entries
- journal_lines
- bank_accounts
- bank_reconciliations
- reconciliation_lines
- vendors
- purchase_invoices
- purchase_invoice_items
- expenses
- payroll_settings
- salary_payments

#### Core System Tables:
- users
- customers
- vehicles
- services
- bookings
- booking_services
- mechanic_assignments
- part_suggestions
- company_settings
- inventory_items
- inventory_variants
- inventory_transactions
- booking_invoice_data
- alerts

#### ERP Tables:
- fixed_assets
- depreciation_entries
- maintenance_contracts
- quotations
- quotation_items
- sales_orders
- sales_order_items
- purchase_orders
- purchase_order_items
- employee_contracts
- leave_requests
- performance_reviews

---

## 2. الـ endpoints في الباك end (Backend)

### ✅ Purchase Orders:
- GET /purchase-orders
- GET /purchase-orders/<id>
- POST /purchase-orders
- PUT /purchase-orders/<id>
- DELETE /purchase-orders/<id>
- PUT /purchase-orders/<id>/confirm
- PUT /purchase-orders/<id>/receive

### ✅ Quotations:
- GET /quotations
- GET /quotations/<id>
- POST /quotations
- PUT /quotations/<id>
- DELETE /quotations/<id>
- POST /quotations/<id>/convert-to-order

### ✅ Sales Orders:
- GET /sales-orders
- GET /sales-orders/<id>
- POST /sales-orders
- PUT /sales-orders/<id>
- DELETE /sales-orders/<id>
- POST /sales-orders/<id>/invoice

### ✅ Inventory Transfers:
- GET /inventory-transfers
- GET /inventory-transfers/<id>
- POST /inventory-transfers
- DELETE /inventory-transfers/<id>

### ✅ Warehouses:
- GET /warehouses
- GET /warehouses/<id>
- POST /warehouses
- PUT /warehouses/<id>
- DELETE /warehouses/<id>

### ✅ Manufacturing BOMs:
- GET /manufacturing/boms
- GET /manufacturing/boms/<id>
- POST /manufacturing/boms
- PUT /manufacturing/boms/<id>
- DELETE /manufacturing/boms/<id>

### ✅ Manufacturing Orders:
- GET /manufacturing/orders
- GET /manufacturing/orders/<id>
- POST /manufacturing/orders
- PUT /manufacturing/orders/<id>
- DELETE /manufacturing/orders/<id>
- POST /manufacturing/orders/<id>/complete

### ✅ CRM Leads:
- GET /crm/leads
- GET /crm/leads/<id>
- POST /crm/leads
- PUT /crm/leads/<id>
- PUT /crm/leads/<id>/convert
- DELETE /crm/leads/<id>

### ✅ CRM Activities:
- GET /crm/activities
- GET /crm/activities/<id>
- POST /crm/activities
- DELETE /crm/activities/<id>

### ✅ HR Contracts:
- GET /hr/contracts
- GET /hr/contracts/<id>
- POST /hr/contracts
- PUT /hr/contracts/<id>
- DELETE /hr/contracts/<id>

### ✅ HR Leave Requests:
- GET /hr/leave-requests
- GET /hr/leave-requests/<id>
- POST /hr/leave-requests
- PUT /hr/leave-requests/<id>/approve
- PUT /hr/leave-requests/<id>/reject
- DELETE /hr/leave-requests/<id>

### ✅ HR Performance Reviews:
- GET /hr/performance-reviews
- GET /hr/performance-reviews/<id>
- POST /hr/performance-reviews
- DELETE /hr/performance-reviews/<id>

### ✅ Fixed Assets:
- GET /assets
- GET /assets/<id>
- POST /assets
- PUT /assets/<id>
- DELETE /assets/<id>
- POST /assets/depreciate

### ✅ Maintenance Contracts:
- GET /maintenance/contracts
- GET /maintenance/contracts/<id>
- GET /maintenance/contracts/due
- POST /maintenance/contracts
- PUT /maintenance/contracts/<id>
- DELETE /maintenance/contracts/<id>

### ✅ Dashboard Stats:
- GET /dashboard/sales-stats
- GET /dashboard/purchase-stats
- GET /dashboard/inventory-stats
- GET /dashboard/manufacturing-stats
- GET /dashboard/hr-stats
- GET /dashboard/fixed-assets-stats

---

## 3. الـ providers في الفرونت end (Frontend)

### ✅ Purchase Orders:
- purchaseOrdersProvider (GET /purchase-orders)
- purchaseOrderProvider (GET /purchase-orders/$id)
- createPurchaseOrderProvider (POST /purchase-orders)
- updatePurchaseOrderProvider (PUT /purchase-orders/${args.id})
- deletePurchaseOrderProvider (DELETE /purchase-orders/$id)
- confirmPurchaseOrderProvider (PUT /purchase-orders/$id/confirm)
- receivePurchaseOrderProvider (PUT /purchase-orders/${args.id}/receive)

### ✅ Quotations:
- quotationsProvider (GET /quotations)
- quotationProvider (GET /quotations/$id)
- createQuotationProvider (POST /quotations)
- updateQuotationProvider (PUT /quotations/${args.id})
- deleteQuotationProvider (DELETE /quotations/$id)
- convertQuotationToOrderProvider (POST /quotations/$id/convert-to-order)

### ✅ Sales Orders:
- salesOrdersProvider (GET /sales-orders)
- salesOrderProvider (GET /sales-orders/$id)
- createSalesOrderProvider (POST /sales-orders)
- updateSalesOrderProvider (PUT /sales-orders/${args.id})
- deleteSalesOrderProvider (DELETE /sales-orders/$id)

### ✅ Inventory Transfers:
- inventoryTransfersProvider (GET /inventory-transfers)
- createInventoryTransferProvider (POST /inventory-transfers)
- deleteInventoryTransferProvider (DELETE /inventory-transfers/$id)

### ✅ Warehouses:
- warehousesProvider (GET /warehouses)
- warehouseProvider (GET /warehouses/$id)
- createWarehouseProvider (POST /warehouses)
- updateWarehouseProvider (PUT /warehouses/${args.id})
- deleteWarehouseProvider (DELETE /warehouses/$id)

### ✅ Manufacturing BOMs:
- bomsProvider (GET /manufacturing/boms)
- bomProvider (GET /manufacturing/boms/$id)
- createBomProvider (POST /manufacturing/boms)
- updateBomProvider (PUT /manufacturing/boms/${args.id})
- deleteBomProvider (DELETE /manufacturing/boms/$id)

### ✅ Manufacturing Orders:
- manufacturingOrdersProvider (GET /manufacturing/orders)
- manufacturingOrderProvider (GET /manufacturing/orders/$id)
- createManufacturingOrderProvider (POST /manufacturing/orders)
- updateManufacturingOrderProvider (PUT /manufacturing/orders/${args.id})
- completeManufacturingOrderProvider (PUT /manufacturing/orders/$id/complete)
- deleteManufacturingOrderProvider (DELETE /manufacturing/orders/$id)

### ✅ CRM Leads:
- crmLeadsProvider (GET /crm/leads)
- crmLeadProvider (GET /crm/leads/$id)
- createCrmLeadProvider (POST /crm/leads)
- updateCrmLeadProvider (PUT /crm/leads/${args.id})
- convertLeadProvider (PUT /crm/leads/$id/convert)
- deleteCrmLeadProvider (DELETE /crm/leads/$id)

### ✅ HR Contracts:
- employeeContractsProvider (GET /hr/contracts)
- employeeContractProvider (GET /hr/contracts/$id)
- createEmployeeContractProvider (POST /hr/contracts)
- updateEmployeeContractProvider (PUT /hr/contracts/${args.id})
- deleteEmployeeContractProvider (DELETE /hr/contracts/$id)

### ✅ HR Leave Requests:
- leaveRequestsProvider (GET /hr/leave-requests)
- leaveRequestProvider (GET /hr/leave-requests/$id)
- createLeaveRequestProvider (POST /hr/leave-requests)
- approveLeaveRequestProvider (PUT /hr/leave-requests/${args.id}/approve)
- rejectLeaveRequestProvider (PUT /hr/leave-requests/${args.id}/reject)
- deleteLeaveRequestProvider (DELETE /hr/leave-requests/$id)

### ✅ Fixed Assets:
- fixedAssetsProvider (GET /assets)
- fixedAssetProvider (GET /assets/$id)
- createFixedAssetProvider (POST /assets)
- updateFixedAssetProvider (PUT /assets/${args.id})
- deleteFixedAssetProvider (DELETE /assets/$id)

### ✅ Maintenance Contracts:
- maintenanceContractsProvider (GET /maintenance/contracts)
- maintenanceContractProvider (GET /maintenance/contracts/$id)
- createMaintenanceContractProvider (POST /maintenance/contracts)
- updateMaintenanceContractProvider (PUT /maintenance/contracts/${args.id})
- deleteMaintenanceContractProvider (DELETE /maintenance/contracts/$id)

---

## 4. الاختلافات والمشاكل

### ⚠️ الاختلافات المكتشفة:

#### 1. Manufacturing Orders Complete Endpoint:
- **الباك end:** POST /manufacturing/orders/<id>/complete
- **الفرونت end:** PUT /manufacturing/orders/$id/complete
- **الحالة:** ⚠️ HTTP method مختلف (POST vs PUT)
- **التوصية:** تغيير الفرونت end لاستخدام POST بدلاً من PUT

#### 2. CRM Activities:
- **الباك end:** يوفر endpoints لـ CRM Activities
- **الفرونت end:** لا يوجد providers لـ CRM Activities
- **الحالة:** ⚠️ Feature غير مستخدم في الفرونت end
- **التوصية:** إضافة providers لـ CRM Activities في الفرونت end إذا كانت مطلوبة

#### 3. HR Performance Reviews:
- **الباك end:** يوفر endpoints لـ HR Performance Reviews
- **الفرونت end:** لا يوجد providers لـ HR Performance Reviews
- **الحالة:** ⚠️ Feature غير مستخدم في الفرونت end
- **التوصية:** إضافة providers لـ HR Performance Reviews في الفرونت end إذا كانت مطلوبة

#### 4. Fixed Assets Depreciate:
- **الباك end:** POST /assets/depreciate
- **الفرونت end:** لا يوجد provider
- **الحالة:** ⚠️ Feature غير مستخدم في الفرونت end
- **التوصية:** إضافة provider لـ Fixed Assets Depreciation في الفرونت end إذا كانت مطلوبة

#### 5. Maintenance Contracts Due:
- **الباك end:** GET /maintenance/contracts/due
- **الفرونت end:** لا يوجد provider
- **الحالة:** ⚠️ Feature غير مستخدم في الفرونت end
- **التوصية:** إضافة provider لـ Maintenance Contracts Due في الفرونت end إذا كانت مطلوبة

#### 6. Sales Orders Invoice:
- **الباك end:** POST /sales-orders/<id>/invoice
- **الفرونت end:** لا يوجد provider
- **الحالة:** ⚠️ Feature غير مستخدم في الفرونت end
- **التوصية:** إضافة provider لـ Sales Orders Invoice في الفرونت end إذا كانت مطلوبة

#### 7. Inventory Transfers GET by ID:
- **الباك end:** GET /inventory-transfers/<id>
- **الفرونت end:** لا يوجد provider
- **الحالة:** ⚠️ Feature غير مستخدم في الفرونت end
- **التوصية:** إضافة provider لـ Inventory Transfer by ID في الفرونت end إذا كانت مطلوبة

---

## 5. المشاكل الحالية

### 🔴 المشاكل الحرجة:

1. **تسجيل الخروج لا يعمل** - تم إصلاحه باستخدام authProvider
2. **أخطاء 500 على dashboard stats endpoints** - سببها جداول quotations و employee_contracts غير موجودة (تم إضافتها للتو)
3. **أخطاء 401 على /assets endpoint** - سببها authentication middleware (يجب تسجيل الدخول)
4. **WebSocket connection failed** - قد يكون بسبب أن الباك end لا يدعم WebSocket أو endpoint غير صحيح

### 🟡 المشاكل المتوسطة:

1. **HTTP method مختلف في Manufacturing Orders Complete** - PUT vs POST
2. **Features غير مستخدمة** - CRM Activities, HR Performance Reviews, Fixed Assets Depreciate, Maintenance Contracts Due, Sales Orders Invoice

---

## 6. التوصيات

### قصيرة المدى (قبل الإطلاق):

1. ✅ إصلاح تسجيل الخروج - تم
2. ✅ إضافة الجداول المفقودة إلى schema.sql - تم
3. ⚠️ تغيير HTTP method في completeManufacturingOrderProvider من PUT إلى POST
4. ⚠️ إعادة نشر الباك end على Render لتنفيذ schema الجديد
5. ⚠️ اختبار السيناريوهات يدوياً مع Backend حقيقي

### متوسطة المدى:

1. إضافة providers للـ Features غير المستخدمة إذا كانت مطلوبة:
   - CRM Activities providers
   - HR Performance Reviews providers
   - Fixed Assets Depreciate provider
   - Maintenance Contracts Due provider
   - Sales Orders Invoice provider
   - Inventory Transfer by ID provider

2. فحص WebSocket connection وإصلاحه إذا كان مطلوباً

### طويلة المدى:

1. إنشاء اختبارات آلية (Unit Tests) لجميع الـ Models
2. إنشاء اختبارات تكامل (Integration Tests) للـ endpoints
3. إضافة documentation للـ API (Swagger/OpenAPI)

---

## 7. الخلاصة

### ✅ الحالة العامة:
- الجداول في قاعدة البيانات: ✅ كاملة
- الـ endpoints في الباك end: ✅ كاملة
- الـ providers في الفرونت end: ✅ معظمها كاملة
- التطابق بين الفرونت والباك: ⚠️ جيد مع بعض الاختلافات الطفيفة

### 🔧 الإصلاحات المطلوبة:
1. تغيير HTTP method في completeManufacturingOrderProvider
2. إعادة نشر الباك end على Render
3. إضافة providers للـ Features غير المستخدمة (اختياري)
