# 🧠 Sistema RAG (Retrieval-Augmented Generation)

## Obiettivo

Creare un sistema di documentazione centralizzato che permette a tutti gli agenti AI di:
1. Accedere sempre alle informazioni più aggiornate
2. Non dover fare copia-incolla continuo
3. Mantenere la knowledge base sincronizzata automaticamente

---

## 📁 Struttura Directory

```
~/WAPRO/
├── DOCS/                              # Documentazione centralizzata
│   ├── MASTER-GUIDE-BASE44-N8N-MCP.md # Guida principale
│   ├── RAG-SYSTEM-SETUP.md           # Questo file
│   ├── CHANGELOG.md                   # Log modifiche
│   └── snippets/                      # Code snippets riutilizzabili
│       ├── base44/
│       ├── n8n/
│       └── mcp/
├── CONFIG/                            # Configurazioni
│   ├── credentials.env.template
│   └── credentials.env (gitignored)
├── base44-sdk/                        # SDK Base44
├── base44-docs/                       # Tool documentazione Base44
└── MCP/                               # Server MCP
```

---

## 🔄 Sistema di Aggiornamento Automatico

### 1. Git come Source of Truth

```bash
# Repository GitHub
cd ~/WAPRO
git init
git remote add origin https://github.com/Waipro-agency/waipro-knowledge-base.git

# Commit iniziale
git add .
git commit -m "Initial knowledge base setup"
git push -u origin main
```

### 2. Script di Sync Automatico

**File**: `~/WAPRO/sync-knowledge.sh`

```bash
#!/bin/bash

REPO_DIR="$HOME/WAPRO"
LOG_FILE="$REPO_DIR/DOCS/sync.log"

echo "[$(date)] Starting knowledge base sync..." >> "$LOG_FILE"

cd "$REPO_DIR" || exit 1

# Pull latest changes
git pull origin main >> "$LOG_FILE" 2>&1

# Update Base44 docs
if [ -f "$REPO_DIR/base44-docs/b44" ]; then
    echo "[$(date)] Updating Base44 documentation..." >> "$LOG_FILE"
    "$REPO_DIR/base44-docs/b44" scrape >> "$LOG_FILE" 2>&1
fi

# Commit changes if any
if [[ `git status --porcelain` ]]; then
    git add .
    git commit -m "Auto-update: $(date +%Y-%m-%d)"
    git push origin main >> "$LOG_FILE" 2>&1
    echo "[$(date)] Changes pushed to repository" >> "$LOG_FILE"
else
    echo "[$(date)] No changes detected" >> "$LOG_FILE"
fi

echo "[$(date)] Sync complete" >> "$LOG_FILE"
```

**Rendere eseguibile**:
```bash
chmod +x ~/WAPRO/sync-knowledge.sh
```

### 3. Cron Job per Sync Automatico

```bash
# Apri crontab
crontab -e

# Aggiungi job per sync ogni 6 ore
0 */6 * * * /Users/YOUR_USERNAME/WAPRO/sync-knowledge.sh
```

---

## 🔍 Accesso RAG per Agenti AI

### Metodo 1: MCP Read Access

Gli agenti AI possono usare MCP per leggere la documentazione:

```javascript
// Agente AI usa MCP per leggere la guida
const guide = await mcp.read_file({
  path: "/Users/YOUR_USERNAME/WAPRO/DOCS/MASTER-GUIDE-BASE44-N8N-MCP.md"
});
```

### Metodo 2: Base44 Docs Tool

```bash
# Cerca informazioni specifiche
~/WAPRO/base44-docs/b44 search "authentication setup"

# Output strutturato per AI
~/WAPRO/base44-docs/b44 ai-answer "How to setup Google SSO?"
```

### Metodo 3: API REST (Opzionale)

Creare un semplice server REST che serve la documentazione:

**File**: `~/WAPRO/docs-api-server.js`

```javascript
const express = require('express');
const fs = require('fs');
const path = require('path');
const app = express();

const DOCS_DIR = path.join(__dirname, 'DOCS');

// Endpoint per ottenere documentazione
app.get('/api/docs/:filename', (req, res) => {
  const filePath = path.join(DOCS_DIR, req.params.filename);

  if (fs.existsSync(filePath)) {
    const content = fs.readFileSync(filePath, 'utf8');
    res.json({ content, filename: req.params.filename });
  } else {
    res.status(404).json({ error: 'File not found' });
  }
});

// Endpoint per cercare nella documentazione
app.get('/api/search', (req, res) => {
  const query = req.query.q;
  // Implementa ricerca full-text
  // ...
});

app.listen(3001, () => {
  console.log('Docs API server running on http://localhost:3001');
});
```

---

## 📚 Indexing per Ricerca Veloce

### Usando Supabase per Vector Search

```sql
-- Abilita estensione pgvector
CREATE EXTENSION vector;

-- Tabella per knowledge base
CREATE TABLE knowledge_base (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT, -- 'base44', 'n8n', 'mcp', 'config'
  tags TEXT[],
  embedding vector(1536), -- OpenAI embeddings
  metadata JSONB
);

-- Index per ricerca vettoriale
CREATE INDEX ON knowledge_base USING ivfflat (embedding vector_cosine_ops);

-- Full-text search
CREATE INDEX knowledge_base_content_idx ON knowledge_base
  USING gin(to_tsvector('english', content));
```

### Script per Generare Embeddings

**File**: `~/WAPRO/generate-embeddings.js`

```javascript
import { createClient } from '@supabase/supabase-js';
import OpenAI from 'openai';
import fs from 'fs';
import path from 'path';

const supabase = createClient(process.env.VITE_SUPABASE_URL, process.env.VITE_SUPABASE_SERVICE_ROLE_KEY);
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

async function generateEmbedding(text) {
  const response = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: text,
  });
  return response.data[0].embedding;
}

async function indexDocumentation() {
  const docsDir = path.join(process.env.HOME, 'WAPRO', 'DOCS');
  const files = fs.readdirSync(docsDir).filter(f => f.endsWith('.md'));

  for (const file of files) {
    const filePath = path.join(docsDir, file);
    const content = fs.readFileSync(filePath, 'utf8');

    // Genera embedding
    const embedding = await generateEmbedding(content);

    // Salva in Supabase
    await supabase.from('knowledge_base').upsert({
      title: file,
      content: content,
      category: detectCategory(file),
      tags: extractTags(content),
      embedding: embedding,
      metadata: {
        filename: file,
        size: content.length,
        lastModified: fs.statSync(filePath).mtime
      }
    });

    console.log(`Indexed: ${file}`);
  }
}

function detectCategory(filename) {
  if (filename.includes('base44')) return 'base44';
  if (filename.includes('n8n')) return 'n8n';
  if (filename.includes('mcp')) return 'mcp';
  return 'general';
}

function extractTags(content) {
  // Estrai tag comuni dal contenuto
  const tags = [];
  if (content.includes('authentication')) tags.push('auth');
  if (content.includes('deployment')) tags.push('deploy');
  if (content.includes('API')) tags.push('api');
  // ... più logica di estrazione
  return tags;
}

// Esegui indexing
indexDocumentation().catch(console.error);
```

---

## 🤖 Uso del RAG da Parte degli Agenti

### Prompt Template per Agenti

```markdown
Quando lavori su task relativi a WAIPRO/Base44/n8n/MCP:

1. PRIMA controlla la knowledge base:
   - Leggi ~/WAPRO/DOCS/MASTER-GUIDE-BASE44-N8N-MCP.md
   - Cerca informazioni specifiche con ~/WAPRO/base44-docs/b44 search
   - Verifica credentials in ~/WAPRO/CONFIG/credentials.env.template

2. Usa le informazioni trovate piuttosto che inventare

3. Se la documentazione è incompleta o datata:
   - Aggiorna la documentazione
   - Fai commit delle modifiche
   - Esegui ~/WAPRO/sync-knowledge.sh

4. IMPORTANTE: Mantieni sempre la knowledge base aggiornata
```

### Esempio Query RAG

```python
# Python script per query semantica
import os
from supabase import create_client
from openai import OpenAI

supabase = create_client(os.getenv('VITE_SUPABASE_URL'), os.getenv('VITE_SUPABASE_SERVICE_ROLE_KEY'))
openai_client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

def search_knowledge_base(query, limit=5):
    # Genera embedding della query
    query_embedding = openai_client.embeddings.create(
        model='text-embedding-3-small',
        input=query
    ).data[0].embedding

    # Ricerca vettoriale in Supabase
    result = supabase.rpc('match_knowledge', {
        'query_embedding': query_embedding,
        'match_threshold': 0.78,
        'match_count': limit
    }).execute()

    return result.data

# Uso
results = search_knowledge_base("How to setup Google authentication in Base44?")
for doc in results:
    print(f"Title: {doc['title']}")
    print(f"Content: {doc['content'][:200]}...")
    print(f"Similarity: {doc['similarity']}")
    print("---")
```

---

## 📊 Dashboard per Knowledge Base

### Creare pagina Base44 per gestione docs

```javascript
// ~/WAPRO/knowledge-dashboard/DocsManager.jsx

import { useState, useEffect } from 'react';
import { supabase } from './supabaseClient';

export default function DocsManager() {
  const [docs, setDocs] = useState([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    loadDocs();
  }, []);

  async function loadDocs() {
    const { data } = await supabase
      .from('knowledge_base')
      .select('*')
      .order('updated_at', { ascending: false });
    setDocs(data);
  }

  async function searchDocs() {
    const { data } = await supabase
      .from('knowledge_base')
      .select('*')
      .textSearch('content', search);
    setDocs(data);
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Knowledge Base Manager</h1>

      <div className="mb-4">
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search documentation..."
          className="border p-2 w-full"
        />
        <button onClick={searchDocs} className="mt-2 bg-blue-500 text-white px-4 py-2">
          Search
        </button>
      </div>

      <div className="grid gap-4">
        {docs.map(doc => (
          <div key={doc.id} className="border p-4 rounded">
            <h3 className="font-bold">{doc.title}</h3>
            <p className="text-sm text-gray-600">
              Category: {doc.category} | Updated: {new Date(doc.updated_at).toLocaleString()}
            </p>
            <p className="mt-2 text-sm">{doc.content.substring(0, 200)}...</p>
            <div className="mt-2">
              {doc.tags?.map(tag => (
                <span key={tag} className="inline-block bg-gray-200 px-2 py-1 text-xs mr-2">
                  {tag}
                </span>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

## ✅ Checklist Setup RAG

- [ ] Repository GitHub creato
- [ ] Script sync-knowledge.sh creato e testato
- [ ] Cron job configurato
- [ ] Tabella knowledge_base in Supabase creata
- [ ] Script generate-embeddings.js creato
- [ ] Embeddings iniziali generati
- [ ] Dashboard docs manager creato (opzionale)
- [ ] Documentazione testata dagli agenti AI
- [ ] Workflow di aggiornamento documentato

---

## 🔄 Workflow di Manutenzione

### Giornaliero (Automatico)
- Sync con GitHub
- Update Base44 docs
- Backup database

### Settimanale (Manuale)
- Review documentation changes
- Update embeddings se necessario
- Cleanup documenti obsoleti

### Mensile (Manuale)
- Audit completo knowledge base
- Reorganizzare se necessario
- Update tool e dipendenze

---

**Note**: Questo sistema RAG garantisce che tutti gli agenti AI abbiano sempre accesso alle informazioni più aggiornate senza bisogno di copia-incolla manuale.

