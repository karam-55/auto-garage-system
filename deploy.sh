#!/bin/bash

# Auto Garage System - Hetzner Deployment Script
# Optimized for 2 vCPU, 4GB RAM Ubuntu Server
# This script automates the deployment process

set -e  # Exit on error

echo "🚀 Auto Garage System - Hetzner Deployment"
echo "=========================================="
echo "Server Specs: 2 vCPU, 4GB RAM"
echo "OS: Ubuntu"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root (use sudo)"
    exit 1
fi

# Step 1: Update System
echo "📦 Step 1: Updating system..."
apt update && apt upgrade -y
print_success "System updated"

# Step 2: Install Docker
echo "🐳 Step 2: Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl enable docker
    print_success "Docker installed"
else
    print_success "Docker already installed"
fi

# Step 3: Install Docker Compose
echo "🔧 Step 3: Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed"
else
    print_success "Docker Compose already installed"
fi

# Step 4: Install Additional Tools
echo "🛠️ Step 4: Installing additional tools..."
apt install -y git curl htop vim net-tools
print_success "Additional tools installed"

# Step 5: Add Swap Space (Important for 4GB RAM)
echo "💾 Step 5: Adding swap space (2GB)..."
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    print_success "Swap space added"
else
    print_success "Swap space already exists"
fi

# Step 6: Configure Docker for Low Memory
echo "⚙️ Step 6: Optimizing Docker for 4GB RAM..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF
systemctl restart docker
print_success "Docker optimized"

# Step 7: Create Project Directory
echo "📁 Step 7: Creating project directory..."
mkdir -p /var/www/auto-garage
cd /var/www/auto-garage
print_success "Project directory created"

# Step 8: Clone or Copy Project
echo "📥 Step 8: Setting up project files..."
if [ -d ".git" ]; then
    print_success "Project already exists, pulling latest changes..."
    git pull
else
    if [ -z "$GIT_REPO_URL" ]; then
        GIT_REPO_URL="https://github.com/karam-55/auto-garage-system.git"
    fi
    git clone $GIT_REPO_URL .
    print_success "Project cloned from GitHub"
fi

# Step 9: Build Frontend (Skip on server, assume pre-built)
echo "🎨 Step 9: Checking frontend build..."
if [ -d "admin_frontend/build/web" ]; then
    print_success "Frontend already built"
else
    print_warning "Frontend not built. Please build on local machine and upload:"
    print_info "1. On local machine: cd admin_frontend && flutter build web"
    print_info "2. Upload admin_frontend/build/web to server"
fi

# Step 10: Generate Secrets
echo "🔐 Step 10: Generating secrets..."
if [ ! -f ".env" ]; then
    cat > .env << EOF
POSTGRES_PASSWORD=$(openssl rand -hex 16)
JWT_SECRET=$(openssl rand -hex 32)
JWT_REFRESH_SECRET=$(openssl rand -hex 32)
EOF
    print_success "Secrets generated and saved to .env"
    print_info "Generated secrets saved. Keep them safe!"
else
    print_success "Secrets already exist"
fi

# Step 11: Create Required Directories
echo "📂 Step 11: Creating required directories..."
mkdir -p certbot/conf certbot/www
mkdir -p migrations
print_success "Directories created"

# Step 12: Update docker-compose.yml with secrets
echo "🔧 Step 12: Updating docker-compose.yml with secrets..."
if [ -f ".env" ]; then
    source .env
    sed -i "s/garage123/$POSTGRES_PASSWORD/g" docker-compose.yml
    sed -i "s/7f82670b53bd936d32f73af55c021a82/$JWT_SECRET/g" docker-compose.yml
    sed -i "s/673d0b0d0fc538ae34a3d177f682d2ac/$JWT_REFRESH_SECRET/g" docker-compose.yml
    print_success "docker-compose.yml updated with secrets"
fi

# Step 13: Start Services
echo "🚀 Step 13: Starting services..."
docker-compose down
docker-compose up -d postgres
print_success "PostgreSQL started"

# Wait for PostgreSQL
echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 20

# Step 14: Run Migrations
echo "🗄️ Step 14: Running database migrations..."
if [ -f "migrations/2026-05-24_add_acquisition_date_to_fixed_assets.sql" ]; then
    docker-compose exec -T postgres psql -U garage -d garage_db < migrations/2026-05-24_add_acquisition_date_to_fixed_assets.sql
    print_success "Migration 1 executed"
fi

if [ -f "migrations/2026-05-24_seed_chart_of_accounts.sql" ]; then
    docker-compose exec -T postgres psql -U garage -d garage_db < migrations/2026-05-24_seed_chart_of_accounts.sql
    print_success "Migration 2 executed"
fi

# Step 15: Start All Services
echo "🎯 Step 15: Starting all services..."
docker-compose up -d
print_success "All services started"

# Step 16: Configure Firewall
echo "🔒 Step 16: Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    print_success "Firewall configured"
else
    print_warning "UFW not found, skipping firewall configuration"
fi

# Step 17: Display Status
echo ""
echo "📊 Deployment Status:"
echo "===================="
docker-compose ps
echo ""

# Step 18: Display Access Information
echo "🌐 Access Information:"
echo "====================="
SERVER_IP=$(curl -s ifconfig.me)
echo "Backend API: http://$SERVER_IP:8080"
echo "Frontend: http://$SERVER_IP"
echo "Database: postgres://garage:PASSWORD@localhost:5432/garage_db"
echo ""
echo "🔑 Default Credentials:"
echo "Username: admin"
echo "Password: admin123"
echo ""

# Step 19: Display Resource Usage
echo "💾 Resource Usage:"
echo "================"
free -h
df -h
echo ""

# Step 20: Final Instructions
echo "📋 Next Steps:"
echo "============"
echo "1. Test the deployment by accessing: http://$SERVER_IP"
echo "2. Login with: admin / admin123"
echo "3. Monitor logs: docker-compose logs -f"
echo "4. Monitor resources: htop"
echo "5. View this guide: cat HETZNER_DEPLOYMENT.md"
echo "6. If you have a domain later, setup SSL using nginx-ssl.conf"
echo ""

print_success "Deployment completed successfully!"
print_info "Your Auto Garage System is now running on Hetzner!"
