#!/bin/bash

# Auto Garage System - Hetzner Deployment Script
# This script automates the deployment process

set -e  # Exit on error

echo "🚀 Auto Garage System - Hetzner Deployment"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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
apt install -y git curl nginx certbot python3-certbot-nginx htop
print_success "Additional tools installed"

# Step 5: Create Project Directory
echo "📁 Step 5: Creating project directory..."
mkdir -p /var/www/auto-garage
cd /var/www/auto-garage
print_success "Project directory created"

# Step 6: Clone or Copy Project
echo "📥 Step 6: Setting up project files..."
if [ -d ".git" ]; then
    print_success "Project already exists, pulling latest changes..."
    git pull
else
    if [ -z "$GIT_REPO_URL" ]; then
        print_warning "GIT_REPO_URL not set, skipping clone"
        print_warning "Please manually copy project files to /var/www/auto-garage"
    else
        git clone $GIT_REPO_URL .
        print_success "Project cloned from GitHub"
    fi
fi

# Step 7: Build Frontend
echo "🎨 Step 7: Building frontend..."
if [ -d "admin_frontend" ]; then
    cd admin_frontend
    if command -v flutter &> /dev/null; then
        flutter pub get
        flutter build web
        print_success "Frontend built successfully"
    else
        print_warning "Flutter not found, skipping frontend build"
        print_warning "Please build frontend manually or install Flutter"
    fi
    cd /var/www/auto-garage
else
    print_warning "admin_frontend directory not found"
fi

# Step 8: Generate Secrets
echo "🔐 Step 8: Generating secrets..."
if [ ! -f ".env" ]; then
    cat > .env << EOF
POSTGRES_PASSWORD=$(openssl rand -hex 16)
JWT_SECRET=$(openssl rand -hex 32)
JWT_REFRESH_SECRET=$(openssl rand -hex 32)
EOF
    print_success "Secrets generated and saved to .env"
else
    print_success "Secrets already exist"
fi

# Step 9: Create Required Directories
echo "📂 Step 9: Creating required directories..."
mkdir -p certbot/conf certbot/www
mkdir -p migrations
print_success "Directories created"

# Step 10: Start Services
echo "🚀 Step 10: Starting services..."
docker-compose down
docker-compose up -d postgres
print_success "PostgreSQL started"

# Wait for PostgreSQL
echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 15

# Step 11: Run Migrations
echo "🗄️ Step 11: Running database migrations..."
if [ -f "migrations/2026-05-24_add_acquisition_date_to_fixed_assets.sql" ]; then
    docker-compose exec -T postgres psql -U garage -d garage_db < migrations/2026-05-24_add_acquisition_date_to_fixed_assets.sql
    print_success "Migration 1 executed"
fi

if [ -f "migrations/2026-05-24_seed_chart_of_accounts.sql" ]; then
    docker-compose exec -T postgres psql -U garage -d garage_db < migrations/2026-05-24_seed_chart_of_accounts.sql
    print_success "Migration 2 executed"
fi

# Step 12: Start All Services
echo "🎯 Step 12: Starting all services..."
docker-compose up -d
print_success "All services started"

# Step 13: Configure Firewall
echo "🔒 Step 13: Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    print_success "Firewall configured"
else
    print_warning "UFW not found, skipping firewall configuration"
fi

# Step 14: Display Status
echo ""
echo "📊 Deployment Status:"
echo "===================="
docker-compose ps
echo ""

# Step 15: Display Access Information
echo "🌐 Access Information:"
echo "====================="
echo "Backend API: http://$(curl -s ifconfig.me):8080"
echo "Frontend: http://$(curl -s ifconfig.me)"
echo "Database: postgres://garage:PASSWORD@localhost:5432/garage_db"
echo ""
echo "🔑 Default Credentials:"
echo "Username: admin"
echo "Password: admin123"
echo ""

# Step 16: Final Instructions
echo "📋 Next Steps:"
echo "============"
echo "1. Test the deployment by accessing the URLs above"
echo "2. If you have a domain, update nginx-ssl.conf and setup SSL"
echo "3. Monitor logs: docker-compose logs -f"
echo "4. View this guide: cat HETZNER_DEPLOYMENT.md"
echo ""

print_success "Deployment completed successfully!"
