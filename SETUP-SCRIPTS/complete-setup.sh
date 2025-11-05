#!/bin/bash

# ============================================
# WAIPRO MULTI-TENANT SETUP SCRIPT
# ============================================
# Complete setup for WhatsApp Multi-tenant system
# with Base44, n8n, Auth0, and OpenWeb UI
# ============================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 is not installed"
        return 1
    else
        print_success "$1 is installed"
        return 0
    fi
}

# ============================================
# STEP 1: Check Prerequisites
# ============================================
print_header "STEP 1: Checking Prerequisites"

print_info "Checking required software..."

MISSING_DEPS=0

if ! check_command "docker"; then
    print_warning "Docker will be installed"
    MISSING_DEPS=1
fi

if ! check_command "docker-compose"; then
    print_warning "Docker Compose will be installed"
    MISSING_DEPS=1
fi

if ! check_command "node"; then
    print_warning "Node.js will be installed"
    MISSING_DEPS=1
fi

if ! check_command "git"; then
    print_error "Git is required but not installed"
    exit 1
fi

check_command "curl" || MISSING_DEPS=1
check_command "jq" || MISSING_DEPS=1

if [ $MISSING_DEPS -eq 1 ]; then
    print_warning "Some dependencies are missing. Install them? (y/n)"
    read -r response
    if [[ "$response" == "y" ]]; then
        print_info "Installing dependencies..."

        # Detect OS
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            sudo apt update
            sudo apt install -y curl jq

            # Install Docker
            if ! command -v docker &> /dev/null; then
                curl -fsSL https://get.docker.com -o get-docker.sh
                sh get-docker.sh
                sudo usermod -aG docker $USER
                print_success "Docker installed"
            fi

            # Install Docker Compose
            if ! command -v docker-compose &> /dev/null; then
                sudo apt install -y docker-compose
                print_success "Docker Compose installed"
            fi

            # Install Node.js
            if ! command -v node &> /dev/null; then
                curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
                sudo apt install -y nodejs
                print_success "Node.js installed"
            fi

        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if ! command -v brew &> /dev/null; then
                print_error "Homebrew is required on macOS. Install from https://brew.sh"
                exit 1
            fi

            brew install docker docker-compose node jq curl
            print_success "Dependencies installed via Homebrew"
        else
            print_error "Unsupported OS: $OSTYPE"
            exit 1
        fi
    else
        print_error "Cannot continue without required dependencies"
        exit 1
    fi
fi

print_success "All prerequisites satisfied!"

# ============================================
# STEP 2: Project Directory Setup
# ============================================
print_header "STEP 2: Project Directory Setup"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

print_info "Project root: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

# Check if .env exists
if [ -f "CONFIG/.env" ]; then
    print_warning ".env file already exists"
    print_info "Do you want to:"
    echo "  1) Keep existing .env"
    echo "  2) Backup and create new .env"
    echo "  3) Exit"
    read -p "Choice (1-3): " env_choice

    case $env_choice in
        1)
            print_info "Keeping existing .env"
            ;;
        2)
            BACKUP_NAME="CONFIG/.env.backup.$(date +%Y%m%d_%H%M%S)"
            mv CONFIG/.env "$BACKUP_NAME"
            print_success "Backed up to $BACKUP_NAME"
            cp CONFIG/.env.example CONFIG/.env
            print_success "Created new .env from template"
            ;;
        3)
            print_info "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
else
    cp CONFIG/.env.example CONFIG/.env
    print_success "Created CONFIG/.env from template"
fi

# ============================================
# STEP 3: WhatsApp Configuration
# ============================================
print_header "STEP 3: WhatsApp Configuration"

print_info "Configure WhatsApp Business API tokens"
echo ""
echo "You need to get tokens from Meta Business Manager:"
echo "1. Go to https://business.facebook.com"
echo "2. Select your Business Account"
echo "3. Go to WhatsApp > API Setup"
echo "4. Generate Permanent Token for each phone number"
echo ""

configure_whatsapp() {
    local TENANT_NAME=$1
    local TOKEN_VAR=$2
    local PHONE_VAR=$3
    local BUSINESS_VAR=$4

    print_info "Configuring $TENANT_NAME..."

    read -p "WhatsApp Token: " token
    read -p "Phone Number ID: " phone
    read -p "Business Account ID: " business

    # Update .env
    sed -i.bak "s|${TOKEN_VAR}=.*|${TOKEN_VAR}=${token}|g" CONFIG/.env
    sed -i.bak "s|${PHONE_VAR}=.*|${PHONE_VAR}=${phone}|g" CONFIG/.env
    sed -i.bak "s|${BUSINESS_VAR}=.*|${BUSINESS_VAR}=${business}|g" CONFIG/.env

    print_success "$TENANT_NAME configured"
}

print_info "Do you want to configure WhatsApp now? (y/n)"
read -r response
if [[ "$response" == "y" ]]; then
    configure_whatsapp "Mister Phone TEC" "WHATSAPP_TOKEN_MISTERPHONE" "WHATSAPP_PHONE_MISTERPHONE" "WHATSAPP_BUSINESS_ID_MISTERPHONE"
    echo ""
    configure_whatsapp "Ripara Subito TEC" "WHATSAPP_TOKEN_RIPARASUBITO" "WHATSAPP_PHONE_RIPARASUBITO" "WHATSAPP_BUSINESS_ID_RIPARASUBITO"
else
    print_warning "You can configure WhatsApp tokens later by editing CONFIG/.env"
fi

# ============================================
# STEP 4: Base44 Configuration
# ============================================
print_header "STEP 4: Base44 Configuration"

print_info "Configure Base44 API and Agent IDs"
echo ""
print_info "Do you want to configure Base44 now? (y/n)"
read -r response
if [[ "$response" == "y" ]]; then
    read -p "Base44 API Key: " base44_api
    read -p "Base44 Account ID: " base44_account
    read -p "Agent ID (Mister Phone): " agent_mp
    read -p "Agent ID (Ripara Subito): " agent_rs

    sed -i.bak "s|BASE44_API_KEY=.*|BASE44_API_KEY=${base44_api}|g" CONFIG/.env
    sed -i.bak "s|BASE44_ACCOUNT_ID=.*|BASE44_ACCOUNT_ID=${base44_account}|g" CONFIG/.env
    sed -i.bak "s|BASE44_AGENT_MISTERPHONE=.*|BASE44_AGENT_MISTERPHONE=${agent_mp}|g" CONFIG/.env
    sed -i.bak "s|BASE44_AGENT_RIPARASUBITO=.*|BASE44_AGENT_RIPARASUBITO=${agent_rs}|g" CONFIG/.env

    print_success "Base44 configured"
else
    print_warning "You can configure Base44 later by editing CONFIG/.env"
fi

# ============================================
# STEP 5: Generate Secrets
# ============================================
print_header "STEP 5: Generating Secrets"

print_info "Generating secure encryption keys..."

# Generate N8N encryption key
N8N_KEY=$(openssl rand -base64 32)
sed -i.bak "s|N8N_ENCRYPTION_KEY=.*|N8N_ENCRYPTION_KEY=${N8N_KEY}|g" CONFIG/.env
print_success "N8N encryption key generated"

# Generate JWT secret
JWT_SECRET=$(openssl rand -base64 64)
sed -i.bak "s|JWT_SECRET=.*|JWT_SECRET=${JWT_SECRET}|g" CONFIG/.env
print_success "JWT secret generated"

# Clean up backup files
rm -f CONFIG/.env.bak

# ============================================
# STEP 6: Docker Setup
# ============================================
print_header "STEP 6: Docker Setup"

print_info "Do you want to start n8n with Docker now? (y/n)"
read -r response
if [[ "$response" == "y" ]]; then
    print_info "Starting Docker containers..."

    # Load .env for docker-compose
    set -a
    source CONFIG/.env
    set +a

    # Start containers
    docker-compose up -d

    print_success "Docker containers started"

    # Wait for n8n to be ready
    print_info "Waiting for n8n to start..."
    sleep 10

    # Check if n8n is running
    if docker ps | grep -q "n8n_waipro"; then
        print_success "n8n is running!"
        print_info "Access n8n at: https://n8n.waipro.it"
        print_info "Username: admin"
        print_info "Password: (check CONFIG/.env)"
    else
        print_error "n8n failed to start. Check logs with: docker-compose logs n8n"
    fi
else
    print_warning "You can start Docker later with: docker-compose up -d"
fi

# ============================================
# STEP 7: Import n8n Workflows
# ============================================
print_header "STEP 7: Import n8n Workflows"

print_info "Available workflows to import:"
echo "  1. WhatsApp Multi-Tenant Orchestrator"
echo "  2. Base44 AI Agent Workflow"
echo "  3. RAG Auto-Update"
echo "  4. Social Media Automation"
echo "  5. All workflows"
echo ""

print_info "Import workflows now? (y/n)"
read -r response
if [[ "$response" == "y" ]]; then
    print_info "Workflows are in: n8n-workflows/"
    print_info "Import them via n8n UI:"
    echo "  1. Go to https://n8n.waipro.it"
    echo "  2. Click 'Workflows' > 'Import from File'"
    echo "  3. Select JSON files from n8n-workflows/"
    echo ""
    print_warning "Remember to activate workflows after importing!"
else
    print_info "You can import workflows later from n8n UI"
fi

# ============================================
# STEP 8: Telegram Notifications Setup
# ============================================
print_header "STEP 8: Telegram Notifications (Optional)"

print_info "Do you want to configure Telegram notifications? (y/n)"
read -r response
if [[ "$response" == "y" ]]; then
    echo ""
    echo "To get Telegram Bot Token:"
    echo "  1. Open Telegram and search for @BotFather"
    echo "  2. Send /newbot and follow instructions"
    echo "  3. Copy the token provided"
    echo ""
    read -p "Telegram Bot Token: " tg_token

    echo ""
    echo "To get Chat ID:"
    echo "  1. Add your bot to a group or send it a message"
    echo "  2. Visit: https://api.telegram.org/bot${tg_token}/getUpdates"
    echo "  3. Look for 'chat':{'id': YOUR_CHAT_ID}"
    echo ""
    read -p "Telegram Chat ID: " tg_chat

    sed -i "s|TELEGRAM_BOT_TOKEN=.*|TELEGRAM_BOT_TOKEN=${tg_token}|g" CONFIG/.env
    sed -i "s|TELEGRAM_OPERATOR_CHAT_ID=.*|TELEGRAM_OPERATOR_CHAT_ID=${tg_chat}|g" CONFIG/.env

    print_success "Telegram configured"
else
    print_info "Skipping Telegram setup"
fi

# ============================================
# STEP 9: Verify Configuration
# ============================================
print_header "STEP 9: Configuration Verification"

print_info "Verifying configuration..."

ISSUES=0

# Check required variables
check_env_var() {
    local VAR_NAME=$1
    local VAR_VALUE=$(grep "^${VAR_NAME}=" CONFIG/.env | cut -d '=' -f 2)

    if [[ -z "$VAR_VALUE" || "$VAR_VALUE" == *"xxxx"* || "$VAR_VALUE" == *"yyyy"* ]]; then
        print_warning "$VAR_NAME is not configured"
        ((ISSUES++))
        return 1
    else
        print_success "$VAR_NAME is configured"
        return 0
    fi
}

echo ""
print_info "Critical configuration:"
check_env_var "WHATSAPP_TOKEN_MISTERPHONE"
check_env_var "WHATSAPP_TOKEN_RIPARASUBITO"
check_env_var "BASE44_API_KEY"
check_env_var "N8N_ENCRYPTION_KEY"

echo ""
if [ $ISSUES -eq 0 ]; then
    print_success "All critical settings configured!"
else
    print_warning "Found $ISSUES unconfigured settings"
    print_info "Edit CONFIG/.env to complete configuration"
fi

# ============================================
# STEP 10: Next Steps
# ============================================
print_header "🎉 Setup Complete!"

echo ""
print_success "Your Waipro Multi-Tenant system is ready!"
echo ""
print_info "Next steps:"
echo ""
echo "1. 📝 Review and complete CONFIG/.env configuration"
echo "   vim CONFIG/.env"
echo ""
echo "2. 🚀 Start services (if not already started):"
echo "   docker-compose up -d"
echo ""
echo "3. 🌐 Access n8n:"
echo "   https://n8n.waipro.it"
echo "   User: admin"
echo "   Pass: (see CONFIG/.env)"
echo ""
echo "4. 📥 Import workflows:"
echo "   - Go to n8n UI > Workflows > Import from File"
echo "   - Import from: n8n-workflows/"
echo "   - Activate each workflow"
echo ""
echo "5. 🔗 Configure WhatsApp Webhooks:"
echo "   - Meta Business Manager > WhatsApp > Configuration"
echo "   - Webhook URL: https://n8n.waipro.it/webhook/whatsapp-webhook"
echo "   - Subscribe to: messages, message_status"
echo ""
echo "6. 🧪 Test the system:"
echo "   - Send a WhatsApp message to your business number"
echo "   - Check n8n executions for processing"
echo "   - Verify AI response is sent back"
echo ""
echo "7. 📊 Setup monitoring:"
echo "   - Telegram notifications (if configured)"
echo "   - n8n execution history"
echo "   - Docker logs: docker-compose logs -f"
echo ""
echo "8. 📚 Read documentation:"
echo "   - DOCS/WAIPRO-OPERATIONAL-PLAN.md"
echo "   - DOCS/MASTER-GUIDE-BASE44-N8N-MCP.md"
echo ""
print_info "Need help? Check: https://github.com/Waipro-agency/waipro-knowledge-base"
echo ""
print_success "Happy automating! 🚀"
echo ""

# Create setup completion marker
touch .setup_completed
echo "$(date)" > .setup_completed

# Save setup log
SETUP_LOG="setup-log-$(date +%Y%m%d_%H%M%S).txt"
echo "Setup completed at $(date)" > "$SETUP_LOG"
print_success "Setup log saved to: $SETUP_LOG"

exit 0
