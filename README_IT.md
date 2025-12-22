# 🎯 GUIDA RAPIDA - Help Request System

## 📝 Riepilogo delle Correzioni

### ✅ Cosa è stato corretto:

1. **BUG CRITICO**: Client e Server usavano URL diversi
   - ❌ Prima: Client → `http://IP:7777/` | Server → `http://+:7777/api/helprequest/`
   - ✅ Dopo: Entrambi usano `http://IP:7777/api/helprequest/`

2. **Codice Inutile Rimosso**:
   - Rimosso import inutile `System.Net.Sockets` nel server
   - Aggiunta gestione corretta delle risorse con `Stop()`

3. **Miglioramenti Aggiunti**:
   - Logging dettagliato per debug
   - Validazione input nel client
   - Gestione errori più chiara
   - Timeout configurato nel client (10 secondi)
   - Gestione asincrona delle richieste nel server

## 🚀 Come Avviare il Sistema

### Metodo 1: Script Automatici (CONSIGLIATO)

#### Sul Computer SERVER:
```bash
cd /home/king_monster_/Scrivania/HelpRequestSystem/Server
sudo ./start_server.sh
```

#### Sul Computer CLIENT:
```bash
cd /home/king_monster_/Scrivania/HelpRequestSystem/Client
./start_client.sh
```

### Metodo 2: Manuale

#### Server:
```bash
cd /home/king_monster_/Scrivania/HelpRequestSystem/Server
sudo dotnet run
```

#### Client:
```bash
cd /home/king_monster_/Scrivania/HelpRequestSystem/Client
dotnet run
```

## 🌐 Configurazione Rete

### 1. Trova l'IP del Server

Sul computer server:
```bash
hostname -I
```

Esempio output: `192.168.1.22 172.17.0.1`
→ Usa il primo IP (es. `192.168.1.22`)

### 2. Configura il Client

Nell'interfaccia del client, inserisci l'IP del server nel campo "IP del Master"

### 3. Test di Connettività

Dal computer client, verifica la connessione:
```bash
ping 192.168.1.22
```

## 🐛 Risoluzione Problemi Comuni

### ⚠️ "Access to the path is denied" / "Accesso negato"

**Causa**: HttpListener richiede permessi amministrativi

**Soluzione**:
```bash
sudo dotnet run
```

### ⚠️ "Connection refused" / "Connessione rifiutata"

**Possibili cause**:
1. Server non avviato → Avvia il server
2. IP errato → Verifica l'IP con `hostname -I`
3. Firewall locale → Vedi sotto

**Soluzione Firewall (Linux)**:
```bash
# Consenti temporaneamente la porta 7777
sudo iptables -I INPUT -p tcp --dport 7777 -j ACCEPT

# Oppure con ufw:
sudo ufw allow 7777/tcp
```

### ⚠️ "Timeout della connessione"

**Causa**: Server non raggiungibile o troppo lento

**Soluzioni**:
1. Verifica che entrambi i PC siano sulla stessa rete
2. Prova a pingare il server
3. Controlla che non ci siano proxy/VPN attivi

### ⚠️ "Porta già in uso"

**Causa**: Un altro programma usa la porta 7777

**Soluzione**:
```bash
# Trova il processo che usa la porta
sudo netstat -tulpn | grep 7777

# Termina il processo (sostituisci PID)
kill -9 PID
```

## 🧪 Test del Sistema

### Test 1: Verifica Server Attivo

Sul server, dovresti vedere:
```
Server in ascolto su http://+:7777/api/helprequest/
```

### Test 2: Test con curl (Avanzato)

Sul client, testa la connessione (sostituisci l'IP):
```bash
curl -X POST http://192.168.1.22:7777/api/helprequest/ \
  -H "Content-Type: application/json" \
  -d '{"ComputerName":"TestPC","User":"Mario","Message":"Test di connessione","Timestamp":"2025-12-18T10:00:00"}'
```

Se funziona, vedrai la richiesta apparire nel server!

### Test 3: Invio Richiesta dall'Interfaccia

1. Apri il client
2. Inserisci IP del server
3. Inserisci il tuo nome
4. Scrivi un messaggio
5. Clicca "Invia Richiesta"
6. Controlla che appaia nel server

## 📊 Cosa Vedrai

### Sul CLIENT:
- Messaggio: "Richiesta inviata correttamente!" ✅
- In console: URL di destinazione e stato della richiesta

### Sul SERVER:
- La richiesta appare nella lista con:
  - Nome del computer
  - Nome utente
  - Messaggio
  - Timestamp
- In console: Log della richiesta ricevuta

## ⚙️ Note Tecniche

### Porte Utilizzate
- **7777/TCP**: Comunicazione HTTP Client → Server

### Requisiti
- .NET 9.0
- Avalonia UI
- Entrambi i PC sulla stessa rete locale

### Limitazioni Attuali
- ⚠️ **NESSUNA CRITTOGRAFIA**: Dati in chiaro
- ⚠️ **NESSUNA AUTENTICAZIONE**: Chiunque può inviare richieste
- ⚠️ **SOLO RETI PRIVATE**: Non sicuro per Internet

## 📞 In Caso di Problemi

1. **Controlla i log** nella console di entrambi i programmi
2. **Verifica la connettività**: `ping IP_SERVER`
3. **Testa la porta**: `telnet IP_SERVER 7777`
4. **Leggi i messaggi di errore**: Ora sono molto più dettagliati!

## 🎓 Prossimi Miglioramenti Consigliati

1. **HTTPS/TLS**: Crittografia delle comunicazioni
2. **Autenticazione**: Token o credenziali
3. **Persistenza**: Salvare le richieste in un database
4. **Notifiche**: Alert sonori per nuove richieste
5. **Multi-lingua**: Supporto internazionale
6. **Risoluzione richieste**: Stato "Risolta/In corso/Aperta"
7. **Chat**: Comunicazione bidirezionale

---

**Buon utilizzo! 🚀**
