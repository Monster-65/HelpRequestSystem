# ⚡ GUIDA PERFORMANCE BUILD WINDOWS

## 🤔 PERCHÉ LA BUILD È LENTA?

### **La build self-contained scarica il runtime Windows:**

```
Prima build:    2-10 minuti ⏱️  (download ~200MB)
Build successive: 30-60 secondi 🚀 (runtime in cache)
```

**Cosa viene scaricato:**
- Runtime .NET per Windows (x64)
- Librerie ASP.NET Core
- Dipendenze native Windows
- **Totale: ~200MB** dalla rete

---

## 🎯 SOLUZIONI DISPONIBILI

### **1️⃣ Build Self-Contained (LENTA ma COMPLETA)**

```bash
./build_windows.sh
```

**Quando usarla:**
- ✅ **NON puoi installare .NET** sui PC Windows
- ✅ Deploy in produzione (funziona ovunque)
- ✅ PC senza internet/permessi

**Caratteristiche:**
- ⏱️ Prima build: 2-10 minuti
- ⚡ Build successive: 30-60 secondi (cache)
- 📦 Output: ~70MB per applicazione
- 🚫 Non richiede .NET su Windows

---

### **2️⃣ Build Veloce (RAPIDA ma richiede .NET)**

```bash
./build_windows_fast.sh
```

**Quando usarla:**
- ✅ **Puoi installare .NET** sui PC Windows
- ✅ Test e sviluppo rapido
- ✅ Connessione internet lenta

**Caratteristiche:**
- ⚡ Build: 5-10 secondi sempre
- 📦 Output: ~29MB per applicazione
- ✔️ Richiede .NET 9 su Windows
- 💾 Download .NET: https://dot.net

---

## 🚀 OTTIMIZZAZIONI

### **A) Pre-caricare la cache (CONSIGLIATO)**

Scarica i runtime Windows UNA VOLTA, poi le build saranno veloci:

```bash
./gestisci_cache.sh
# Scegli opzione 2: "Pre-carica runtime Windows"
```

Dopo questo comando:
- Prima build normale: 2-10 minuti
- **Tutte le successive: 30-60 secondi** 🚀

---

### **B) Verifica stato cache**

```bash
./gestisci_cache.sh
# Scegli opzione 3: "Mostra dettagli cache"
```

Mostra:
- Dimensione cache attuale
- Runtime Windows presenti
- Spazio occupato

---

### **C) Pulisci cache (se problemi)**

```bash
./gestisci_cache.sh
# Scegli opzione 1: "Pulisci cache"
```

Utile se:
- Build corrotte
- Errori strani di compilazione
- Vuoi liberare spazio

⚠️ **Attenzione**: La prossima build ricaricherà tutto!

---

## 📊 CONFRONTO VELOCITÀ

| Metodo | Prima Build | Build Successive | Output | .NET Richiesto |
|--------|-------------|------------------|--------|----------------|
| **Self-contained** | 2-10 min | 30-60 sec | 70MB | ❌ No |
| **Self-contained (con cache)** | 30-60 sec | 30-60 sec | 70MB | ❌ No |
| **Veloce** | 5-10 sec | 5-10 sec | 29MB | ✅ Sì |

---

## 🎯 STRATEGIA CONSIGLIATA

### **Per Sviluppo/Test:**

```bash
# 1. Usa build veloce
./build_windows_fast.sh

# 2. Installa .NET 9 sui PC Windows:
# https://dotnet.microsoft.com/download/dotnet/9.0
# Scarica "NET 9.0 Runtime" (non SDK)
```

### **Per Produzione:**

```bash
# 1. Pre-carica cache (una volta sola)
./gestisci_cache.sh
# Opzione 2

# 2. Build self-contained (ora veloce!)
./build_windows.sh
# ~30-60 secondi invece di 10 minuti

# 3. Deploy sui PC Windows (senza .NET)
```

---

## 💡 TIPS EXTRA

### **Accelerare download NuGet:**

Se la connessione è lenta, aumenta timeout:

```bash
# Aggiungi al tuo ~/.bashrc o esegui prima della build:
export NUGET_HTTP_REQUEST_TIMEOUT=600  # 10 minuti invece di default
```

### **Build offline (dopo prima build):**

Dopo che la cache è pronta, puoi compilare senza internet:

```bash
# Disconnetti WiFi
./build_windows.sh  # Usa solo cache locale
```

### **Verificare cosa sta scaricando:**

```bash
# Durante la build, in altro terminal:
watch -n 1 'du -sh ~/.nuget/packages'
# Vedi la cache crescere in real-time
```

---

## 🐛 TROUBLESHOOTING

### **Problema: Build va in timeout**

```bash
# Soluzione 1: Aumenta timeout
export DOTNET_HTTPCLIENT_TIMEOUT=600

# Soluzione 2: Pre-carica cache
./gestisci_cache.sh  # Opzione 2

# Soluzione 3: Usa build veloce
./build_windows_fast.sh
```

### **Problema: Errori strani durante build**

```bash
# Pulisci tutto e riprova
./gestisci_cache.sh  # Opzione 1 (pulisci)
rm -rf build_windows/
./build_windows.sh
```

### **Problema: "A task was canceled"**

Connessione troppo lenta per scaricare 200MB:

```bash
# OPZIONE A: Usa build veloce
./build_windows_fast.sh

# OPZIONE B: Scarica in più tentativi
./gestisci_cache.sh  # Opzione 2
# Se fallisce, riprova finché completata

# OPZIONE C: Build su PC con connessione migliore
```

---

## 📁 PERCORSO CACHE

```bash
# Cache NuGet globale:
~/.nuget/packages/

# Runtime Windows specifici:
~/.nuget/packages/microsoft.netcore.app.runtime.win-x64/
~/.nuget/packages/microsoft.aspnetcore.app.runtime.win-x64/

# Dimensione tipica cache completa:
~500MB - 1GB
```

---

## 🎓 PERCHÉ BUILD VELOCE È VELOCE?

**Build Self-Contained:**
```
dotnet publish --self-contained true
└─> Scarica runtime Windows (~200MB)
└─> Include tutto nell'output (~70MB)
└─> Windows PC: Non serve .NET ✅
```

**Build Veloce:**
```
dotnet publish --self-contained false
└─> Non scarica runtime (0MB)
└─> Output solo codice (~29MB)
└─> Windows PC: Serve .NET ⚠️
```

---

## 🚀 RIEPILOGO COMANDI

```bash
# Build completa self-contained
./build_windows.sh

# Build veloce (richiede .NET su Windows)
./build_windows_fast.sh

# Gestisci cache NuGet
./gestisci_cache.sh

# Pre-carica runtime (una volta)
./gestisci_cache.sh  # Opzione 2

# Verifica cache
./gestisci_cache.sh  # Opzione 3
```

---

**CONSIGLIO FINALE:**

Esegui **UNA VOLTA** il pre-caricamento:
```bash
./gestisci_cache.sh  # Opzione 2
```

Poi le build self-contained saranno **sempre veloci** (30-60 sec)! 🚀
