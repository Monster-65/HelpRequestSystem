# 🚀 QUICKSTART - HelpRequestSystem Cartella Condivisa

## 📋 IN 3 PASSI

### 1️⃣ TEST LOCALE (Linux)

```bash
# Setup e test con cartella temporanea
./test_locale.sh

# Terminal 1
cd Server && dotnet run

# Terminal 2  
cd Client && dotnet run
```

### 2️⃣ BUILD PER WINDOWS

```bash
./build_windows.sh
```

Output: `build_windows/Server/` e `build_windows/Client/`

### 3️⃣ DEPLOY SU WINDOWS

#### Sul PC che ospita la cartella condivisa:

```cmd
# 1. Crea cartella
mkdir C:\HelpRequests

# 2. Condividi
Click destro → Proprietà → Condivisione → Condividi
Aggiungi "Everyone" con permessi "Modifica"

# 3. Annota il percorso
\\192.168.0.114\HelpRequests
```

#### Sul PC Master (server):

```cmd
# 1. Copia la cartella build_windows/Server
# 2. Modifica server_config.json:
{
  "SharePath": "C:\\HelpRequests"    ← Percorso locale
  ...oppure...
  "SharePath": "\\\\IP\\HelpRequests" ← Percorso di rete
}

# 3. Avvia
start_server.bat
```

#### Sui PC Utenti (client):

```cmd
# 1. Copia la cartella build_windows/Client
# 2. Modifica client_config.json:
{
  "SharePath": "\\\\192.168.0.114\\HelpRequests"
}

# 3. Avvia
start_client.bat
```

---

## ✅ VERIFICA FUNZIONAMENTO

1. Dal client, inserisci nome e messaggio
2. Clicca "Invia Richiesta"
3. La richiesta appare sul server entro 1-2 secondi
4. Controlla i log: `server_log.txt` e `client_log.txt`

---

## 🐛 TROUBLESHOOTING VELOCE

| Problema | Soluzione |
|----------|-----------|
| "Cartella non accessibile" | Verifica che `SharePath` esista e sia accessibile |
| "Permessi insufficienti" | Dai permessi Lettura/Scrittura sulla share |
| "Richieste non arrivano" | Verifica che `SharePath` sia identico in client e server |

### Test manuale:

```cmd
# Windows - Verifica accesso alla share
dir \\192.168.0.114\HelpRequests

# Dovrebbe mostrare il contenuto senza errori
```

---

## 📚 DOCUMENTAZIONE COMPLETA

- `README_SHARE.md` - Guida completa
- `SOLUZIONE_FIREWALL_AZIENDALE.md` - Alternative e confronti

---

## 🎯 VANTAGGI QUESTA VERSIONE

| ✅ Pro | ❌ Contro |
|--------|-----------|
| Nessuna porta di rete | Latenza ~2 secondi |
| Nessun firewall da configurare | Serve cartella condivisa |
| Funziona sempre | Non real-time |
| File = log automatici | Richiede permessi Windows |

---

## 💡 SUGGERIMENTI

### Per test veloce:
```bash
./test_locale.sh  # Setup automatico con cartella temporanea
```

### Per produzione:
1. Usa cartella locale sul Master: `C:\HelpRequests`
2. Condividila in rete
3. I client accedono via rete: `\\IP\HelpRequests`

### Configurazione ottimale:
- `PollIntervalSeconds: 2` (bilanciato)
- `AutoDeleteProcessedFiles: true` (pulisce automaticamente)

---

## 🆘 SUPPORTO

Per problemi, controlla:
1. Log files (`*_log.txt`)
2. Accesso alla share (`dir \\IP\Share`)
3. Permessi (Everyone = Modifica)
4. Percorsi identici in client e server

**Documentazione:** `README_SHARE.md`
