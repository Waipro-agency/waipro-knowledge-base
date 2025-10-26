# 🌐 Configurazione DNS n8n.waipro.it su GoDaddy

## ✅ Stato Attuale (Aggiornato: 2025-10-26)

**DNS configurato e verificato!**

- **Dominio**: n8n.waipro.it
- **Record Type**: AAAA (IPv6)
- **Nome/Host**: n8n
- **Valore**: 2a02:4780:41:9001::1
- **TTL**: 600 secondi (10 minuti)
- **Status**: ✅ Propagato globalmente
- **Verifica**: [DNSChecker](https://dnschecker.org/#AAAA/n8n.waipro.it)

---

## Metodo 1: Configurazione Manuale (Più Semplice)

### Passo 1: Accedi a GoDaddy

1. Vai su https://dcc.godaddy.com
2. Login con le tue credenziali
3. Vai su "My Products" → "DNS"
4. Seleziona dominio **waipro.it**

### Passo 2: Aggiungi Record AAAA

1. Click su **"Add"** (o "Aggiungi nuovo record")
2. Seleziona **"AAAA"** come tipo di record (per indirizzi IPv6)
3. Compila:
   - **Nome/Host**: `n8n`
   - **Punta a**: `2a02:4780:41:9001::1` (indirizzo IPv6 del server)
   - **TTL**: `600` secondi (10 minuti) o "Custom"
4. Click **"Save"** (Salva)

### Passo 3: Verifica

Dopo 2-5 minuti, verifica DNS:

```bash
# Verifica record AAAA (IPv6)
dig AAAA +short n8n.waipro.it
# Dovrebbe restituire: 2a02:4780:41:9001::1

# Oppure usa nslookup
nslookup -type=AAAA n8n.waipro.it

# Verifica globale online
# https://dnschecker.org/#AAAA/n8n.waipro.it
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
1. Ottiene l'indirizzo IPv6 del server automaticamente
2. Chiama l'API GoDaddy
3. Crea/aggiorna il record AAAA per n8n.waipro.it

---

## Metodo 3: cURL Manuale (Avanzato)

```bash
# Variabili
GODADDY_API_KEY="your_api_key"
GODADDY_API_SECRET="your_api_secret"
DOMAIN="waipro.it"
SUBDOMAIN="n8n"
IPV6_ADDRESS="2a02:4780:41:9001::1"

# Crea/Aggiorna record AAAA
curl -X PUT "https://api.godaddy.com/v1/domains/${DOMAIN}/records/AAAA/${SUBDOMAIN}" \
  -H "Authorization: sso-key ${GODADDY_API_KEY}:${GODADDY_API_SECRET}" \
  -H "Content-Type: application/json" \
  -d '[{"data":"'${IPV6_ADDRESS}'","ttl":600}]'
```

---

## Risoluzione Problemi

### Record non si propaga

1. **Verifica TTL**: Un TTL alto ritarda la propagazione
2. **Cancella cache DNS locale**:
   ```bash
   # Linux
   sudo systemd-resolve --flush-caches
   
   # macOS
   sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
   
   # Windows
   ipconfig /flushdns
   ```
3. **Usa DNS alternativi**: Testa con Google DNS (8.8.8.8) o Cloudflare (1.1.1.1)

### Errore "Record già esistente"

- Elimina il vecchio record prima di aggiungerne uno nuovo
- Oppure usa "Edit" invece di "Add"

### IPv6 non funziona

1. Verifica che il server supporti IPv6:
   ```bash
   ip -6 addr show
   ```
2. Controlla firewall:
   ```bash
   sudo ufw allow from any to any proto tcp port 443 comment 'HTTPS IPv6'
   ```
3. Se necessario, aggiungi anche un record A (IPv4):
   - Type: A
   - Name: n8n
   - Value: [IPv4 del server]
   - TTL: 600

---

## Note Tecniche

### Differenza tra A e AAAA

- **A Record**: Punta a indirizzo IPv4 (es: 192.168.1.1)
- **AAAA Record**: Punta a indirizzo IPv6 (es: 2a02:4780:41:9001::1)

### TTL (Time To Live)

- **600 secondi (10 min)**: Propagazione veloce, utile per testing
- **3600 secondi (1 ora)**: Standard per ambienti stabili
- **86400 secondi (24 ore)**: Per configurazioni permanenti

### Propagazione DNS

- **Locale**: 2-5 minuti
- **Globale**: 24-48 ore (ma spesso molto più veloce)
- **Verifica globale**: https://dnschecker.org

---

## Checklist Post-Configurazione

- [x] Record AAAA aggiunto su GoDaddy
- [x] TTL impostato a 600 secondi
- [x] DNS verificato localmente
- [x] DNS verificato globalmente (dnschecker.org)
- [ ] Certificato SSL configurato (Let's Encrypt)
- [ ] n8n installato e raggiungibile
- [ ] HTTPS funzionante
- [ ] Redirect HTTP → HTTPS attivo

---

## Riferimenti

- [GoDaddy API Docs](https://developer.godaddy.com/doc)
- [DNS Checker Tool](https://dnschecker.org)
- [IPv6 Info](https://test-ipv6.com/)
- [n8n Docs](https://docs.n8n.io)

---

**Ultima modifica**: 2025-10-26  
**Configurato da**: WAIPRO Agency  
**Status**: ✅ Completato e Verificato
