# 🚀 WAIPRO Knowledge Base
> 
**Documentazione centralizzata e sistema RAG per Base44, n8n, MCP e automazioni AI**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status](https://img.shields.io/badge/Status-Active-success)]()
[![Last Updated](https://img.shields.io/badge/Updated-2025--10--26-blue)]()

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

### Prerequisiti

```bash
# Software necessario
- Git
- Node.js 18+
- Docker & Docker Compose
- Un account Base44
- Un progetto Supabase
```

### Setup Rapido

1. **Clone repository**
```bash
git clone https://github.com/Waipro-agency/waipro-knowledge-base.git
cd waipro-knowledge-base
```

2. **Setup credenziali**
```bash
cp CONFIGS/.env.example CONFIGS/.env
# Modifica CONFIGS/.env con le tue credenziali
```

3. **Installa dipendenze**
```bash
npm install
```

4. **Avvia i servizi**
```bash
docker-compose up -d
```

---

## 📚 Documentazione

### Guide Principali

1. **[MASTER GUIDE](./DOCS/MASTER-GUIDE-BASE44-N8N-MCP.md)** - Punto di partenza completo
2. **[Base44 + Supabase](./DOCS/BASE44/)** - Migrazione e SDK
3. **[n8n Automation](./DOCS/N8N/)** - Workflows e integrazioni
4. **[MCP Setup](./DOCS/MCP/)** - Server e tools
5. **[DNS Configuration](./ISTRUZIONI-DNS-GODADDY.md)** - Setup DNS su GoDaddy

### Per chi inizia

📖 Leggi prima la **[MASTER GUIDE](./DOCS/MASTER-GUIDE-BASE44-N8N-MCP.md)** per una panoramica completa dell'ecosistema

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

### ✅ Completato

- [x] Setup repository strutturato
- [x] Creazione guida master
- [x] MCP server funzionante
- [x] Base44 docs tool integrato
- [x] Template credenziali
- [x] GitHub audit completo
- [x] DNS configuration per n8n.waipro.it

### 🚧 In Progress

- [ ] Verifica accesso t.waipro.it
- [ ] Setup RAG system completo
- [ ] Generazione embeddings
- [ ] CI/CD pipeline

### 📅 Planned

- [ ] Dashboard gestione docs
- [ ] Integrazione n8n ↔ Base44 ↔ MCP
- [ ] Workflow templates pronti
- [ ] Video tutorial
- [ ] API REST per documentazione

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
