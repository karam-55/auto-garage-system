# 🚀 Hetzner Deployment - Step by Step Guide

## 📋 Prerequisites
- Hetzner Server (Ubuntu, 2 vCPU, 4GB RAM)
- SSH Access
- Project files ready

## 🔧 Step 1: Connect to Hetzner Server

```bash
ssh root@your-hetzner-ip
```

## 📦 Step 2: Update System

```bash
apt update && apt upgrade -y
```

## 🐳 Step 3: Install Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable docker
```

## 🔧 Step 4: Install Docker Compose

```bash
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

## 💾 Step 5: Add Swap Space (Important for 4GB RAM)

```bash
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 🛠️ Step 6: Install Additional Tools

```bash
apt install -y git curl htop vim net-tools
```

## 📁 Step 7: Create Project Directory

```bash
mkdir -p /var/www/auto-garage
cd /var/www/auto-garage
```

## 📥 Step 8: Clone Project

```bash
git clone https://github.com/karam-55/auto-garage-system.git .
```

## 🎨 Step 9: Build Frontend (ON YOUR LOCAL MACHINE)

```bash
# On your local machine
cd admin_frontend
flutter pub get
flutter build web
```

## 📤 Step 10: Upload Frontend to Hetzner

```bash
# On your local machine
scp -r admin_frontend/build/web root@your-hetzner-ip:/var/www/auto-garage/admin_frontend/
```

## 🔐 Step 11: Generate Secrets

```bash
# On Hetzner server
cd /var/www/auto-garage
openssl rand -hex 16  # Use this as POSTGRES_PASSWORD
openssl rand -hex 32  # Use this as JWT_SECRET
openssl rand -hex 32  # Use this as JWT_REFRESH_SECRET
```

## 🔧 Step 12: Update docker-compose.yml

```bash
nano docker-compose.yml
```

Replace the secrets with the ones you generated:
- `POSTGRES_PASSWORD`
- `JWT_SECRET`
- `JWT_REFRESH_SECRET`

## 📂 Step 13: Create Required Directories

```bash
mkdir -p certbot/conf certbot/www
mkdir -p migrations
```

## 🚀 Step 14: Start Services

```bash
docker-compose up -d postgres
```

## ⏳ Step 15: Wait for PostgreSQL

```bash
# Wait 20 seconds
sleep 20
```

## 🗄️ Step 16: Run Migrations

```bash
docker-compose exec -T postgres psql -U garage -d garage_db < migrations/2026-05-24_add_acquisition_date_to_fixed_assets.sql
docker-compose exec -T postgres psql -U garage -d garage_db < migrations/2026-05-24_seed_chart_of_accounts.sql
```

## 🎯 Step 17: Start All Services

```bash
docker-compose up -d
```

## 🔒 Step 18: Configure Firewall

```bash
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
```

## 📊 Step 19: Check Status

```bash
docker-compose ps
```

## 🌐 Step 20: Access Your Application

```
Frontend: http://your-hetzner-ip
Backend API: http://your-hetzner-ip:8080
Login: admin / admin123
```

## 🧪 Step 21: Test Deployment

```bash
# Test backend
curl http://localhost:8080/api/health

# Test database
docker-compose exec postgres psql -U garage -d garage_db -c "SELECT COUNT(*) FROM accounts;"
```

## 📋 Step 22: Monitor Resources

```bash
htop
```

## 📝 Step 23: View Logs

```bash
docker-compose logs -f
```

## 🔄 Step 24: Restart Services (if needed)

```bash
docker-compose restart backend
docker-compose restart postgres
docker-compose restart nginx
```

## 🎉 Deployment Complete!

Your Auto Garage System is now running on Hetzner!

## 📞 Next Steps

1. Test the application thoroughly
2. Monitor resource usage with `htop`
3. Setup SSL if you get a domain
4. Configure automated backups
5. Setup monitoring alerts

## 🔧 Troubleshooting

### Backend not starting
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

### Out of memory
```bash
# Check swap
free -h
# Check Docker resource usage
docker stats
