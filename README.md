# 🚀 WAIPRO Knowledge Base

> **Documentazione centralizzata e sistema RAG per Base44, n8n, MCP e automazioni AI**

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
│   ├── RAG-SYSTEM-SETUP.md
│   ├── GITHUB-AUDIT-REPORT.md
│   └── CHANGELOG.md
│
├── CONFIG/                      # ⚙️ Configurazioni
│   ├── credentials.env.template # Template credenziali
│   └── .gitkeep
│
├── MCP/                         # 🤖 Model Context Protocol Server
│   ├── index.js                 # Server MCP
│   ├── package.json             # Dipendenze
│   ├── README.md                # Guida MCP
│   └── node_modules/
│
├── base44-sdk/                  # 📦 SDK Base44 → Supabase
│   └── [repository clonato]
│
├── base44-docs/                 # 📖 Tool Documentazione Base44
│   ├── b44                      # CLI tool
│   └── [repository clonato]
│
└── scripts/                     # 🔧 Utility Scripts
    ├── sync-knowledge.sh        # Sync automatico
    ├── generate-embeddings.js   # RAG embeddings
    └── docs-api-server.js       # API docs (opzionale)
```

---

## 🚀 Quick Start

### Prerequisiti

- **Node.js** 18+ (`node --version`)
- **npm** o **yarn**
- **Git**
- **Supabase Account** (per Base44)
- **GitHub CLI** (`gh`) - opzionale ma consigliato

### Installazione

```bash
# 1. Clona il repository
git clone https://github.com/Waipro-agency/waipro-knowledge-base.git
cd waipro-knowledge-base

# 2. Setup MCP Server
cd MCP
npm install
chmod +x index.js

# 3. Configura credenziali
cd ../CONFIG
cp credentials.env.template credentials.env
# Edita credentials.env con i tuoi valori reali

# 4. Test Base44 docs tool
cd ../base44-docs
./b44 stats
./b44 search "authentication"

# 5. (Opzionale) Setup sync automatico
cd ../scripts
chmod +x sync-knowledge.sh
# Aggiungi a crontab: 0 */6 * * * /path/to/sync-knowledge.sh
```

### Verifica Installazione

```bash
# Test MCP server
cd ~/WAPRO/MCP
node index.js
# Output: "MCP Filesystem Server avviato"

# Test Base44 tool
cd ~/WAPRO/base44-docs
./b44 search "setup"

# Verifica configurazione
cat ~/WAPRO/CONFIG/credentials.env.template
```

---

## 📚 Documentazione

### Guide Principali

1. **[MASTER GUIDE](./DOCS/MASTER-GUIDE-BASE44-N8N-MCP.md)**
   - Setup completo Base44 + n8n + MCP
   - Integrazione end-to-end
   - Best practices e troubleshooting

2. **[RAG System Setup](./DOCS/RAG-SYSTEM-SETUP.md)**
   - Sistema di retrieval-augmented generation
   - Sync automatico documentazione
   - Embedding e vector search

3. **[GitHub Audit Report](./DOCS/GITHUB-AUDIT-REPORT.md)**
   - Analisi repository esistenti
   - Action plan per organizzazione
   - Security audit

### Link Rapidi

| Risorsa | Descrizione | Link |
|---------|-------------|------|
| Base44 Docs | Documentazione ufficiale | https://docs.base44.com |
| n8n Docs | Workflow automation | https://docs.n8n.io |
| Supabase Docs | Backend e database | https://supabase.com/docs |
| MCP Protocol | Model Context Protocol | Locale in `./MCP/` |

---

## 🛠️ Tool e Risorse

### Base44 Docs Tool

```bash
# Ricerca documentazione
./base44-docs/b44 search "your query"

# Ricerca con filtro sezione
./base44-docs/b44 s "Google login" -s Integrations

# Ottieni pagina specifica
./base44-docs/b44 get "/Guides/Setting-up-SSO"

# Aggiorna documentazione
./base44-docs/b44 scrape

# Risposta AI-formatted
./base44-docs/b44 ai-answer "How to setup payments?"
```

### MCP Server

**Strumenti disponibili per Claude Desktop**:

- `read_file` - Leggi file
- `write_file` - Scrivi file
- `list_directory` - Lista directory
- `create_directory` - Crea directory
- `delete_file` - Elimina file/dir
- `execute_command` - Esegui comandi shell
- `file_info` - Info file/dir

**Configurazione Claude Desktop** (`~/Library/Application Support/Claude/claude_desktop_config.json`):

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

### Base44 SDK

```javascript
// Il tuo codice Base44 esistente funziona inalterato
import { BlogPost, User, Product } from "./src/api/entities";

const posts = await BlogPost.list("-created_date");
const user = await User.me();
const products = await Product.filter({ status: "active" });
```

---

## ⚙️ Configurazione

### Environment Variables

Copia il template e configura i tuoi valori:

```bash
cp CONFIG/credentials.env.template CONFIG/credentials.env
```

**Variabili principali**:

```env
# Supabase / Base44
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
VITE_SUPABASE_SERVICE_ROLE_KEY=...

# n8n
N8N_URL=https://n8n.waipro.it
N8N_API_KEY=...

# AI Services
OPENAI_API_KEY=...
ANTHROPIC_API_KEY=...

# Domini WAIPRO
# n8n.waipro.it - n8n automation
# t.waipro.it - admin@waipro.it / Benessere84++
```

### Sicurezza

⚠️ **IMPORTANTE**:
- Non committare MAI `credentials.env` in Git
- Usa `.gitignore` per escludere file sensibili
- Ruota le chiavi API periodicamente
- Usa environment variables in production

---

## 🤝 Contributing

### Workflow

1. **Fork** questo repository
2. **Crea branch** feature (`git checkout -b feature/amazing-feature`)
3. **Commit** modifiche (`git commit -m 'Add amazing feature'`)
4. **Push** al branch (`git push origin feature/amazing-feature`)
5. **Apri Pull Request**

### Conventional Commits

Usa prefissi standard:

- `feat:` - Nuova feature
- `fix:` - Bug fix
- `docs:` - Documentazione
- `style:` - Formattazione
- `refactor:` - Refactoring codice
- `test:` - Test
- `chore:` - Manutenzione

Esempio: `docs: update Base44 migration guide`

### Aggiornare Documentazione

```bash
# 1. Modifica i file in DOCS/
vim DOCS/MASTER-GUIDE-BASE44-N8N-MCP.md

# 2. Testa localmente

# 3. Commit
git add DOCS/
git commit -m "docs: update Base44 setup instructions"

# 4. Push
git push origin main

# 5. (Opzionale) Rigenera embeddings
node scripts/generate-embeddings.js
```

---

## 📊 Roadmap

### ✅ Completato

- [x] Setup repository strutturato
- [x] Creazione guida master
- [x] MCP server funzionante
- [x] Base44 docs tool integrato
- [x] Template credenziali
- [x] GitHub audit completo

### 🚧 In Progress

- [ ] Deploy n8n.waipro.it
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

- **n8n.waipro.it** - Server automazione n8n (da configurare)
- **t.waipro.it** - Admin: `admin@waipro.it` / `Benessere84++`

### Contatti

- **Email**: info@waipro.it
- **GitHub**: https://github.com/Waipro-agency
- **Issues**: https://github.com/Waipro-agency/waipro-knowledge-base/issues

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

