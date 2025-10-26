# 🚀 GUIDA MASTER: Base44 + n8n + MCP - Configurazione Completa

> **Scopo**: Questa guida fornisce tutte le informazioni necessarie per configurare e integrare Base44, n8n e MCP (Model Context Protocol) in un ecosistema completo di automazione AI.
>
> **Destinatari**: Agenti AI, sviluppatori, automatori
>
> **Ultimo aggiornamento**: 2025-10-26

---

## 📋 Indice

1. [Panoramica dell'Ecosistema](#panoramica-delecosistema)
2. [Base44: Setup e Configurazione](#base44-setup-e-configurazione)
3. [n8n: Automazione e Workflow](#n8n-automazione-e-workflow)
4. [MCP: Model Context Protocol](#mcp-model-context-protocol)
5. [Integrazione Completa](#integrazione-completa)
6. [API Keys e Credenziali](#api-keys-e-credenziali)
7. [Deployment e Hosting](#deployment-e-hosting)
8. [Troubleshooting](#troubleshooting)

---

## 🌟 Panoramica dell'Ecosistema

### Componenti Chiave

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   Base44    │◄────►│     n8n     │◄────►│     MCP     │
│  (Database) │      │ (Workflow)  │      │  (AI Agent) │
└─────────────┘      └─────────────┘      └─────────────┘
       │                    │                     │
       └────────────────────┴─────────────────────┘
                           │
                    ┌──────▼──────┐
                    │  Supabase   │
                    │ (Backend)   │
                    └─────────────┘
```

### Architettura

1. **Base44** - Frontend e gestione dati
2. **Supabase** - Backend PostgreSQL con auth e storage
3. **n8n** - Orchestrazione workflow e automazioni
4. **MCP** - Protocollo per agenti AI con accesso filesystem

---

## 🎯 Base44: Setup e Configurazione

### Cos'è Base44?

Base44 è una piattaforma no-code/low-code per costruire applicazioni web con AI integrata.

### Migrazione a Self-Hosted con Supabase

#### 1. Installazione Dipendenze

```bash
npm install @supabase/supabase-js
```

#### 2. Struttura File SDK

```
src/
├── lib/
│   ├── supabase-client.js    # Connessione Supabase
│   └── custom-sdk.js          # SDK universale Base44
└── api/
    └── base44Client.js        # Drop-in replacement
```

#### 3. Environment Variables

```env
# Supabase
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key
VITE_SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# App Config
VITE_APP_NAME=Your App Name
VITE_APP_DOMAIN=https://your-domain.com
```

#### 4. Database Schema Base

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  role TEXT DEFAULT 'user' CHECK (role IN ('admin', 'user')),
  email_verified BOOLEAN DEFAULT FALSE
);

-- Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
  FOR UPDATE USING (auth.uid() = id);
```

#### 5. Base44 Tool per Documentazione

**Installazione**:
```bash
cd ~/WAPRO/base44-docs
./install-base44-tool.sh
```

**Comandi Utili**:
```bash
# Cerca documentazione
./b44 search "authentication"
./b44 s "Google login" -s Integrations

# Ottieni pagina specifica
./b44 get "/Guides/Setting-up-SSO"

# Aggiorna documentazione
./b44 scrape
```

### Entità Universali in Base44

Il SDK automaticamente converte:
- `BlogPost` → `blog_posts` table
- `UserMembership` → `user_memberships` table
- `Product` → `products` table

**Zero code changes required!**

```javascript
// Il tuo codice Base44 esistente funziona inalterato
import { BlogPost, User, Product } from "./src/api/entities";

const posts = await BlogPost.list("-created_date");
const user = await User.me();
const products = await Product.filter({ status: "active" });
```

---

## ⚙️ n8n: Automazione e Workflow

### Cos'è n8n?

n8n è una piattaforma open-source di automazione workflow che permette di:
- Creare agenti AI
- Integrare servizi (Gmail, Slack, API, ecc.)
- Orchestrare flussi complessi senza codice

### Setup n8n

#### Opzione 1: Docker (Raccomandato)

```bash
# Crea docker-compose.yml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your_secure_password
      - N8N_HOST=n8n.waipro.it
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://n8n.waipro.it/
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
```

```bash
# Avvia n8n
docker-compose up -d
```

#### Opzione 2: npm

```bash
npm install -g n8n
n8n start
```

### Integrazione Base44 + n8n

#### Workflow Base

1. **Trigger** - Webhook o Schedule
2. **Base44 Node** - Crea/Leggi/Aggiorna dati
3. **AI Node** - Processa con LLM
4. **Action Node** - Invia email, notifica, ecc.

#### Esempio: Workflow Automatico

```json
{
  "nodes": [
    {
      "type": "n8n-nodes-base.webhook",
      "name": "Webhook",
      "parameters": {
        "path": "base44-trigger"
      }
    },
    {
      "type": "n8n-nodes-base.httpRequest",
      "name": "Get Base44 Data",
      "parameters": {
        "url": "={{$env.VITE_SUPABASE_URL}}/rest/v1/your_table",
        "authentication": "genericCredentialType",
        "headers": {
          "apikey": "={{$env.VITE_SUPABASE_ANON_KEY}}"
        }
      }
    },
    {
      "type": "@n8n/n8n-nodes-langchain.openAi",
      "name": "Process with AI",
      "parameters": {
        "prompt": "Analyze this data: {{$json.data}}"
      }
    },
    {
      "type": "n8n-nodes-base.emailSend",
      "name": "Send Notification",
      "parameters": {
        "to": "user@example.com",
        "subject": "AI Analysis Complete"
      }
    }
  ]
}
```

### n8n + Base44: Best Practices

1. **Usa Supabase REST API** per accedere ai dati Base44
2. **Credenziali sicure** - Salva API keys in n8n Credentials
3. **Error handling** - Aggiungi nodi di error catching
4. **Logging** - Traccia tutte le operazioni
5. **Testing** - Testa workflow in ambiente di sviluppo

---

## 🤖 MCP: Model Context Protocol

### Cos'è MCP?

MCP (Model Context Protocol) permette agli agenti AI di accedere a:
- Filesystem locale
- Eseguire comandi shell
- Leggere/scrivere file
- Controllare il sistema

### Setup MCP Server

#### Server già creato in: `~/WAPRO/MCP/`

**Struttura**:
```
~/WAPRO/MCP/
├── index.js           # Server MCP
├── package.json       # Dipendenze
└── node_modules/      # Librerie installate
```

#### Configurazione Claude Desktop (macOS)

**File**: `~/Library/Application Support/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "node",
      "args": ["/Users/YOUR_USERNAME/WAPRO/MCP/index.js"]
    }
  }
}
```

#### Strumenti Disponibili

1. **read_file** - Legge file dal filesystem
2. **write_file** - Scrive contenuto in file
3. **list_directory** - Lista file e directory
4. **create_directory** - Crea nuove directory
5. **delete_file** - Elimina file/directory
6. **execute_command** - Esegue comandi shell
7. **file_info** - Ottiene info su file/directory

#### Test MCP

```bash
# Verifica che il server funzioni
cd ~/WAPRO/MCP
node index.js
# Dovrebbe stampare: "MCP Filesystem Server avviato"
```

---

## 🔗 Integrazione Completa

### Flusso End-to-End

```
1. User Action → Base44 App
2. Base44 → Webhook → n8n
3. n8n → Process data → AI Agent (via MCP)
4. AI Agent → Access files/execute commands → MCP
5. MCP → Return results → n8n
6. n8n → Update Base44/Supabase
7. n8n → Send notifications
```

### Esempio Pratico: Sistema di Analisi Documenti

#### Step 1: Upload documento in Base44

```javascript
// Base44 app - upload file
const uploadedFile = await UploadFile(file);
```

#### Step 2: Trigger n8n workflow

```javascript
// Webhook trigger in n8n
fetch('https://n8n.waipro.it/webhook/analyze-document', {
  method: 'POST',
  body: JSON.stringify({
    fileUrl: uploadedFile.url,
    userId: currentUser.id
  })
});
```

#### Step 3: n8n processa il documento

```
n8n Workflow:
1. Download file from Base44/Supabase
2. Send to AI agent (Claude con MCP)
3. AI reads file using MCP read_file
4. AI analyzes content
5. AI writes summary using MCP write_file
6. n8n uploads summary to Base44
7. n8n sends email notification
```

#### Step 4: Risultati salvati in Base44

```javascript
// Aggiornamento automatico in Base44/Supabase
await DocumentAnalysis.create({
  documentId: file.id,
  summary: aiSummary,
  extractedData: aiData,
  status: 'completed'
});
```

---

## 🔑 API Keys e Credenziali

### Struttura Organizzata

**File**: `~/WAPRO/CONFIG/credentials.env`

```env
# ========================
# SUPABASE / BASE44
# ========================
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhb...
VITE_SUPABASE_SERVICE_ROLE_KEY=eyJhb...

# ========================
# N8N
# ========================
N8N_URL=https://n8n.waipro.it
N8N_API_KEY=your_n8n_api_key
N8N_WEBHOOK_SECRET=your_webhook_secret

# ========================
# AI SERVICES
# ========================
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# ========================
# EMAIL SERVICES
# ========================
RESEND_API_KEY=re_...
SENDGRID_API_KEY=SG...

# ========================
# OTHER INTEGRATIONS
# ========================
STRIPE_SECRET_KEY=sk_test_...
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...

# ========================
# WAIPRO DOMAINS
# ========================
# n8n.waipro.it - n8n automation server
# t.waipro.it - Admin: admin@waipro.it / Benessere84++
```

### Gestione Sicura delle Credenziali

1. **Mai committare in Git**
```bash
# .gitignore
*.env
credentials.env
.env.local
```

2. **Usa secret manager** (per production)
- Vercel: Environment Variables
- Cloudflare: Secrets
- Docker: Docker secrets

3. **Rotazione periodica** delle chiavi
4. **Accesso limitato** solo a chi serve

---

## 🚀 Deployment e Hosting

### Setup Domini WAIPRO

#### 1. n8n.waipro.it

**Status**: Da configurare
**Scopo**: Hosting n8n automation server

**Setup**:
```bash
# DNS Configuration
A Record: n8n.waipro.it → Your Server IP

# Nginx/Caddy reverse proxy
server {
    server_name n8n.waipro.it;
    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
    }
}

# SSL con Let's Encrypt
certbot --nginx -d n8n.waipro.it
```

#### 2. t.waipro.it

**Credenziali**:
- User: `admin@waipro.it`
- Pass: `Benessere84++`

**Status**: Da verificare

### Deployment Checklist

- [ ] Configurare DNS per n8n.waipro.it
- [ ] Setup n8n con Docker
- [ ] Configurare SSL/HTTPS
- [ ] Verificare accesso t.waipro.it
- [ ] Deploy Base44 app su Cloudflare Pages/Vercel
- [ ] Configurare MCP server su Mac locale
- [ ] Testare integrazione end-to-end
- [ ] Setup monitoring e logging
- [ ] Configurare backup automatici

---

## 🐛 Troubleshooting

### Base44 Issues

**Problema**: Entità non trovata
```javascript
// Soluzione: Verifica nome tabella Supabase
// Base44: BlogPost → Supabase: blog_posts
```

**Problema**: RLS policy violation
```sql
-- Soluzione: Aggiungi policy RLS
CREATE POLICY "Allow access" ON your_table
  FOR ALL USING (auth.uid() = user_id);
```

### n8n Issues

**Problema**: Workflow non si attiva
- Verifica webhook URL
- Controlla credentials
- Vedi execution logs in n8n UI

**Problema**: Timeout su operazioni lunghe
```json
// Soluzione: Aumenta timeout
{
  "timeout": 300000  // 5 minuti
}
```

### MCP Issues

**Problema**: Server disconnected
- Verifica percorso in claude_desktop_config.json
- Riavvia Claude Desktop (⌘+Q)
- Controlla che Node.js sia installato

**Problema**: Permission denied
```bash
# Soluzione: Dai permessi corretti
chmod +x ~/WAPRO/MCP/index.js
```

---

## 📚 Risorse Aggiuntive

### Documentazione Ufficiale

- **Base44**: https://docs.base44.com
- **n8n**: https://docs.n8n.io
- **Supabase**: https://supabase.com/docs
- **MCP**: Repository locali in `~/WAPRO/`

### Tool Locali

```bash
# Base44 docs tool
~/WAPRO/base44-docs/b44 search "query"

# Base44 SDK
~/WAPRO/base44-sdk/

# MCP Server
~/WAPRO/MCP/
```

### Community e Supporto

- **AI Automation Society**: https://www.skool.com/ai-automation-society
- **n8n Community**: https://community.n8n.io
- **Supabase Discord**: https://discord.supabase.com

---

## ✅ Checklist Finale

### Setup Iniziale
- [ ] Supabase project creato
- [ ] Base44 SDK installato
- [ ] n8n installato e funzionante
- [ ] MCP server configurato
- [ ] Tutti i credentials salvati in `~/WAPRO/CONFIG/credentials.env`

### Integrazione
- [ ] Base44 ↔ Supabase connesso
- [ ] n8n ↔ Supabase API funzionante
- [ ] MCP ↔ Claude Desktop connesso
- [ ] Workflow di test creato e funzionante

### Production Ready
- [ ] Domini configurati (n8n.waipro.it, t.waipro.it)
- [ ] SSL/HTTPS attivo
- [ ] Backup automatici configurati
- [ ] Monitoring attivo
- [ ] Documentazione aggiornata

---

## 🎯 Next Steps

1. **Verificare domini WAIPRO** (n8n.waipro.it, t.waipro.it)
2. **Creare primo workflow** Base44 + n8n + MCP
3. **Testare integrazione completa**
4. **Documentare workflow custom**
5. **Setup RAG system** per aggiornamenti automatici

---

**Ultimo aggiornamento**: 2025-10-26
**Versione**: 1.0
**Maintainer**: WAIPRO Agency

