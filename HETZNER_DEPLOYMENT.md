# 🚀 Hetzner Deployment Guide

## 📋 Prerequisites

1. **Hetzner Server** (Ubuntu 22.04 recommended)
2. **Domain Name** (optional but recommended for SSL)
3. **SSH Access** to your Hetzner server

## 🔧 Step 1: Initial Server Setup

### Connect to Hetzner Server
```bash
ssh root@your-hetzner-ip
```

### Update System
```bash
apt update && apt upgrade -y
```

### Install Docker & Docker Compose
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Enable Docker on boot
systemctl enable docker
```

### Install Additional Tools
```bash
# Install Git, Curl, and other tools
apt install -y git curl nginx certbot python3-certbot-nginx

# Create project directory
mkdir -p /var/www/auto-garage
cd /var/www/auto-garage
```

## 📦 Step 2: Deploy Project Files

### Option A: Clone from GitHub
```bash
git clone https://github.com/karam-55/auto-garage-system.git .
```

### Option B: Upload Files Manually
```bash
# On your local machine
scp -r auto-garrage root@your-hetzner-ip:/var/www/
```

## 🔐 Step 3: Configure Environment

### Update docker-compose.yml
```bash
# Edit docker-compose.yml if needed
nano docker-compose.yml
```

**Important Security Changes:**
- Change `POSTGRES_PASSWORD` to a strong password
- Change `JWT_SECRET` and `JWT_REFRESH_SECRET` to random strings
- Generate secrets: `openssl rand -hex 32`

## 🏗️ Step 4: Build Frontend

### Build Admin Frontend
```bash
cd admin_frontend
flutter pub get
flutter build web
cd ..
```

### Build Customer Frontend (if exists)
```bash
cd customer-frontend
# Build process for customer frontend
cd ..
```

## 🗄️ Step 5: Initialize Database

### Run Migrations
```bash
# Start only PostgreSQL
docker-compose up -d postgres

# Wait for PostgreSQL to be ready
sleep 10

# Run migrations
docker-compose exec postgres psql -U garage -d garage_db -f /docker-entrypoint-initdb.d/2026-05-24_add_acquisition_date_to_fixed_assets.sql
docker-compose exec postgres psql -U garage -d garage_db -f /docker-entrypoint-initdb.d/2026-05-24_seed_chart_of_accounts.sql

# Stop PostgreSQL
docker-compose down
```

## 🚀 Step 6: Start All Services

### Start Docker Compose
```bash
docker-compose up -d
```

### Check Status
```bash
docker-compose ps
docker-compose logs -f
```

## 🔗 Step 7: Configure Nginx

### Copy Nginx Config
```bash
# The nginx.conf is already mounted in docker-compose
# Just restart nginx container
docker-compose restart nginx
```

## 🔒 Step 8: Setup SSL (Optional but Recommended)

### If you have a domain:

1. **Update nginx-ssl.conf**
```bash
nano nginx-ssl.conf
# Replace 'your-domain.com' with your actual domain
```

2. **Stop current nginx**
```bash
docker-compose stop nginx
```

3. **Run Certbot**
```bash
certbot certonly --standalone -d your-domain.com -d www.your-domain.com
```

4. **Update docker-compose.yml**
```yaml
nginx:
  volumes:
    - ./nginx-ssl.conf:/etc/nginx/nginx.conf:ro
    - /etc/letsencrypt:/etc/letsencrypt:ro
```

5. **Start nginx with SSL**
```bash
docker-compose up -d nginx
```

## 🧪 Step 9: Test Deployment

### Test Backend
```bash
curl http://your-hetzner-ip:8080/api/health
```

### Test Frontend
- Open browser: `http://your-hetzner-ip`
- Try login with: `admin` / `admin123`

### Test Database Connection
```bash
docker-compose exec postgres psql -U garage -d garage_db -c "SELECT COUNT(*) FROM accounts;"
```

## 📊 Step 10: Monitor & Maintenance

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f postgres
docker-compose logs -f nginx
```

### Restart Services
```bash
docker-compose restart backend
docker-compose restart postgres
docker-compose restart nginx
```

### Update Application
```bash
# Pull latest code
git pull

# Rebuild and restart
docker-compose down
docker-compose build backend
docker-compose up -d
```

### Database Backup
```bash
# Backup
docker-compose exec postgres pg_dump -U garage garage_db > backup_$(date +%Y%m%d).sql

# Restore
docker-compose exec -T postgres psql -U garage garage_db < backup_20240524.sql
```

## 🔧 Troubleshooting

### Backend not starting
```bash
# Check logs
docker-compose logs backend

# Check database connection
docker-compose exec postgres psql -U garage -d garage_db
```

### Frontend not loading
```bash
# Check nginx logs
docker-compose logs nginx

# Check if files exist
ls -la admin_frontend/build/web
```

### Database connection issues
```bash
# Check PostgreSQL status
docker-compose ps postgres

# Restart PostgreSQL
docker-compose restart postgres
```

### Port conflicts
```bash
# Check what's using port 80
netstat -tulpn | grep :80

# Stop conflicting service
systemctl stop nginx  # if nginx is installed on host
```

## 📈 Performance Optimization

### Enable Docker Swarm (for scaling)
```bash
docker swarm init
docker stack deploy -c docker-compose.yml garage
```

### Add Swap Space
```bash
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

### Configure Firewall
```bash
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw enable
```

## 🎯 Next Steps

1. **Monitor Performance**: Use `htop` to monitor resources
2. **Setup Backups**: Automate database backups with cron
3. **Configure Domain**: Point your domain to Hetzner IP
4. **Setup Monitoring**: Consider using Prometheus + Grafana
5. **Setup CI/CD**: Automate deployment with GitHub Actions

## 📞 Support

If you encounter issues:
1. Check logs: `docker-compose logs -f`
2. Verify configuration: `docker-compose config`
3. Check Docker status: `systemctl status docker`
4. Review Hetzner server metrics in their dashboard
