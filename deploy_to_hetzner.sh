#!/bin/bash

# Auto Garage System - Hetzner CX23 Deployment Script
# Server: 178.105.209.59
# This script automates the entire deployment process

set -e  # Exit on error

echo "🚀 Auto Garage System - Hetzner CX23 Deployment"
echo "=========================================="
echo "Server: 178.105.209.59"
echo "Specs: 2 vCPU, 8GB RAM"
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

print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

# Step 1: Update System
print_step "Step 1: Updating system..."
apt update && apt upgrade -y
print_success "System updated"

# Step 2: Install Docker
print_step "Step 2: Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl enable docker
    print_success "Docker installed"
else
    print_success "Docker already installed"
fi

# Step 3: Install Docker Compose
print_step "Step 3: Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed"
else
    print_success "Docker Compose already installed"
fi

# Step 4: Install Additional Tools
print_step "Step 4: Installing additional tools..."
apt install -y git curl htop vim net-tools
print_success "Additional tools installed"

# Step 5: Configure Docker for Optimal Performance
print_step "Step 5: Optimizing Docker for 8GB RAM..."
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

# Step 6: Create Project Directory
print_step "Step 6: Creating project directory..."
mkdir -p /var/www/auto-garage
cd /var/www/auto-garage
print_success "Project directory created"

# Step 7: Clone Project
print_step "Step 7: Cloning project from GitHub..."
if [ -d ".git" ]; then
    print_success "Project already exists, pulling latest changes..."
    git pull
else
    git clone https://github.com/karam-55/auto-garage-system.git .
    print_success "Project cloned from GitHub"
fi

# Step 8: Check Frontend Build
print_step "Step 8: Checking frontend build..."
if [ -d "admin_frontend/build/web" ]; then
    print_success "Frontend already built"
else
    print_warning "Frontend not found. Please build on local machine and upload:"
    print_info "1. On local machine: cd admin_frontend && flutter build web"
    print_info "2. Upload admin_frontend/build/web to: /var/www/auto-garage/admin_frontend/"
    print_info "3. Then run this script again"
    exit 1
fi

# Step 9: Generate Secrets
print_step "Step 9: Generating secrets..."
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

# Step 10: Create Required Directories
print_step "Step 10: Creating required directories..."
mkdir -p certbot/conf certbot/www
mkdir -p migrations
print_success "Directories created"

# Step 11: Update docker-compose.yml with secrets
print_step "Step 11: Updating docker-compose.yml with secrets..."
if [ -f ".env" ]; then
    source .env
    sed -i "s/garage123/$POSTGRES_PASSWORD/g" docker-compose.yml
    sed -i "s/7f82670b53bd936d32f73af55c021a82/$JWT_SECRET/g" docker-compose.yml
    sed -i "s/673d0b0d0fc538ae34a3d177f682d2ac/$JWT_REFRESH_SECRET/g" docker-compose.yml
    print_success "docker-compose.yml updated with secrets"
fi

# Step 12: Start PostgreSQL
print_step "Step 12: Starting PostgreSQL..."
docker-compose down
docker-compose up -d postgres
print_success "PostgreSQL started"

# Wait for PostgreSQL
print_info "Waiting for PostgreSQL to be ready..."
sleep 15

# Step 13: Run Migrations
print_step "Step 13: Running database migrations..."
if [ -f "migrations/2026-05-24_add_acquisition_date_to_fixed_assets.sql" ]; then
    docker-compose exec -T postgres psql -U garage -d garage_db < migrations/2026-05-24_add_acquisition_date_to_fixed_assets.sql
    print_success "Migration 1 executed"
fi

if [ -f "migrations/2026-05-24_seed_chart_of_accounts.sql" ]; then
    docker-compose exec -T postgres psql -U garage -d garage_db < migrations/2026-05-24_seed_chart_of_accounts.sql
    print_success "Migration 2 executed"
fi

# Step 14: Start All Services
print_step "Step 14: Starting all services..."
docker-compose up -d
print_success "All services started"

# Step 15: Configure Firewall
print_step "Step 15: Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    print_success "Firewall configured"
else
    print_warning "UFW not found, skipping firewall configuration"
fi

# Step 16: Display Status
echo ""
echo "📊 Deployment Status:"
echo "===================="
docker-compose ps
echo ""

# Step 17: Display Access Information
echo "🌐 Access Information:"
echo "====================="
echo "Backend API: http://178.105.209.59:8080"
echo "Frontend: http://178.105.209.59"
echo "Database: postgres://garage:PASSWORD@localhost:5432/garage_db"
echo ""
echo "🔑 Default Credentials:"
echo "Username: admin"
echo "Password: admin123"
echo ""

# Step 18: Display Resource Usage
echo "💾 Resource Usage:"
echo "================"
free -h
df -h
echo ""

# Step 19: Final Instructions
echo "📋 Next Steps:"
echo "============"
echo "1. Test the deployment by accessing: http://178.105.209.59"
echo "2. Login with: admin / admin123"
echo "3. Monitor logs: docker-compose logs -f"
echo "4. Monitor resources: htop"
echo "5. View this guide: cat HETZNER_DEPLOYMENT.md"
echo "6. If you have a domain later, setup SSL using nginx-ssl.conf"
echo ""

print_success "Deployment completed successfully!"
print_info "Your Auto Garage System is now running on Hetzner CX23!"
