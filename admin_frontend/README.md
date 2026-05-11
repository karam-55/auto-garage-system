# Auto Garage Admin Frontend

Admin dashboard for the Auto Garage System - built with Flutter Web.

## Features

- Dashboard Overview
- Bookings Management
- Customers Management
- Services Management
- Employees Management
- Reports & Analytics

## Getting Started

### Prerequisites

- Flutter SDK 3.11.5 or higher
- Dart SDK

### Installation

```bash
flutter pub get
```

### Run locally

```bash
flutter run -d chrome
```

### Build for production

```bash
flutter build web --release
```

## Deployment

### Cloudflare Pages

The project is configured for Cloudflare Pages deployment via `wrangler.toml`.

### Docker

A Dockerfile is provided for containerized deployment.

## Environment Variables

- `API_URL`: Backend API URL (default: https://auto-garage-system-backend.onrender.com)
