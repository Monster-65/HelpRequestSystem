═══════════════════════════════════════════════════════════════
    HELP REQUEST SYSTEM - GUIDA WINDOWS
═══════════════════════════════════════════════════════════════

📦 CONTENUTO

  📁 Server/
     → Server.exe         (Applicazione server)
     → start_server.bat   (Avvia il server)
     → server_config.json (Configurazione)
     
  📁 Client/
     → Client.exe         (Applicazione client)
     → start_client.bat   (Avvia il client)
     → client_config.json (Configurazione)


🚀 INSTALLAZIONE

1. Copia la cartella "Server" sul computer che farà da master
2. Copia la cartella "Client" su ogni computer che deve inviare richieste


📋 AVVIO

SUL SERVER:
  1. Apri la cartella Server
  2. Doppio click su "start_server.bat" (o su "Server.exe")
  3. ⚠️ Se Windows chiede, clicca "Consenti accesso" per il firewall
  4. Prendi nota dell'IP mostrato (sarà nel file server_log.txt)

SUI CLIENT:
  1. Apri la cartella Client
  2. Doppio click su "start_client.bat" (o su "Client.exe")
  3. Nell'interfaccia, inserisci l'IP del server
  4. Inserisci il tuo nome e il messaggio
  5. Clicca "Invia Richiesta"


⚙️ CONFIGURAZIONE

Per cambiare IP o PORTA, modifica i file JSON:

server_config.json:
  - ServerPort: La porta usata dal server (default: 7777)
  - LogFilePath: Dove salvare i log

client_config.json:
  - DefaultServerIp: IP predefinito del server (default: 127.0.0.1)
  - ServerPort: Porta del server (deve corrispondere al server!)
  - RequestTimeoutSeconds: Timeout richieste in secondi


📄 LOG

Tutti i log sono salvati in file di testo:
  - server_log.txt (sul server)
  - client_log.txt (sui client)

Se qualcosa non funziona, controlla questi file!


🔥 FIREWALL WINDOWS

Al primo avvio, Windows Firewall potrebbe chiedere il permesso.
Clicca "Consenti accesso" per reti private!

Se non hai i permessi amministrativi, chiedi all'IT di:
  - Consentire Server.exe sulla porta configurata (default: 7777)
  - Permettere connessioni in entrata per Server.exe


🐛 PROBLEMI COMUNI

PROBLEMA: "Impossibile connettersi al server"
SOLUZIONE:
  ✓ Verifica che il server sia avviato
  ✓ Controlla l'IP inserito nel client
  ✓ Guarda server_log.txt per l'IP corretto
  ✓ Verifica il firewall Windows

PROBLEMA: Il server non parte
SOLUZIONE:
  ✓ Apri server_log.txt per vedere l'errore
  ✓ Verifica che la porta 7777 non sia in uso
  ✓ Prova a eseguire come amministratore (click destro → "Esegui come amministratore")

PROBLEMA: "Timeout"
SOLUZIONE:
  ✓ Ping al server: apri CMD e scrivi: ping IP_SERVER
  ✓ Verifica di essere sulla stessa rete del server
  ✓ Controlla il firewall


💡 SUGGERIMENTI

1. Testa prima con IP 127.0.0.1 sullo stesso PC
2. Poi prova con l'IP di rete tra computer diversi
3. I log ti dicono TUTTO - controlla sempre i file .txt!
4. Puoi cambiare porta e IP nei file config.json


📞 SUPPORTO

In caso di problemi, invia:
  - Il contenuto di server_log.txt
  - Il contenuto di client_log.txt
  - Descrizione del problema


═══════════════════════════════════════════════════════════════
