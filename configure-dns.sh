#!/bin/bash

# Script per configurare DNS n8n.waipro.it
# Supporta GoDaddy API e altri provider

SERVER_IP=$(curl -s ifconfig.me)

echo "=========================================="
echo "  DNS Configuration per n8n.waipro.it"
echo "=========================================="
echo ""
echo "IP Server: $SERVER_IP"
echo ""

# Funzione per GoDaddy API
configure_godaddy() {
    echo "Configurazione GoDaddy DNS via API..."

    read -p "GoDaddy API Key: " GODADDY_API_KEY
    read -p "GoDaddy API Secret: " GODADDY_API_SECRET

    DOMAIN="waipro.it"
    SUBDOMAIN="n8n"

    # Update A record
    curl -X PUT "https://api.godaddy.com/v1/domains/${DOMAIN}/records/A/${SUBDOMAIN}" \
      -H "Authorization: sso-key ${GODADDY_API_KEY}:${GODADDY_API_SECRET}" \
      -H "Content-Type: application/json" \
      -d "[{\"data\": \"${SERVER_IP}\", \"ttl\": 600}]"

    echo ""
    echo "✓ DNS configurato via GoDaddy API"
}

# Funzione per Cloudflare API
configure_cloudflare() {
    echo "Configurazione Cloudflare DNS via API..."

    read -p "Cloudflare API Token: " CF_API_TOKEN
    read -p "Cloudflare Zone ID: " CF_ZONE_ID

    # Get existing record ID
    RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records?name=n8n.waipro.it" \
      -H "Authorization: Bearer ${CF_API_TOKEN}" \
      -H "Content-Type: application/json" | jq -r '.result[0].id')

    if [ "$RECORD_ID" != "null" ] && [ -n "$RECORD_ID" ]; then
        # Update existing
        curl -X PUT "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records/${RECORD_ID}" \
          -H "Authorization: Bearer ${CF_API_TOKEN}" \
          -H "Content-Type: application/json" \
          -d "{\"type\":\"A\",\"name\":\"n8n\",\"content\":\"${SERVER_IP}\",\"ttl\":1,\"proxied\":false}"
    else
        # Create new
        curl -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records" \
          -H "Authorization: Bearer ${CF_API_TOKEN}" \
          -H "Content-Type: application/json" \
          -d "{\"type\":\"A\",\"name\":\"n8n\",\"content\":\"${SERVER_IP}\",\"ttl\":1,\"proxied\":false}"
    fi

    echo ""
    echo "✓ DNS configurato via Cloudflare API"
}

# Menu
echo "Seleziona provider DNS:"
echo "1) GoDaddy"
echo "2) Cloudflare"
echo "3) Manuale (mostra istruzioni)"
echo ""
read -p "Scelta (1-3): " choice

case $choice in
    1)
        configure_godaddy
        ;;
    2)
        configure_cloudflare
        ;;
    3)
        echo ""
        echo "=========================================="
        echo "  CONFIGURAZIONE MANUALE DNS"
        echo "=========================================="
        echo ""
        echo "Accedi al pannello del tuo provider DNS e crea:"
        echo ""
        echo "Tipo: A Record"
        echo "Nome/Host: n8n"
        echo "Dominio: waipro.it"
        echo "Indirizzo IPv4: $SERVER_IP"
        echo "TTL: 600 (10 minuti)"
        echo ""
        echo "Esempio per GoDaddy:"
        echo "1. Vai su https://dcc.godaddy.com/control/waipro.it/dns"
        echo "2. Click 'Add' → 'A'"
        echo "3. Nome: n8n"
        echo "4. Indirizzo: $SERVER_IP"
        echo "5. TTL: 10 minuti"
        echo "6. Salva"
        echo ""
        echo "=========================================="
        ;;
    *)
        echo "Scelta non valida"
        exit 1
        ;;
esac

echo ""
echo "Attendi 2-5 minuti per propagazione DNS..."
echo ""
echo "Verifica DNS con:"
echo "  dig +short n8n.waipro.it"
echo "  nslookup n8n.waipro.it"
echo ""
