# 🚀 QUICK START - Waipro Multi-Tenant System

**Setup Time:** 15-30 minuti
**Difficoltà:** Facile
**Prerequisiti:** Git, Docker (verrà installato se mancante)

---

## ⚡ Setup Rapido (3 Comandi)

```bash
# 1. Clone repository
git clone https://github.com/Waipro-agency/waipro-knowledge-base.git
cd waipro-knowledge-base

# 2. Run setup automatico
./SETUP-SCRIPTS/complete-setup.sh

# 3. Start services
docker-compose up -d
```

**Fatto!** 🎉 Il sistema è pronto.

---

## 📋 Setup Dettagliato

### Passo 1: Preparazione

```bash
# Clone il repository
git clone https://github.com/Waipro-agency/waipro-knowledge-base.git
cd waipro-knowledge-base

# Verifica contenuto
ls -la
```

**Output atteso:**
```
CONFIG/
DOCS/
n8n-workflows/
SETUP-SCRIPTS/
docker-compose.yml
...
```

---

### Passo 2: Configurazione Automatica

```bash
# Esegui lo script di setup
./SETUP-SCRIPTS/complete-setup.sh
```

**Lo script farà:**
- ✅ Verifica prerequisiti (Docker, Node.js, etc.)
- ✅ Crea file `.env` da template
- ✅ Configura token WhatsApp (interattivo)
- ✅ Configura Base44 API (interattivo)
- ✅ Genera chiavi di encryption
- ✅ Avvia Docker containers
- ✅ Verifica configurazione

**Tempo:** ~10 minuti (più le informazioni da inserire)

---

### Passo 3: Configurazione Manuale (Opzionale)

Se preferisci configurare manualmente:

```bash
# Copia template
cp CONFIG/.env.example CONFIG/.env

# Modifica con i tuoi dati
nano CONFIG/.env
# oppure
vim CONFIG/.env
```

**Variabili critiche da configurare:**

```env
# WhatsApp Tokens (da Meta Business Manager)
WHATSAPP_TOKEN_MISTERPHONE=EAAxxxxx...
WHATSAPP_PHONE_MISTERPHONE=+39xxxxxxxxxx

WHATSAPP_TOKEN_RIPARASUBITO=EAAyyyyy...
WHATSAPP_PHONE_RIPARASUBITO=+39yyyyyyyyyy

# Base44 (da app.base44.com)
BASE44_API_KEY=b44_xxxxx...
BASE44_AGENT_MISTERPHONE=agent_xxxxx
BASE44_AGENT_RIPARASUBITO=agent_yyyyy

# n8n (password sicura!)
N8N_BASIC_AUTH_PASSWORD=TuaPasswordSicura123!

# Telegram (opzionale, per notifiche)
TELEGRAM_BOT_TOKEN=123456:ABCdef...
TELEGRAM_OPERATOR_CHAT_ID=-1001234567890
```

---

### Passo 4: Start Services

```bash
# Start tutti i servizi
docker-compose up -d

# Verifica che siano attivi
docker-compose ps
```

**Output atteso:**
```
NAME            IMAGE               STATUS
n8n_waipro      n8nio/n8n:latest    Up
n8n_nginx       nginx:alpine        Up
n8n_certbot     certbot/certbot     Up
```

**Accesso n8n:**
- URL: `https://n8n.waipro.it`
- User: `admin`
- Password: (quella in `.env`)

---

### Passo 5: Import Workflows n8n

1. **Apri n8n UI:** `https://n8n.waipro.it`

2. **Login** con credenziali da `.env`

3. **Import workflows:**
   - Click su **"Workflows"** nel menu
   - Click su **"Import from File"**
   - Seleziona file da `n8n-workflows/`:
     - ✅ `whatsapp-multi-tenant-orchestrator.json` **(PRINCIPALE)**
     - ✅ `base44-ai-agent-workflow.json`
     - ✅ `rag-auto-update.json`
     - ✅ `social-media-automation.json`

4. **Attiva workflow:**
   - Apri ogni workflow importato
   - Click su **"Active"** (toggle in alto a destra)
   - Salva

**IMPORTANTE:** Il workflow **WhatsApp Multi-Tenant Orchestrator** DEVE essere attivo!

---

### Passo 6: Configura WhatsApp Webhooks

1. **Vai su Meta Business Manager:**
   - URL: https://business.facebook.com
   - Seleziona il tuo Business Account

2. **WhatsApp > Configuration:**
   - Click su **"Configuration"** nel menu WhatsApp

3. **Webhook Setup:**
   - **Callback URL:** `https://n8n.waipro.it/webhook/whatsapp-webhook`
   - **Verify Token:** (crea token personalizzato, es: `waipro_verify_2025`)

4. **Subscribe to:**
   - ✅ `messages` (messaggi in arrivo)
   - ✅ `message_status` (conferme di lettura)

5. **Save e Verify:**
   - Click **"Verify and Save"**
   - Deve mostrare ✅ **"Success"**

---

### Passo 7: Test del Sistema

#### Test 1: Invio Messaggio WhatsApp

```bash
# Invia messaggio WhatsApp al numero business
# (dal tuo telefono personale)

"Ciao, ho bisogno di riparare il mio iPhone"
```

**Verifica:**
1. Vai su n8n UI > **Executions**
2. Dovresti vedere nuova execution del workflow **WhatsApp Multi-Tenant Orchestrator**
3. Click sull'execution per vedere i dettagli
4. Verifica che:
   - ✅ Tenant detection funziona
   - ✅ Message validation passa
   - ✅ Base44 AI risponde
   - ✅ Risposta inviata su WhatsApp

#### Test 2: Verifica Logs

```bash
# Logs di tutti i container
docker-compose logs -f

# Solo n8n
docker-compose logs -f n8n

# Ultimi 100 righe
docker-compose logs --tail=100 n8n
```

#### Test 3: Escalation Test

```bash
# Invia messaggio che causerà errore (per testare escalation)
"sdfjksdjfksjdkfjskdfjksd"
```

**Verifica:**
- Dopo 2-3 retry, il sistema dovrebbe escalare
- Ricevi notifica Telegram (se configurato)
- Cliente riceve: "Un operatore ti contatterà a breve..."

---

## 🔧 Comandi Utili

### Docker

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart services
docker-compose restart

# View logs
docker-compose logs -f

# Update containers
docker-compose pull
docker-compose up -d
```

### n8n

```bash
# Backup workflows
docker exec n8n_waipro n8n export:workflow --all --output=/backup

# Restore workflows
docker exec n8n_waipro n8n import:workflow --input=/backup/workflow.json

# Reset n8n (ATTENZIONE: cancella tutto!)
docker-compose down -v
docker-compose up -d
```

### Git

```bash
# Pull ultimi aggiornamenti
git pull origin main

# Commit modifiche
git add .
git commit -m "Update configuration"
git push origin main
```

---

## 🐛 Troubleshooting

### Problema: n8n non parte

```bash
# Verifica logs
docker-compose logs n8n

# Controlla porta in uso
sudo lsof -i :5678

# Restart
docker-compose restart n8n
```

### Problema: WhatsApp webhook non funziona

**Checklist:**
- [ ] Workflow **WhatsApp Multi-Tenant Orchestrator** è ATTIVO?
- [ ] Webhook URL corretto su Meta Business?
- [ ] Token WhatsApp configurati in `.env`?
- [ ] DNS `n8n.waipro.it` risolve correttamente?
- [ ] SSL certificate valido?

**Test manuale webhook:**
```bash
curl -X POST https://n8n.waipro.it/webhook/whatsapp-webhook \
  -H "Content-Type: application/json" \
  -d '{"test": "message"}'
```

### Problema: AI non risponde

**Checklist:**
- [ ] Base44 API key valida?
- [ ] Agent ID corretto?
- [ ] n8n può raggiungere Base44 API?

**Test API Base44:**
```bash
curl -X POST https://api.base44.com/v1/agents/YOUR_AGENT_ID/chat \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"message": "test"}'
```

### Problema: Escalation non funziona

**Checklist:**
- [ ] Telegram Bot Token configurato?
- [ ] Chat ID corretto?
- [ ] Circuit breaker impostato correttamente?

**Test Telegram:**
```bash
curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d "chat_id=${TELEGRAM_CHAT_ID}&text=Test notification"
```

---

## 📊 Monitoring

### Dashboard n8n

Accedi a: `https://n8n.waipro.it/executions`

**Metriche da monitorare:**
- 📈 Execution count (giornaliero)
- ⏱️  Average execution time
- ❌ Error rate (< 2% target)
- 🔄 Retry rate
- 📤 Escalation rate (< 15% target)

### Logs Monitoring

```bash
# Real-time logs
docker-compose logs -f | grep -i error

# Error summary
docker-compose logs --since 24h | grep -i error | wc -l

# Successful executions
docker-compose logs --since 1h | grep -i success | wc -l
```

### Health Check

```bash
# Check all services
docker-compose ps

# Check n8n health
curl https://n8n.waipro.it/healthz

# Check disk space
df -h

# Check memory
free -h
```

---

## 🔐 Security Best Practices

### 1. Secrets Management

```bash
# NEVER commit .env to Git!
echo "CONFIG/.env" >> .gitignore

# Restrict .env permissions
chmod 600 CONFIG/.env

# Backup .env securely
gpg -c CONFIG/.env
# Crea CONFIG/.env.gpg (encrypted)
```

### 2. Update Passwords

```bash
# Generate strong password
openssl rand -base64 32

# Update n8n password
# Edit CONFIG/.env:
N8N_BASIC_AUTH_PASSWORD=nuovo_password_sicuro
```

### 3. Firewall Setup

```bash
# Allow only necessary ports
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw enable
```

### 4. SSL Certificate Renewal

```bash
# Auto-renewal is configured in docker-compose
# Manual renewal:
docker-compose run --rm certbot renew

# Reload nginx
docker-compose exec nginx nginx -s reload
```

---

## 📚 Documentazione Completa

- **Piano Operativo:** [`DOCS/WAIPRO-OPERATIONAL-PLAN.md`](DOCS/WAIPRO-OPERATIONAL-PLAN.md)
- **Master Guide:** [`DOCS/MASTER-GUIDE-BASE44-N8N-MCP.md`](DOCS/MASTER-GUIDE-BASE44-N8N-MCP.md)
- **Social Login:** [`DOCS/BASE44-SOCIAL-LOGIN-WAIPRO-GUIDE.md`](DOCS/BASE44-SOCIAL-LOGIN-WAIPRO-GUIDE.md)
- **Comet.ai Integration:** [`DOCS/COMET-AI-INTEGRATION-STRATEGY.md`](DOCS/COMET-AI-INTEGRATION-STRATEGY.md)

---

## 💡 Tips & Tricks

### Sviluppo Locale

```bash
# Override docker-compose per sviluppo
cp docker-compose.yml docker-compose.dev.yml

# Modifica docker-compose.dev.yml:
# - Esponi porte aggiuntive
# - Mount codice locale
# - Disabilita restart: always

# Use dev compose
docker-compose -f docker-compose.dev.yml up
```

### Testing Workflows

1. **Test Mode:** Usa n8n "Execute Workflow" button
2. **Manual Trigger:** Click "Execute Workflow" con dati test
3. **Debug:** Aggiungi nodi "Function" con `console.log()`

### Performance Optimization

```bash
# Limit execution history
# Edit CONFIG/.env:
EXECUTIONS_DATA_SAVE_ON_SUCCESS=false
EXECUTIONS_DATA_MAX_AGE=168  # 7 days

# Restart n8n
docker-compose restart n8n
```

---

## 🆘 Support

### Community

- **Discord Base44:** https://discord.gg/base44
- **n8n Community:** https://community.n8n.io
- **GitHub Issues:** https://github.com/Waipro-agency/waipro-knowledge-base/issues

### Commercial Support

- **Email:** support@waipro.it
- **Website:** https://waipro.it

---

## ✅ Checklist Post-Setup

Prima di andare in produzione:

- [ ] Tutti i token WhatsApp configurati
- [ ] Base44 API keys valide
- [ ] n8n accessibile e sicuro (HTTPS + password forte)
- [ ] Workflows importati e ATTIVI
- [ ] WhatsApp webhooks configurati
- [ ] Test messaggio WhatsApp completato con successo
- [ ] Escalation testata
- [ ] Telegram notifications funzionanti
- [ ] SSL certificate valido
- [ ] Backup automatico configurato
- [ ] Monitoring attivo
- [ ] Documentazione letta e compresa
- [ ] Team formato sull'uso del sistema

---

**🎉 Congratulazioni! Il tuo sistema multi-tenant è pronto! 🎉**

*Creato con ❤️ da Waipro Agency*
*Ultimo aggiornamento: 5 Novembre 2025*
