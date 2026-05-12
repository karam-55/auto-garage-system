# Cloudflare Worker - Auto Garage API Proxy

هذا Worker يعمل كـ Reverse Proxy لتجاوز مشكلة DNS على الموبايل.

## نشر Worker

1. تثبيت Wrangler CLI:
```bash
npm install -g wrangler
```

2. تسجيل الدخول إلى Cloudflare:
```bash
wrangler login
```

3. نشر Worker:
```bash
cd cloudflare-worker
wrangler deploy
```

4. بعد النشر، ستحصل على URL مثل: `https://auto-garage-proxy.your-subdomain.workers.dev`

## تحديث API URL في mechanic_app

بعد الحصول على Worker URL، قم بتحديث `mechanic_app/lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = "https://auto-garage-proxy.your-subdomain.workers.dev";
```

## إعادة بناء mechanic_app

```bash
cd mechanic_app
flutter build apk
```
