#!/bin/bash

# Auto-configurazione DNS GoDaddy per n8n.waipro.it
# Script completamente automatico

set -e

SERVER_IP=$(curl -s ifconfig.me)

echo "=========================================="
echo "  AUTO-CONFIG DNS n8n.waipro.it"
echo "=========================================="
echo ""
echo "IP Server: $SERVER_IP"
echo ""

# Cerca credenziali GoDaddy in credentials.env
if [ -f "/root/WAPRO/CONFIG/credentials.env" ]; then
    source /root/WAPRO/CONFIG/credentials.env 2>/dev/null || true
fi

# Se non trovate, chiedi
if [ -z "$GODADDY_API_KEY" ] || [ -z "$GODADDY_API_SECRET" ]; then
    echo "⚠️  Credenziali GoDaddy non trovate in CONFIG/credentials.env"
    echo ""
    echo "Ottieni le credenziali API da: https://developer.godaddy.com/keys"
    echo ""
    read -p "GoDaddy API Key: " GODADDY_API_KEY
    read -p "GoDaddy API Secret: " GODADDY_API_SECRET

    # Salva in credentials.env
    echo "" >> /root/WAPRO/CONFIG/credentials.env
    echo "# GoDaddy DNS API" >> /root/WAPRO/CONFIG/credentials.env
    echo "GODADDY_API_KEY=$GODADDY_API_KEY" >> /root/WAPRO/CONFIG/credentials.env
    echo "GODADDY_API_SECRET=$GODADDY_API_SECRET" >> /root/WAPRO/CONFIG/credentials.env
    echo "✓ Credenziali salvate"
else
    echo "✓ Credenziali GoDaddy trovate"
fi

echo ""
echo "Configurazione DNS n8n.waipro.it → $SERVER_IP"
echo ""

DOMAIN="waipro.it"
SUBDOMAIN="n8n"

# Update A record via GoDaddy API
RESPONSE=$(curl -s -X PUT \
  "https://api.godaddy.com/v1/domains/${DOMAIN}/records/A/${SUBDOMAIN}" \
  -H "Authorization: sso-key ${GODADDY_API_KEY}:${GODADDY_API_SECRET}" \
  -H "Content-Type: application/json" \
  -d "[{\"data\": \"${SERVER_IP}\", \"ttl\": 600}]")

# Check response
if [ -z "$RESPONSE" ]; then
    echo "✓ DNS configurato con successo!"
    echo ""
    echo "Record creato/aggiornato:"
    echo "  Tipo: A"
    echo "  Nome: n8n.waipro.it"
    echo "  IP: $SERVER_IP"
    echo "  TTL: 600s (10 minuti)"
else
    echo "⚠️  Risposta API: $RESPONSE"
fi

echo ""
echo "Attendi 2-5 minuti per propagazione DNS..."
echo ""

# Wait and verify
echo "Verifico DNS tra 30 secondi..."
sleep 30

DNS_IP=$(dig +short n8n.waipro.it | head -1)

if [ "$DNS_IP" == "$SERVER_IP" ]; then
    echo "✓ DNS propagato correttamente!"
    echo "  n8n.waipro.it → $SERVER_IP"
else
    echo "⏳ DNS non ancora propagato"
    echo "  Atteso: $SERVER_IP"
    echo "  Attuale: $DNS_IP"
    echo ""
    echo "Riprova tra 5 minuti con:"
    echo "  dig +short n8n.waipro.it"
fi

echo ""
echo "=========================================="
echo ""
