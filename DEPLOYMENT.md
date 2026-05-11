# Deployment Guide

This guide provides step-by-step instructions for deploying the Auto Garage Management System.

## Table of Contents
- [Backend Deployment (Render)](#backend-deployment-render)
- [Customer Frontend Deployment (Cloudflare Pages)](#customer-frontend-deployment-cloudflare-pages)
- [Staff App & Mechanic App]((#staff-app--mechanic-app)
- [Environment Variables](#environment-variables)

## Backend Deployment (Render)

### Prerequisites
- Render account (free tier available)
- PostgreSQL database (can use Render PostgreSQL)
- GitHub repository with backend code

### Steps

1. **Prepare the Backend Repository**
   - Ensure `render.yaml` is in the backend root directory
   - Verify `Dockerfile` exists (optional, for container-based deployment)

2. **Set up PostgreSQL Database**
   - Create a PostgreSQL instance on Render
   - Note the connection string (DATABASE_URL)

3. **Connect GitHub Repository to Render**
   - Go to [render.com](https://render.com)
   - Click "New +" and select "Web Service"
   - Connect your GitHub repository
   - Select the `backend` directory as the root

4. **Configure Build Settings**
   - Build Command: `dart pub get`
   - Start Command: `dart run bin/server.dart`
   - Environment: Dart

5. **Add Environment Variables**
   - `DATABASE_URL`: Your PostgreSQL connection string
   - `JWT_SECRET`: Generate a secure random string
   - `PORT`: 8080 (default)

6. **Deploy**
   - Click "Create Web Service"
   - Render will automatically build and deploy
   - Wait for the deployment to complete

7. **Verify Deployment**
   - Check the deployment logs
   - Test the API endpoints
   - Example: `https://your-backend.onrender.com/api/dashboard/stats`

### Troubleshooting
- If deployment fails, check the build logs
- Ensure all dependencies are in `pubspec.yaml`
- Verify environment variables are set correctly
- Check that PostgreSQL is accessible

## Customer Frontend Deployment (Cloudflare Pages)

### Prerequisites
- Cloudflare account (free tier available)
- GitHub repository with customer_frontend code
- Flutter SDK installed locally

### Steps

1. **Build the Flutter Web App**
   ```bash
   cd customer_frontend
   flutter build web
   ```

2. **Prepare for Deployment**
   - Ensure `wrangler.toml` is in the customer_frontend directory
   - The `build/web` directory contains the static files

3. **Deploy via Cloudflare Dashboard**
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
   - Navigate to "Workers & Pages"
   - Click "Create application"
   - Select "Pages"
   - Choose "Upload assets" or connect GitHub

4. **Configure Build Settings (if using GitHub)**
   - Build command: `cd customer_frontend && flutter build web`
   - Build output directory: `customer_frontend/build/web`
   - Root directory: `/`

5. **Add Environment Variables (if needed)**
   - Add any API endpoints or configuration variables

6. **Deploy**
   - Click "Save and Deploy"
   - Wait for the build to complete

7. **Configure Custom Domain (Optional)**
   - Add a custom domain in Cloudflare
   - Update DNS settings

8. **Verify Deployment**
   - Visit your Cloudflare Pages URL
   - Test the tracking functionality
   - Ensure QR codes display correctly

### Alternative: Manual Upload
If you prefer manual deployment:
```bash
cd customer_frontend
flutter build web
# Upload the contents of build/web to Cloudflare Pages
```

## Staff App & Mechanic App

### Building for Different Platforms

**Windows:**
```bash
cd staff_app  # or mechanic_app
flutter build windows
```

**Android:**
```bash
cd staff_app  # or mechanic_app
flutter build apk
```

**Web:**
```bash
cd staff_app  # or mechanic_app
flutter build web
```

### Deployment Options

1. **Windows**: Distribute the executable file
2. **Android**: Upload APK to Google Play or distribute directly
3. **Web**: Deploy to any static hosting service (Netlify, Vercel, etc.)

## Environment Variables

### Backend Required Variables
- `DATABASE_URL`: PostgreSQL connection string
  - Format: `postgresql://username:password@host:port/database`
- `JWT_SECRET`: Secret key for JWT token generation
  - Generate using: `openssl rand -base64 32`
- `PORT`: Server port (default: 8080)

### Customer Frontend Variables (Optional)
- `API_BASE_URL`: Backend API URL
  - Example: `https://your-backend.onrender.com`

### Staff/Mechanic App Variables (Optional)
- `API_BASE_URL`: Backend API URL
  - Example: `https://your-backend.onrender.com`

## Security Considerations

1. **Never commit `.env` files** to version control
2. **Use strong JWT secrets** - generate random strings
3. **Enable SSL/TLS** on all deployments
4. **Rotate secrets regularly** in production
5. **Use environment-specific configurations**
6. **Enable CORS** only for trusted domains

## Post-Deployment Checklist

- [ ] Backend API is accessible
- [ ] Database connection is working
- [ ] JWT authentication is functional
- [ ] Customer frontend can track bookings
- [ ] Staff app can connect to backend
- [ ] Mechanic app can connect to backend
- [ ] All role-based permissions work correctly
- [ ] Public token tracking is functional
- [ ] SSL/TLS is enabled
- [ ] Monitoring/logging is configured

## Monitoring and Maintenance

### Backend Monitoring
- Use Render's built-in metrics
- Set up error tracking (Sentry, etc.)
- Monitor database performance
- Check API response times

### Frontend Monitoring
- Use Cloudflare Analytics
- Monitor page load times
- Track user interactions
- Check for console errors

### Regular Maintenance
- Update dependencies regularly
- Review and rotate secrets
- Backup database regularly
- Monitor storage usage
- Review logs for anomalies

## Support

For deployment issues:
1. Check deployment logs
2. Verify environment variables
3. Test database connectivity
4. Review API documentation
5. Check firewall/security settings
