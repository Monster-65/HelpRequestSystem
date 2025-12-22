# 🚀 Guida alla Configurazione del Sistema Help Request

## 📌 Problema Identificato
Il client e il server non comunicavano perché usavano URL diversi. Questo è stato corretto.

## ✅ Correzioni Applicate

1. **URL Sincronizzati**: Client e Server ora usano lo stesso endpoint `/api/helprequest/`
2. **Logging Migliorato**: Sia client che server mostrano messaggi di debug
3. **Gestione Errori**: Messaggi più chiari per identificare problemi di rete
4. **Validazione Input**: Il client verifica che tutti i campi siano compilati

## 🔧 Come Far Comunicare i Computer

### SOLUZIONE 1: Eseguire con Permessi Amministrativi (RACCOMANDATO)

#### Su Linux:
```bash
# Compila il progetto
cd /home/king_monster_/Scrivania/HelpRequestSystem/Server
dotnet build

# Esegui come amministratore
sudo dotnet run
```

#### Su Windows:
1. Apri il terminale come **Amministratore**
2. Naviga nella cartella Server
3. Esegui: `dotnet run`

### SOLUZIONE 2: Registrare l'URL (Windows)

Se non vuoi eseguire sempre come amministratore su Windows:

```cmd
# Esegui questo comando UNA VOLTA come amministratore:
netsh http add urlacl url=http://+:7777/api/helprequest/ user=Everyone
```

### SOLUZIONE 3: Usare Kestrel invece di HttpListener

Se i permessi sono un problema, possiamo passare a Kestrel (ASP.NET Core).

## 🌐 Configurazione di Rete

### 1. Trova l'IP del Server

**Su Linux:**
```bash
ip addr show
# oppure
hostname -I
```

**Su Windows:**
```cmd
ipconfig
```

Cerca l'indirizzo IPv4 della tua rete locale (es. 192.168.1.x)

### 2. Verifica Connettività

Dal computer client, verifica che il server sia raggiungibile:

```bash
ping 192.168.1.x
```

### 3. Testa la Porta

**Dal computer SERVER**, verifica che la porta sia in ascolto:

**Linux:**
```bash
sudo netstat -tulpn | grep 7777
# oppure
sudo ss -tulpn | grep 7777
```

**Windows:**
```cmd
netstat -an | findstr 7777
```

### 4. Configura il Client

Nel programma Client, inserisci l'IP del server (es. `192.168.1.22`)

## 🐛 Troubleshooting

### Problema: "Accesso Negato" o "Access Denied"
**Soluzione**: Esegui il server con `sudo` (Linux) o come Amministratore (Windows)

### Problema: "Connection Refused"
**Possibili Cause**:
1. Il server non è avviato
2. IP errato nel client
3. Firewall locale blocca la connessione

**Soluzioni**:
```bash
# Linux - Consenti porta 7777 temporaneamente
sudo iptables -I INPUT -p tcp --dport 7777 -j ACCEPT

# Linux (firewalld)
sudo firewall-cmd --add-port=7777/tcp --permanent
sudo firewall-cmd --reload

# Linux (ufw)
sudo ufw allow 7777/tcp
```

### Problema: "Timeout"
- Verifica che entrambi i computer siano sulla stessa rete
- Controlla che non ci siano proxy o VPN attive
- Prova a pingare il server dal client

### Problema: Il server non parte
- Controlla che la porta 7777 non sia già in uso
- Verifica i log nella console del server

## 🧪 Test della Configurazione

### Test 1: Server Locale
Sul computer server, prova:
```bash
curl -X POST http://localhost:7777/api/helprequest/ \
  -H "Content-Type: application/json" \
  -d '{"ComputerName":"Test","User":"TestUser","Message":"Test message","Timestamp":"2025-12-18T10:00:00"}'
```

### Test 2: Da Altro Computer
Dal client (sostituisci IP):
```bash
curl -X POST http://192.168.1.22:7777/api/helprequest/ \
  -H "Content-Type: application/json" \
  -d '{"ComputerName":"Test","User":"TestUser","Message":"Test message","Timestamp":"2025-12-18T10:00:00"}'
```

## 📊 Passi per l'Avvio Completo

1. **Sul SERVER**:
   ```bash
   cd /home/king_monster_/Scrivania/HelpRequestSystem/Server
   sudo dotnet run
   ```
   
2. Verifica che appaia: "Server in ascolto su http://+:7777/api/helprequest/"

3. **Sul CLIENT**:
   ```bash
   cd /home/king_monster_/Scrivania/HelpRequestSystem/Client
   dotnet run
   ```

4. Nel client:
   - Inserisci l'IP del server
   - Inserisci il tuo nome
   - Scrivi un messaggio
   - Clicca "Invia Richiesta"

5. Controlla che la richiesta appaia nel server!

## 🔒 Nota sulla Sicurezza

⚠️ Questo sistema è progettato per reti private/locali. NON esporlo su Internet senza:
- Autenticazione
- HTTPS/TLS
- Validazione input lato server
- Rate limiting

## 🆘 Se Ancora Non Funziona

Controlla i log della console di entrambi i programmi. Ora mostrano:
- **Client**: URL di destinazione e errori dettagliati
- **Server**: Richieste ricevute e IP del client

Se vedi messaggi di errore, copia e incollali per ulteriore assistenza!
