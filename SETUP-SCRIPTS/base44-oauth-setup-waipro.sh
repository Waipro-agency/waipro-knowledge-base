#!/bin/bash

# ============================================
# WAIPRO BASE44 SOCIAL LOGIN - SETUP SCRIPT
# ============================================
# Creato: 27 Ottobre 2025
# Account Base44: adrian@waipro.it
# Password: Benessere84++

set -e

echo "🚀 WAIPRO BASE44 SOCIAL LOGIN SETUP"
echo "===================================="
echo ""

# Colori per output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Verifica credenziali Base44
echo -e "${BLUE}📋 Step 1: Verifico accesso Base44${NC}"
echo "Account: adrian@waipro.it"
echo "Password: Benessere84++"
echo ""

# Variabili configurazione
BASE44_EMAIL="adrian@waipro.it"
BASE44_PASSWORD="Benessere84++"
WAIPRO_DOMAIN="waipro.it"
SUPPORT_EMAIL="support@waipro.it"
DEV_EMAIL="dev@w-adv.it"

echo -e "${YELLOW}⚠️  AZIONI MANUALI RICHIESTE:${NC}"
echo ""
echo "1️⃣  Accedi a Base44:"
echo "   URL: https://app.base44.com/login"
echo "   Email: ${BASE44_EMAIL}"
echo "   Password: ${BASE44_PASSWORD}"
echo ""
read -p "✅ Hai effettuato il login? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Login Base44 richiesto!${NC}"
    exit 1
fi

# Step 2: Recupera APP ID
echo ""
echo -e "${BLUE}📋 Step 2: Recupero APP ID${NC}"
echo ""
echo "Vai all'editor della tua app Base44"
echo "Guarda l'URL: https://app.base44.com/apps/[APP_ID]/editor/"
echo ""
read -p "Inserisci l'APP ID: " APP_ID

if [ -z "$APP_ID" ]; then
    echo -e "${RED}❌ APP ID richiesto!${NC}"
    exit 1
fi

# Costruisci Redirect URI
REDIRECT_URI="https://app.base44.com/api/apps/${APP_ID}/auth/sso/callback"

echo ""
echo -e "${GREEN}✅ Redirect URI generato:${NC}"
echo "   ${REDIRECT_URI}"
echo ""
echo "📋 COPIA QUESTO URI - Lo userai nei prossimi step!"
echo ""

# Salva configurazione
CONFIG_FILE="/root/WAPRO/CONFIG/base44-oauth-config.env"
mkdir -p /root/WAPRO/CONFIG

cat > "$CONFIG_FILE" << EOF
# Base44 OAuth Configuration - Waipro
# Generato: $(date)

BASE44_EMAIL="${BASE44_EMAIL}"
BASE44_APP_ID="${APP_ID}"
REDIRECT_URI="${REDIRECT_URI}"
WAIPRO_DOMAIN="${WAIPRO_DOMAIN}"
SUPPORT_EMAIL="${SUPPORT_EMAIL}"
DEV_EMAIL="${DEV_EMAIL}"

# Google OAuth (da compilare dopo setup Google Cloud)
GOOGLE_CLIENT_ID=""
GOOGLE_CLIENT_SECRET=""

# Microsoft Azure (opzionale)
AZURE_CLIENT_ID=""
AZURE_CLIENT_SECRET=""
AZURE_DISCOVERY_URL=""

# GitHub (opzionale)
GITHUB_CLIENT_ID=""
GITHUB_CLIENT_SECRET=""
EOF

echo -e "${GREEN}✅ Configurazione salvata in: ${CONFIG_FILE}${NC}"
echo ""

# Step 3: Setup Google Cloud
echo -e "${BLUE}📋 Step 3: Setup Google Cloud OAuth${NC}"
echo ""
echo "🌐 Apri Google Cloud Console:"
echo "   URL: https://console.cloud.google.com/"
echo ""
echo "ISTRUZIONI:"
echo "1. Clicca 'Select a project' → 'New Project'"
echo "2. Nome: 'Waipro - Main OAuth'"
echo "3. Clicca 'Create'"
echo ""
read -p "✅ Progetto creato? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Crea prima il progetto Google!${NC}"
    exit 1
fi

echo ""
echo "4. Vai a: APIs & Services → Credentials"
echo "5. Clicca '+ CREATE CREDENTIALS' → 'OAuth client ID'"
echo ""
echo "6. Se richiesto, configura OAuth consent screen:"
echo "   - User Type: External"
echo "   - App name: Waipro Platform"
echo "   - User support email: ${SUPPORT_EMAIL}"
echo "   - Developer contact: ${DEV_EMAIL}"
echo "   - Logo: (opzionale ora, aggiungi dopo)"
echo ""
read -p "✅ OAuth consent screen configurato? (y/n) " -n 1 -r
echo ""

echo ""
echo "7. Aggiungi Scopes:"
echo "   ✅ openid"
echo "   ✅ https://www.googleapis.com/auth/userinfo.email"
echo "   ✅ https://www.googleapis.com/auth/userinfo.profile"
echo ""
read -p "✅ Scopes aggiunti? (y/n) " -n 1 -r
echo ""

echo ""
echo "8. Crea OAuth Client ID:"
echo "   - Application type: Web application"
echo "   - Name: Waipro - Base44 OAuth"
echo "   - Authorized redirect URIs: ${REDIRECT_URI}"
echo ""
read -p "✅ OAuth Client ID creato? (y/n) " -n 1 -r
echo ""

echo ""
echo "9. Copia le credenziali:"
echo ""
read -p "Inserisci Google Client ID: " GOOGLE_CLIENT_ID
read -p "Inserisci Google Client Secret: " GOOGLE_CLIENT_SECRET

if [ -z "$GOOGLE_CLIENT_ID" ] || [ -z "$GOOGLE_CLIENT_SECRET" ]; then
    echo -e "${RED}❌ Credenziali Google richieste!${NC}"
    exit 1
fi

# Aggiorna configurazione
sed -i "s/GOOGLE_CLIENT_ID=\"\"/GOOGLE_CLIENT_ID=\"${GOOGLE_CLIENT_ID}\"/" "$CONFIG_FILE"
sed -i "s/GOOGLE_CLIENT_SECRET=\"\"/GOOGLE_CLIENT_SECRET=\"${GOOGLE_CLIENT_SECRET}\"/" "$CONFIG_FILE"

echo ""
echo -e "${GREEN}✅ Credenziali Google salvate!${NC}"
echo ""

# Step 4: Configurazione Base44
echo -e "${BLUE}📋 Step 4: Configurazione in Base44${NC}"
echo ""
echo "1. Torna su Base44: https://app.base44.com/"
echo "2. Apri il Dashboard della tua app"
echo "3. Vai a: Settings → Authentication → Single sign-on (SSO)"
echo "4. Seleziona 'Google' come provider"
echo "5. Inserisci:"
echo "   - Client ID: ${GOOGLE_CLIENT_ID}"
echo "   - Client Secret: ${GOOGLE_CLIENT_SECRET}"
echo "6. Clicca 'Save'"
echo ""
read -p "✅ Configurazione Base44 completata? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Completa la configurazione Base44!${NC}"
    exit 1
fi

# Step 5: Test
echo ""
echo -e "${BLUE}📋 Step 5: Test Social Login${NC}"
echo ""
echo "1. Fai LOGOUT da Base44"
echo "2. Vai alla pagina di login dell'app"
echo "3. Clicca 'Log in with Google'"
echo "4. Autorizza con un account Google"
echo ""
read -p "✅ Login funziona? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${GREEN}🎉 SUCCESS! Social Login configurato!${NC}"
    echo ""
    echo "📋 Prossimi Step:"
    echo "   1. Pubblica app su Base44"
    echo "   2. Sottometti progetto Google per approvazione"
    echo "   3. Configura dominio custom (opzionale)"
    echo "   4. Personalizza branding"
    echo ""
    echo "📄 Configurazione salvata in:"
    echo "   ${CONFIG_FILE}"
    echo ""
    echo "🔥 PRONTO PER I CLIENTI! 🔥"
else
    echo ""
    echo -e "${YELLOW}⚠️  Troubleshooting:${NC}"
    echo "   - Verifica Redirect URI esatto"
    echo "   - Controlla Client ID/Secret (no spazi)"
    echo "   - Verifica scopes in Google Console"
    echo ""
    echo "📄 Configurazione in: ${CONFIG_FILE}"
    echo "🔧 Riprova o contatta support"
fi

echo ""
echo "============================================"
echo "Setup completato!"
echo "Timestamp: $(date)"
echo "============================================"
