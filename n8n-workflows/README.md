# n8n Workflows per WAIPRO

## Workflow Disponibili

### 1. base44-supabase-workflow.json
**Sync Base44 ↔ Supabase**

**Trigger**: Webhook POST
**Endpoint**: `/webhook/base44-webhook`

**Input**:
```json
{
  "table": "table_name",
  "data": {
    "field1": "value1",
    "field2": "value2"
  }
}
```

**Output**:
```json
{
  "success": true,
  "data": { ... }
}
```

**Use Case**: Sincronizzare dati tra Base44 app e Supabase database

---

### 2. base44-ai-agent-workflow.json
**AI Agent con OpenAI + MCP**

**Trigger**: Webhook POST
**Endpoint**: `/webhook/ai-agent`

**Input**:
```json
{
  "entity": "products",
  "id": "product_id_123"
}
```

**Flow**:
1. Get data from Supabase
2. Process with OpenAI GPT-4
3. Save AI analysis
4. Return results

**Output**:
```json
{
  "success": true,
  "analysis": {
    "entity_id": "123",
    "analysis": "AI generated text...",
    "created_at": "2025-10-26T..."
  }
}
```

**Use Case**: Analisi automatica di dati con AI, report generation, data enrichment

---

## Come Importare

1. Login a n8n: https://n8n.waipro.it
2. Menu → Workflows → Import from File
3. Seleziona file .json
4. Configurare credentials:
   - Supabase API key
   - OpenAI API key

---

## Credenziali Necessarie

### Supabase
```
Type: HTTP Header Auth
Header Name: apikey
Header Value: YOUR_SUPABASE_ANON_KEY

+ Authorization header
Bearer YOUR_SUPABASE_SERVICE_ROLE_KEY (per admin operations)
```

### OpenAI
```
Type: OpenAI
API Key: sk-...
```

---

## Testare Workflow

### Test base44-supabase-workflow:
```bash
curl -X POST https://n8n.waipro.it/webhook/base44-webhook \
  -H "Content-Type: application/json" \
  -d '{
    "table": "test_table",
    "data": {"name": "Test", "value": 123}
  }'
```

### Test base44-ai-agent-workflow:
```bash
curl -X POST https://n8n.waipro.it/webhook/ai-agent \
  -H "Content-Type: application/json" \
  -d '{
    "entity": "blog_posts",
    "id": "post_123"
  }'
```

---

## Personalizzare Workflow

### Cambiare Modello AI
Nel nodo "OpenAI GPT":
```javascript
model: "gpt-4"  // oppure "gpt-3.5-turbo", "gpt-4-turbo", etc.
temperature: 0.7  // 0-1, più alto = più creativo
```

### Modificare Prompt
Nel nodo "OpenAI GPT", campo messages:
```javascript
{
  "role": "system",
  "content": "Your custom system prompt here"
},
{
  "role": "user",
  "content": "Your user prompt with data: {{$json.data}}"
}
```

### Aggiungere Email Notification
1. Aggiungi nodo "Send Email"
2. Connetti dopo "Save AI Analysis"
3. Configura SMTP credentials
4. Set recipient, subject, body

---

## Best Practices

1. **Error Handling**: Aggiungi nodi "Error Trigger" per catch errors
2. **Logging**: Abilita execution logging in Settings
3. **Testing**: Testa workflow in modalità manuale prima di attivare webhook
4. **Credentials**: Usa sempre credential manager di n8n, mai hardcode
5. **Rate Limiting**: Considera rate limits di API esterne (OpenAI, Supabase)

---

## Workflow Template da Creare

### Idee per nuovi workflow:

1. **Email Automation**
   - Trigger: New Supabase row
   - Action: Send welcome email

2. **Data Enrichment**
   - Trigger: New user signup
   - Action: Get additional data from APIs, update user profile

3. **Scheduled Reports**
   - Trigger: Cron schedule (daily/weekly)
   - Action: Generate analytics report, send via email

4. **Webhook → Slack**
   - Trigger: Important event in Base44
   - Action: Post notification to Slack channel

5. **File Processing**
   - Trigger: File upload to Supabase Storage
   - Action: Process file with AI, extract data, save to database

---

## Debugging

### View Execution Log
1. In n8n UI, vai a "Executions"
2. Click su execution per vedere dettagli
3. Ogni nodo mostra input/output data

### Common Issues

**"Table does not exist"**
- Verifica nome tabella in Supabase
- Check credentials (service role vs anon key)

**"OpenAI API error"**
- Verifica API key valida
- Check quota OpenAI account
- Verifica rate limits

**"Webhook timeout"**
- Aumenta timeout in n8n settings
- Ottimizza workflow (riduci operazioni pesanti)
- Usa async processing per task lunghi

---

## Resources

- n8n Docs: https://docs.n8n.io
- Workflow Examples: https://n8n.io/workflows
- Supabase API: https://supabase.com/docs/reference/javascript
- OpenAI API: https://platform.openai.com/docs/api-reference

---

**Maintainer**: WAIPRO Agency
**Last Updated**: 2025-10-26
