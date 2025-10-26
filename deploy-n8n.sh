#!/bin/bash

set -e

echo "=================================================="
echo "  Deploying n8n to n8n.waipro.it"
echo "=================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root (sudo)${NC}"
  exit 1
fi

# Check prerequisites
echo "Checking prerequisites..."

# Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker not installed. Installing...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    echo -e "${GREEN}✓ Docker installed${NC}"
else
    echo -e "${GREEN}✓ Docker found${NC}"
fi

# Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}Docker Compose not found. Installing...${NC}"
    curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✓ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✓ Docker Compose found${NC}"
fi

echo ""
echo "=================================================="
echo "  DNS Configuration"
echo "=================================================="
echo ""

echo -e "${YELLOW}IMPORTANT: Before continuing, ensure:${NC}"
echo "1. DNS A record for n8n.waipro.it points to this server's IP"
echo "2. Port 80 and 443 are open in firewall"
echo ""

read -p "Have you configured DNS? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Please configure DNS first:${NC}"
    echo "  A Record: n8n.waipro.it → $(curl -s ifconfig.me)"
    exit 1
fi

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)
echo -e "${GREEN}Server IP: $SERVER_IP${NC}"

# Verify DNS
echo "Verifying DNS..."
DNS_IP=$(dig +short n8n.waipro.it | head -1)

if [ "$DNS_IP" == "$SERVER_IP" ]; then
    echo -e "${GREEN}✓ DNS configured correctly${NC}"
else
    echo -e "${YELLOW}⚠ DNS may not be propagated yet${NC}"
    echo "  Expected: $SERVER_IP"
    echo "  Got: $DNS_IP"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "=================================================="
echo "  Setup Directory Structure"
echo "=================================================="
echo ""

cd /root/WAPRO

# Create directories
mkdir -p ssl
mkdir -p n8n-workflows

echo -e "${GREEN}✓ Directories created${NC}"

echo ""
echo "=================================================="
echo "  Generate Encryption Key"
echo "=================================================="
echo ""

# Generate encryption key
ENCRYPTION_KEY=$(openssl rand -base64 32)
echo "Encryption key generated: $ENCRYPTION_KEY"

# Update docker-compose.yml with encryption key
sed -i "s/YOUR_ENCRYPTION_KEY_HERE/$ENCRYPTION_KEY/g" docker-compose.yml

echo -e "${GREEN}✓ Encryption key configured${NC}"

echo ""
echo "=================================================="
echo "  Starting n8n (HTTP only first)"
echo "=================================================="
echo ""

# Start n8n only (without nginx/certbot first)
docker-compose up -d n8n

echo -e "${GREEN}✓ n8n started${NC}"
echo "Waiting for n8n to be ready..."
sleep 10

# Check if n8n is running
if docker ps | grep -q n8n_waipro; then
    echo -e "${GREEN}✓ n8n is running${NC}"
else
    echo -e "${RED}✗ n8n failed to start${NC}"
    docker-compose logs n8n
    exit 1
fi

echo ""
echo "=================================================="
echo "  Obtaining SSL Certificate"
echo "=================================================="
echo ""

# Start nginx temporarily for certbot
docker-compose up -d nginx

# Run certbot
echo "Running certbot to obtain SSL certificate..."
docker-compose up certbot

# Check if certificate was obtained
if [ -d "/var/lib/docker/volumes/waipro_certbot_conf/_data/live/n8n.waipro.it" ]; then
    echo -e "${GREEN}✓ SSL certificate obtained${NC}"
else
    echo -e "${RED}✗ Failed to obtain SSL certificate${NC}"
    echo "You can try manual setup later with:"
    echo "  docker-compose run certbot certonly --webroot --webroot-path=/var/www/certbot --email admin@waipro.it --agree-tos -d n8n.waipro.it"
    exit 1
fi

echo ""
echo "=================================================="
echo "  Restarting Services with SSL"
echo "=================================================="
echo ""

# Restart all services
docker-compose down
docker-compose up -d

echo -e "${GREEN}✓ All services started${NC}"

# Wait for services
sleep 5

echo ""
echo "=================================================="
echo "  Verifying Deployment"
echo "=================================================="
echo ""

# Check docker containers
echo "Running containers:"
docker-compose ps

# Test HTTPS
echo ""
echo "Testing HTTPS connection..."
if curl -k -s -o /dev/null -w "%{http_code}" https://n8n.waipro.it | grep -q "200\|401"; then
    echo -e "${GREEN}✓ HTTPS working${NC}"
else
    echo -e "${YELLOW}⚠ HTTPS may not be ready yet${NC}"
fi

echo ""
echo "=================================================="
echo "  🎉 DEPLOYMENT COMPLETE!"
echo "=================================================="
echo ""
echo -e "${GREEN}n8n is now running at:${NC}"
echo "  https://n8n.waipro.it"
echo ""
echo -e "${GREEN}Credentials:${NC}"
echo "  Username: admin"
echo "  Password: Benessere84++"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Login to n8n at https://n8n.waipro.it"
echo "2. Import workflows from /root/WAPRO/n8n-workflows/"
echo "3. Configure credentials (Supabase, OpenAI, etc.)"
echo "4. Test workflows"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "  View logs:        docker-compose logs -f n8n"
echo "  Restart:          docker-compose restart"
echo "  Stop:             docker-compose down"
echo "  Update:           docker-compose pull && docker-compose up -d"
echo ""
echo -e "${YELLOW}SSL Certificate Renewal:${NC}"
echo "  Certificates auto-renew, or run manually:"
echo "  docker-compose run certbot renew"
echo ""
