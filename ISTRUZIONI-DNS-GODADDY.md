# 🌐 Configurazione DNS n8n.waipro.it su GoDaddy

## Metodo 1: Configurazione Manuale (Più Semplice)

### Passo 1: Accedi a GoDaddy
1. Vai su https://dcc.godaddy.com
2. Login con le tue credenziali
3. Vai su "My Products" → "DNS"
4. Seleziona dominio **waipro.it**

### Passo 2: Aggiungi Record A
1. Click su **"Add"** (o "Aggiungi")
2. Seleziona **"A"** come tipo di record
3. Compila:
   - **Nome/Host**: `n8n`
   - **Punta a**: `2a02:4780:41:9001::1` (IP del server)
   - **TTL**: `600` secondi (10 minuti) o "Custom"
4. Click **"Save"** (Salva)

### Passo 3: Verifica
Dopo 2-5 minuti, verifica DNS:
```bash
dig +short n8n.waipro.it
# Dovrebbe restituire: 2a02:4780:41:9001::1
```

---

## Metodo 2: Configurazione API Automatica

### Prerequisiti
- GoDaddy API Key e Secret
- Accesso SSH al server

### Ottieni API Keys GoDaddy
1. Vai su https://developer.godaddy.com/keys
2. Click "Create New API Key"
3. Seleziona "Production"
4. Copia **Key** e **Secret**

### Esegui Script
```bash
cd /root/WAPRO
./configure-dns.sh
# Seleziona opzione 1 (GoDaddy)
# Inserisci API Key e Secret
```

Lo script:
1. Ottiene l'IP del server automaticamente
2. Chiama l'API GoDaddy
3. Crea/aggiorna il record A per n8n.waipro.it

---

## Metodo 3: cURL Manuale (Avanzato)

```bash
# Variabili
GODADDY_API_KEY="your_api_key"
GODADDY_API_SECRET="your_api_secret"
DOMAIN="waipro.it"
SUBDOMAIN="n8n"
SERVER_IP="2a02:4780:41:9001::1"

# Update/Create A record
curl -X PUT "https://api.godaddy.com/v1/domains/${DOMAIN}/records/A/${SUBDOMAIN}" \
  -H "Authorization: sso-key ${GODADDY_API_KEY}:${GODADDY_API_SECRET}" \
  -H "Content-Type: application/json" \
  -d "[{
    \"data\": \"${SERVER_IP}\",
    \"ttl\": 600
  }]"
```

---

## Verifica DNS Propagazione

### Comando rapido
```bash
dig +short n8n.waipro.it
```

### Verifica dettagliata
```bash
nslookup n8n.waipro.it

# Oppure
host n8n.waipro.it
```

### Online Checkers
- https://dnschecker.org/#A/n8n.waipro.it
- https://www.whatsmydns.net/#A/n8n.waipro.it

---

## Dopo Configurazione DNS

Una volta che DNS è propagato (2-5 minuti):

### 1. Riavvia Deploy con SSL
```bash
cd /root/WAPRO
docker-compose down
./deploy-n8n.sh
```

### 2. Lo script otterrà automaticamente certificato SSL

### 3. Accedi a n8n
```
URL: https://n8n.waipro.it
Username: admin
Password: Benessere84++
```

---

## Troubleshooting

### DNS non si propaga
- Attendi fino a 24h (raro)
- Controlla TTL impostato
- Verifica che il record sia salvato in GoDaddy

### Errore API GoDaddy
- Verifica API keys corrette
- Controlla che le keys siano per "Production"
- Verifica dominio ownership

### IP Server cambiato
Ottieni nuovo IP:
```bash
curl ifconfig.me
```
Aggiorna record A in GoDaddy con nuovo IP

---

## Record DNS Completo per waipro.it

Configurazione raccomandata:

```
# n8n automation
n8n.waipro.it    A    2a02:4780:41:9001::1    600

# Root domain (se necessario)
@.waipro.it      A    2a02:4780:41:9001::1    3600

# WWW (se necessario)
www.waipro.it    CNAME waipro.it            3600
```

---

**IP Server Attuale**: `2a02:4780:41:9001::1`

**Dominio da configurare**: `n8n.waipro.it`

**TTL Raccomandato**: 600 secondi (10 minuti) per test, poi aumenta a 3600 (1 ora)

