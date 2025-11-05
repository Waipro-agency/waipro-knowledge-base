# 🚀 WAIPRO Knowledge Base
> 
**Documentazione centralizzata e sistema RAG per Base44, n8n, MCP e automazioni AI**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status](https://img.shields.io/badge/Status-Active-success)]()
[![Last Updated](https://img.shields.io/badge/Updated-2025--11--05-blue)]()

---

## 📋 Indice

- [Panoramica](#-panoramica)
- [Struttura Repository](#-struttura-repository)
- [Quick Start](#-quick-start)
- [Documentazione](#-documentazione)
- [Tool e Risorse](#-tool-e-risorse)
- [Configurazione](#-configurazione)
- [Contributing](#-contributing)

---

## 🌟 Panoramica

Questo repository centralizza tutta la conoscenza necessaria per lavorare con l'ecosistema WAIPRO:

- **Base44**: Piattaforma no-code con AI integrata + migrazione a Supabase
- **n8n**: Automazione workflow e orchestrazione
- **MCP**: Model Context Protocol per agenti AI
- **RAG System**: Sistema di retrieval per informazioni sempre aggiornate

### Obiettivi

✅ **Zero copia-incolla** - Tutti gli agenti AI accedono alla stessa knowledge base
✅ **Sempre aggiornato** - Sync automatico con Git e scraping docs
✅ **Facile da usare** - Guide step-by-step per ogni componente
✅ **Sicuro** - Template per credenziali, nessun secret in Git

---

## 📁 Struttura Repository

```
WAPRO/
├── README.md                    # Questo file
├── .gitignore                   # File da ignorare
│
├── DOCS/                        # 📚 Documentazione
│   ├── MASTER-GUIDE-BASE44-N8N-MCP.md
│   ├── BASE44/                  # Base44 + Supabase
│   ├── N8N/                     # n8n workflows
│   ├── MCP/                     # Model Context Protocol
│   └── TUTORIALS/               # Guide pratiche
│
├── CONFIGS/                     # ⚙️ Configurazioni
│   ├── .env.example
│   ├── docker-compose.yml
│   └── templates/
│
├── SCRIPTS/                     # 🛠️ Scripts di utilità
│   ├── scraper/                 # Scraping automatico docs
│   └── sync/                    # Sync knowledge base
│
└── WORKFLOWS/                   # 🔄 n8n workflows ready-to-use
    ├── base44_to_supabase/
    └── rag_pipeline/
```

---

## 🚀 Quick Start

### 🔥 Setup in 3 Comandi (15 minuti)

```bash
# 1. Clone repository
git clone https://github.com/Waipro-agency/waipro-knowledge-base.git
cd waipro-knowledge-base

# 2. Run setup automatico
./SETUP-SCRIPTS/complete-setup.sh

# 3. Start services
docker-compose up -d
```

**📖 Guida completa:** [QUICK-START.md](QUICK-START.md)

### Prerequisiti

- Git
- Docker & Docker Compose (installato automaticamente se mancante)
- Token WhatsApp Business API
- Account Base44 con API key

---

## 📚 Documentazione

### Guide Principali

1. **[🚀 QUICK START](./QUICK-START.md)** - Setup completo in 15 minuti
2. **[📋 PIANO OPERATIVO](./DOCS/WAIPRO-OPERATIONAL-PLAN.md)** - Strategia e architettura completa
3. **[📚 MASTER GUIDE](./DOCS/MASTER-GUIDE-BASE44-N8N-MCP.md)** - Base44, n8n e MCP
4. **[🔐 Social Login](./DOCS/BASE44-SOCIAL-LOGIN-WAIPRO-GUIDE.md)** - OAuth con Auth0
5. **[🤖 Comet.ai Integration](./DOCS/COMET-AI-INTEGRATION-STRATEGY.md)** - Browser automation
6. **[🌐 DNS Configuration](./ISTRUZIONI-DNS-GODADDY.md)** - Setup DNS su GoDaddy

### 🎯 Per chi inizia

1. Leggi **[QUICK-START.md](./QUICK-START.md)** per setup rapido
2. Approfondisci con **[WAIPRO-OPERATIONAL-PLAN.md](./DOCS/WAIPRO-OPERATIONAL-PLAN.md)**
3. Importa i workflow n8n da `n8n-workflows/`

---

## 🛠️ Tool e Risorse

### MCP Server

Il server MCP offre questi tools agli agenti AI:

- `search_knowledge_base` - Ricerca semantica nella knowledge base
- `get_document` - Recupera documento specifico
- `list_workflows` - Elenca workflow n8n disponibili

**Avvio:**
```bash
cd SCRIPTS/mcp-server
npx tsx src/index.ts
```

### Base44 Docs Tool

Scraping automatico documentazione Base44:

```bash
cd SCRIPTS/base44-docs-tool
npm start
```

---

## ⚙️ Configurazione

### Variabili d'Ambiente

Crea `CONFIGS/.env` partendo da `CONFIGS/.env.example`:

```env
# Base44
BASE44_API_KEY=your_api_key
BASE44_ACCOUNT_ID=your_account_id

# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=your_anon_key

# n8n
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_password
N8N_HOST=n8n.waipro.it

# OpenAI
OPENAI_API_KEY=sk-...
```

### Template Credenziali

Tutti i template sono in `CONFIGS/templates/` - **non committare mai credenziali reali**.

---

## 🎯 Stato del Progetto

### ✅ Completato (Novembre 2025)

- [x] 🏗️ Setup repository strutturato
- [x] 📚 Piano operativo completo multi-tenant
- [x] 🚀 Quick Start guide automatizzata
- [x] 🤖 Workflow n8n WhatsApp Multi-Tenant Orchestrator
- [x] 🔄 Circuit breaker e retry logic
- [x] 📤 Sistema escalation automatica
- [x] 📝 Documentazione completa setup
- [x] 🔐 Template credenziali e secrets management
- [x] 🌐 DNS configuration per n8n.waipro.it
- [x] 🛠️ Script setup automatico interattivo

### 🚧 In Progress

- [ ] 🔐 Setup Auth0 per social login
- [ ] 🎨 Integrazione OpenWeb UI
- [ ] 🤖 Automazione Comet.ai Pro
- [ ] 🖥️ Deploy VPS Hostinger
- [ ] 🧪 Testing sistema completo

### 📅 Planned

- [ ] 📊 Dashboard monitoring e metriche
- [ ] 🔊 Voice input/output con Whisper
- [ ] 📸 Analisi immagini GPT-4 Vision
- [ ] 📱 App mobile per operatori
- [ ] 🌍 Multi-language support
- [ ] 📹 Video tutorial completo

---

## 📞 Supporto

### Domini WAIPRO

- **n8n.waipro.it** - Server automazione n8n
  - **DNS Configuration (Completato 2025-10-26)**:
    - Record Type: AAAA
    - Name: n8n
    - Value: 2a02:4780:41:9001::1
    - TTL: 600 seconds
    - Status: ✅ Propagato globalmente
    - Verifica: [DNSChecker](https://dnschecker.org/#AAAA/n8n.waipro.it)

- **t.waipro.it** - Admin: `admin@waipro.it` / `Benessere84++`

### Contatti

- **Email**: info@waipro.it
- **GitHub**: https://github.com/Waipro-agency
- **Issues**: https://github.com/Waipro-agency/waipro-knowledge-base/issues

---

## 🤝 Contributing

Contribuzioni benvenute! Segui questi step:

1. Fork il repository
2. Crea branch feature (`git checkout -b feature/amazing-feature`)
3. Commit modifiche (`git commit -m 'Add amazing feature'`)
4. Push al branch (`git push origin feature/amazing-feature`)
5. Apri Pull Request

### Guidelines

- 📝 Aggiorna sempre la documentazione
- ✅ Testa le modifiche prima di committare
- 🔒 Non committare credenziali o secrets
- 📋 Usa commit messages descrittivi

---

## 📄 License

MIT License - Usa liberamente in progetti.
Vedi [LICENSE](./LICENSE) per dettagli.

---

## 🙏 Credits

### Tools Utilizzati

- **Base44 SDK**: https://github.com/Ai-Automators/base44-to-supabase-sdk
- **Base44 Docs Tool**: https://github.com/Uricorn/base44-docs-tool
- **n8n**: https://n8n.io
- **Supabase**: https://supabase.com
- **Claude AI**: https://claude.ai

### Contributors

- [@Waipro-agency](https://github.com/Waipro-agency)

---

**Creato e mantenuto da WAIPRO Agency** 🚀

*Last Updated: 2025-10-26*
