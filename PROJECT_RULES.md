# قواعد المشروع الذهبية - Garage Go
# Project Golden Rules - Auto Garage Management System

**آخر تحديث:** 2026-05-24

---

## 🎯 قواعد يجب أن تُتذكر دائماً

### 1. التحكم في الإصدارات (Git) ⚠️ مهم جداً

- ✅ **جميع التغييرات تُرفع إلى main فقط**
  - لا تفرع (branch) جديداً
  - استخدم main مباشرة
  - هذا قاعدة صارمة للمشروع

- ✅ **بعد كل إصلاح ناجح، قم بعمل commit**
  - رسالة واضحة وموجزة
  - أمثلة:
    - `fix: add missing indexes`
    - `fix: secure password storage`
    - `feat: add rate limiting middleware`
    - `feat: improve performance with caching`

- ✅ **ادفع التغييرات فوراً**
  - لا تتراكم التغييرات
  - ادفع بعد كل commit مهم

---

### 2. بيئة الاستضافة (Hosting Environment) ⚠️ مهم جداً

#### Backend + Database: Render (PostgreSQL 15)
- ✅ أي تغيير في `schema.sql` أو migrations يجب أن يكون متوافقاً مع PostgreSQL 15
- ✅ أي إضافة متغيرات بيئة جديدة يجب:
  - توثيقها في `backend/.env.example`
  - إضافتها في Render Dashboard
- ✅ بعد دفع التغييرات، Render سيقوم بـ redeploy تلقائياً

#### Admin Frontend: Cloudflare Pages (Flutter Web)
- ✅ البناء يجب أن يبقى متوافقاً مع استضافة ملفات ثابتة
- ✅ بعد دفع التغييرات، Cloudflare سيقوم بـ rebuild تلقائياً

#### Customer Frontend: Cloudflare Pages (Static HTML)
- ✅ موجود في `customer_frontend/`
- ✅ يستدعي API العامة `/public/*`
- ⚠️ **لا تقم بتعديله إلا إذا لاحظت خللاً في الـ API**
- ⚠️ هذا ملف HTML واحد فقط، لا تقم بتعديله بدون سبب قوي

#### Mechanic App: Flutter Mobile
- ✅ لا يحتاج تعديل حالياً
- ✅ تأكد من أن التغييرات في الـ API لن تكسر توافقه
- ✅ استخدم نفس الـ endpoints الموجودة

---

### 3. التغييرات المطلوبة على وجه التحديد

#### CORS Origins ⚠️ مهم جداً
- ✅ تستخدم متغيرات بيئة منفصلة لكل واجهة:
  - `CORS_ORIGIN` → واجهة الأدمن (Flutter Web)
  - `CUSTOMER_CORS_ORIGIN` → واجهة الزبون (HTML)
  - `MECHANIC_CORS_ORIGIN` → تطبيق الميكانيكي (Mobile)
- ✅ القيم الحالية في Render:
  - `CORS_ORIGIN=https://auto-garage-staff-frontend.pages.dev`
  - `CUSTOMER_CORS_ORIGIN=https://auto-garage-customer-frontend.pages.dev`
  - `MECHANIC_CORS_ORIGIN=*` (أي نطاق)
- ✅ استبدل النطاقات بالقيم الفعلية من Cloudflare
- ✅ CORS middleware يجمع هذه المتغيرات تلقائياً

#### CSRF Protection
- ✅ لا يُطبق على المسارات العامة `/public/*`
- ✅ يُطبق فقط على المسارات المحمية بالمصادقة
- ✅ السبب: الواجهة العامة للزبائن لا تحتاج CSRF

#### Batch Endpoint
- ✅ `/api/bookings/batch-invoices` يتطلب مصادقة
- ✅ لا يعرض بيانات حساسة بدون مصادقة
- ✅ يستخدم نفس middleware المصادقة الموجود

---

### 4. بعد الانتهاء من الإصلاحات

#### في التقرير النهائي (`FIXES_SUMMARY.md`)
- ✅ قائمة بكل الـ commits التي تم دفعها إلى main
- ✅ تعليمات تشغيل الـ migrations على Render
- ✅ أي متغيرات بيئة جديدة يجب إضافتها في Render
- ✅ أي متغيرات بيئة جديدة يجب إضافتها في Cloudflare

#### في Git
- ✅ دفع جميع التغييرات إلى main
- ✅ التأكد من أن جميع commits واضحة
- ✅ التأكد من أن لا توجد ملفات غير ملتزم

---

## 📊 ملخص بيئة الاستضافة

| المكون | الاستضافة | التكنولوجيا | ملاحظات |
|--------|-----------|-------------|---------|
| **Backend** | Render | Dart + Shelf | PostgreSQL 15 |
| **Backend URL** | https://auto-garage-system-backend.onrender.com | - | - |
| **Database** | Render | PostgreSQL 15 | Managed Database |
| **Admin Frontend** | Cloudflare Pages | Flutter Web | Static Files |
| **Customer Frontend** | Cloudflare Pages | HTML/JS | Single HTML File |
| **Mechanic App** | - | Flutter Mobile | Not Hosted Yet |

---

## 🔧 المتغيرات البيئة الحالية

### Backend (Render)
| Key | الوصف | مطلوب؟ |
|-----|-------|--------|
| `DATABASE_URL` | PostgreSQL connection string | ✅ نعم |
| `PORT` | Server port | ✅ نعم |
| `JWT_SECRET` | JWT secret key | ✅ نعم |
| `JWT_REFRESH_SECRET` | JWT refresh secret | ✅ نعم |
| `CORS_ORIGIN` | Admin frontend CORS origin | ✅ نعم |
| `CUSTOMER_CORS_ORIGIN` | Customer frontend CORS origin | ✅ نعم |
| `MECHANIC_CORS_ORIGIN` | Mechanic app CORS origin | ✅ نعم |
| `DEFAULT_ADMIN_PASSWORD` | Default admin password | ✅ نعم |
| `DEFAULT_RECEPTIONIST_PASSWORD` | Default receptionist password | ✅ نعم |
| `WHATSAPP_API_KEY` | WhatsApp API key | ❌ مستقبلي |
| `WHATSAPP_PHONE_NUMBER_ID` | WhatsApp phone number ID | ❌ مستقبلي |

### Frontend (Cloudflare)
- لا يحتاج متغيرات بيئة حالياً
- يتم تحديد API URL في الكود

---

## 🚝 سير العمل الموصى به (Recommended Workflow)

### 1. قبل البدء بأي تغيير
- ✅ قراءة هذه القواعد
- ✅ التأكد من أن التغيير ضروري
- ✅ التأكد من التوافق مع بيئة الإنتاج

### 2. أثناء التغيير
- ✅ العمل على main فقط
- ✅ التوثيق أثناء العمل
- ✅ اختبار التغييرات محلياً

### 3. بعد التغيير
- ✅ تحديث `.env.example` إذا لزم الأمر
- ✅ عمل commit برسالة واضحة
- ✅ دفع التغييرات إلى main
- ✅ تحديث `FIXES_SUMMARY.md` إذا لزم الأمر

### 4. بعد الدفع
- ✅ مراقبة Render logs
- ✅ مراقبة Cloudflare build logs
- ✅ اختبار الإنتاج
- ✅ التوثيق في التقرير النهائي

---

## ⚠️ تحذيرات مهمة

### لا تقم بـ:
- ❌ إنشاء branch جديد
- ❌ تعديل `customer_frontend/` بدون سبب قوي
- ❌ تعديل `mechanic_app_new/` بدون سبب قوي
- ❌ إضافة متغيرات بيئة بدون توثيقها
- ❌ دفع تغييرات غير مختبرة
- ❌ استخدام قاعدة بيانات غير PostgreSQL 15

### قم دائماً بـ:
- ✅ العمل على main
- ✅ التوثيق في `.env.example`
- ✅ اختبار محلياً قبل الدفع
- ✅ استخدام رسائل commit واضحة
- ✅ مراقبة logs بعد النشر
- ✅ التوثيق في التقرير النهائي

---

## 📞 الدعم

إذا واجهت أي مشاكل:
1. راجع هذه القواعد
2. راجع `FIXES_SUMMARY.md`
3. راجع التقارير الأصلية
4. تحقق من Render logs
5. تحقق من Cloudflare logs

---

**تم إنشاء هذا الملف بواسطة Devin - 2026-05-24**
**آخر تحديث:** 2026-05-24
