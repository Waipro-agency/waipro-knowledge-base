# 🚀 n8n Deployment Guide - n8n.waipro.it

## Quick Deploy

### Prerequisiti
- Server Linux (Ubuntu/Debian raccomandato)
- Accesso root/sudo
- Dominio n8n.waipro.it con DNS configurato

### Deploy Automatico

```bash
cd /root/WAPRO
sudo ./deploy-n8n.sh
```

Lo script esegue automaticamente:
1. ✅ Installazione Docker e Docker Compose
2. ✅ Verifica configurazione DNS
3. ✅ Generazione encryption key
4. ✅ Start n8n container
5. ✅ Ottenimento certificato SSL (Let's Encrypt)
6. ✅ Configurazione Nginx reverse proxy
7. ✅ Avvio servizi completi

---

## Configurazione DNS

Prima di eseguire lo script, configura DNS:

```
Tipo: A Record
Nome: n8n
Dominio: waipro.it
Indirizzo: [IP_DEL_SERVER]
TTL: 3600
```

Verifica DNS:
```bash
dig +short n8n.waipro.it
# Deve restituire l'IP del server
```

---

## Accesso n8n

Dopo il deployment:

**URL**: https://n8n.waipro.it

**Credenziali**:
- Username: `admin`
- Password: `Benessere84++`

---

## Workflow Disponibili

### 1. Base44 to Supabase Sync
**File**: `n8n-workflows/base44-supabase-workflow.json`

**Funzione**: Sincronizza dati tra Base44 e Supabase

**Endpoint**: `https://n8n.waipro.it/webhook/base44-webhook`

**Usage**:
```bash
curl -X POST https://n8n.waipro.it/webhook/base44-webhook \
  -H "Content-Type: application/json" \
  -d '{
    "table": "blog_posts",
    "data": {
      "title": "New Post",
      "content": "Content here"
    }
  }'
```

### 2. Base44 AI Agent with MCP
**File**: `n8n-workflows/base44-ai-agent-workflow.json`

**Funzione**: Processa dati Base44 con AI e salva risultati

**Endpoint**: `https://n8n.waipro.it/webhook/ai-agent`

**Flow**:
1. Webhook trigger
2. Get data from Supabase
3. Process with OpenAI GPT-4
4. Save AI analysis
5. Return results

**Usage**:
```bash
curl -X POST https://n8n.waipro.it/webhook/ai-agent \
  -H "Content-Type: application/json" \
  -d '{
    "entity": "products",
    "id": "123"
  }'
```

---

## Import Workflow in n8n

1. Login a https://n8n.waipro.it
2. Click su "Workflows" → "Import from File"
3. Seleziona file JSON da `n8n-workflows/`
4. Click "Import"

---

## Configurazione Credentials

### Supabase Credentials

1. In n8n, vai a **Settings** → **Credentials** → **Add Credential**
2. Cerca "HTTP Header Auth"
3. Aggiungi:
   - Name: `Supabase Auth`
   - Header Name: `apikey`
   - Header Value: `YOUR_SUPABASE_ANON_KEY`

### OpenAI Credentials

1. **Settings** → **Credentials** → **Add Credential**
2. Cerca "OpenAI"
3. Aggiungi API Key: `sk-...`

---

## Environment Variables

Le variabili sono configurate in `docker-compose.yml`:

```env
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=Benessere84++
N8N_HOST=n8n.waipro.it
WEBHOOK_URL=https://n8n.waipro.it/
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
VITE_SUPABASE_SERVICE_ROLE_KEY=...
```

Per aggiornare:
```bash
cd /root/WAPRO
vim docker-compose.yml
# Modifica variabili
docker-compose down
docker-compose up -d
```

---

## Comandi Utili

### View Logs
```bash
cd /root/WAPRO
docker-compose logs -f n8n
```

### Restart n8n
```bash
docker-compose restart n8n
```

### Stop All Services
```bash
docker-compose down
```

### Update n8n
```bash
docker-compose pull n8n
docker-compose up -d
```

### SSL Certificate Renewal
```bash
docker-compose run certbot renew
docker-compose restart nginx
```

### Backup n8n Data
```bash
docker run --rm -v waipro_n8n_data:/data -v $(pwd):/backup ubuntu tar czf /backup/n8n-backup-$(date +%Y%m%d).tar.gz /data
```

### Restore n8n Data
```bash
docker run --rm -v waipro_n8n_data:/data -v $(pwd):/backup ubuntu tar xzf /backup/n8n-backup-YYYYMMDD.tar.gz -C /
```

---

## Troubleshooting

### n8n non si avvia

```bash
# Check logs
docker-compose logs n8n

# Common issues:
# 1. Port 5678 già in uso
sudo lsof -i :5678
# Killa processo o cambia porta in docker-compose.yml

# 2. Permessi volume
sudo chown -R 1000:1000 /var/lib/docker/volumes/waipro_n8n_data/_data
```

### SSL Certificate Failed

```bash
# Manual certificate request
docker-compose run certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email admin@waipro.it \
  --agree-tos \
  --no-eff-email \
  -d n8n.waipro.it

# Verify certificate
docker-compose run certbot certificates
```

### Webhook non funziona

1. Verifica firewall:
```bash
sudo ufw allow 80
sudo ufw allow 443
```

2. Test webhook:
```bash
curl -X POST https://n8n.waipro.it/webhook-test/test
```

3. Check n8n execution logs in UI

### Cannot Connect to Supabase

1. Verifica credentials in n8n UI
2. Test connection manualmente:
```bash
curl -X GET "$VITE_SUPABASE_URL/rest/v1/your_table" \
  -H "apikey: $VITE_SUPABASE_ANON_KEY"
```

---

## Sicurezza

### Cambiare Password

1. Modifica `docker-compose.yml`:
```yaml
- N8N_BASIC_AUTH_PASSWORD=NEW_SECURE_PASSWORD
```

2. Riavvia:
```bash
docker-compose down
docker-compose up -d
```

### Rate Limiting

Configurato in `nginx.conf`:
```
limit_req_zone $binary_remote_addr zone=n8n_limit:10m rate=10r/s;
```

Modifica per cambiare limiti.

### Firewall

```bash
# Allow solo porte necessarie
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

---

## Monitoring

### Docker Stats
```bash
docker stats n8n_waipro
```

### Check Health
```bash
curl -I https://n8n.waipro.it
```

### n8n Metrics
n8n espone metriche Prometheus su `/metrics` (se abilitato)

---

## Production Checklist

- [ ] DNS configurato correttamente
- [ ] SSL certificate ottenuto e funzionante
- [ ] Password cambiata da default
- [ ] Firewall configurato
- [ ] Backup automatici configurati
- [ ] Monitoring setup
- [ ] Workflow importati e testati
- [ ] Credentials configurate
- [ ] Webhook testati
- [ ] Rate limiting verificato

---

## Prossimi Passi

1. **Import workflow**:
   - base44-supabase-workflow.json
   - base44-ai-agent-workflow.json

2. **Configurare credentials**:
   - Supabase
   - OpenAI
   - Email (opzionale)

3. **Testare workflow**:
   - Trigger manuale
   - Webhook test
   - Verifica output

4. **Integrare con Base44 app**:
   - Aggiungere webhook calls in Base44
   - Testare end-to-end flow

5. **Setup monitoring**:
   - Log aggregation
   - Error alerting
   - Performance metrics

---

**Documentazione**: https://docs.n8n.io
**Supporto**: admin@waipro.it

*Last Updated: 2025-10-26*
