# ⚡ Hetzner Quick Start Guide

## 🚀 Fast Deployment (5 minutes)

### 1. Connect to Hetzner
```bash
ssh root@your-hetzner-ip
```

### 2. Run Deployment Script
```bash
# Download and run the script
curl -fsSL https://raw.githubusercontent.com/karam-55/auto-garage-system/main/deploy.sh -o deploy.sh
chmod +x deploy.sh
./deploy.sh
```

### 3. Access Your Application
- **Frontend**: `http://your-hetzner-ip`
- **Backend API**: `http://your-hetzner-ip:8080`
- **Default Login**: `admin` / `admin123`

## 🔧 Manual Deployment (15 minutes)

If the script fails, follow these steps:

### 1. Install Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable docker
```

### 2. Install Docker Compose
```bash
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### 3. Clone Project
```bash
cd /var/www
git clone https://github.com/karam-55/auto-garage-system.git auto-garage
cd auto-garage
```

### 4. Build Frontend
```bash
cd admin_frontend
flutter pub get
flutter build web
cd ..
```

### 5. Start Services
```bash
docker-compose up -d
```

### 6. Run Migrations
```bash
docker-compose exec postgres psql -U garage -d garage_db -f /docker-entrypoint-initdb.d/2026-05-24_seed_chart_of_accounts.sql
```

## 🔒 Setup SSL (Optional)

### 1. Update nginx-ssl.conf
Replace `your-domain.com` with your actual domain

### 2. Stop nginx
```bash
docker-compose stop nginx
```

### 3. Get SSL Certificate
```bash
certbot certonly --standalone -d your-domain.com
```

### 4. Update docker-compose.yml
```yaml
nginx:
  volumes:
    - ./nginx-ssl.conf:/etc/nginx/nginx.conf:ro
    - /etc/letsencrypt:/etc/letsencrypt:ro
```

### 5. Restart nginx
```bash
docker-compose up -d nginx
```

## 📊 Monitor Deployment

### Check Status
```bash
docker-compose ps
```

### View Logs
```bash
docker-compose logs -f
```

### Restart Services
```bash
docker-compose restart backend
```

## 🆘 Troubleshooting

### Backend not responding
```bash
docker-compose logs backend
docker-compose restart backend
```

### Database connection error
```bash
docker-compose restart postgres
docker-compose logs postgres
```

### Frontend not loading
```bash
docker-compose logs nginx
docker-compose restart nginx
```

## 📞 Need Help?

Check the full guide: `HETZNER_DEPLOYMENT.md`
