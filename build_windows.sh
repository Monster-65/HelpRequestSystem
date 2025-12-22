#!/bin/bash

echo "🔨 BUILD WINDOWS - Help Request System"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BUILD_DIR="build_windows"

echo -e "${BLUE}Questo script crea build Windows self-contained (con .NET incluso)${NC}"
echo -e "${BLUE}Gli .exe risultanti funzioneranno su Windows SENZA installare .NET${NC}"
echo ""

# Chiedi tipo di build
echo "Scegli il tipo di build:"
echo "1) Self-contained (Raccomandato - Include .NET, ~70MB per app)"
echo "2) Framework-dependent (Richiede .NET installato, ~1MB)"
echo ""
read -p "Scelta [1]: " choice
choice=${choice:-1}

if [ "$choice" == "2" ]; then
    SELF_CONTAINED="false"
    echo -e "${YELLOW}⚠️  Gli utenti Windows dovranno installare .NET 9.0 Runtime${NC}"
else
    SELF_CONTAINED="true"
    echo -e "${GREEN}✓ Build self-contained - Non richiede .NET su Windows${NC}"
fi

echo ""

# Pulizia build precedenti
if [ -d "$BUILD_DIR" ]; then
    echo "🧹 Pulizia build precedenti..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 BUILD SERVER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd Server

if [ "$SELF_CONTAINED" == "true" ]; then
    dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true
else
    dotnet publish -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Server compilato con successo${NC}"
    cp -r bin/Release/net9.0/win-x64/publish "../$BUILD_DIR/Server"
    
    # Crea file di configurazione predefinito
    cat > "../$BUILD_DIR/Server/server_config.json" << 'EOF'
{
  "ServerPort": "7777",
  "ApiEndpoint": "/api/helprequest/",
  "LogFilePath": "server_log.txt",
  "EnableFileLogging": true,
  "EnableConsoleLogging": true
}
EOF
    
    # Crea batch file per Windows
    cat > "../$BUILD_DIR/Server/start_server.bat" << 'EOF'
@echo off
echo ╔═══════════════════════════════════════════════════════════╗
echo ║     Help Request System - SERVER                          ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo Avvio del server...
echo I log verranno salvati in server_log.txt
echo.
Server.exe
pause
EOF
    
    echo -e "${GREEN}✓ File copiati in $BUILD_DIR/Server${NC}"
else
    echo -e "${RED}✗ Errore nella compilazione del Server${NC}"
    exit 1
fi

cd ..

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 BUILD CLIENT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd Client

if [ "$SELF_CONTAINED" == "true" ]; then
    dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true
else
    dotnet publish -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Client compilato con successo${NC}"
    cp -r bin/Release/net9.0/win-x64/publish "../$BUILD_DIR/Client"
    
    # Crea file di configurazione predefinito
    cat > "../$BUILD_DIR/Client/client_config.json" << 'EOF'
{
  "DefaultServerIp": "127.0.0.1",
  "ServerPort": "7777",
  "ApiEndpoint": "/api/helprequest/",
  "LogFilePath": "client_log.txt",
  "EnableFileLogging": true,
  "EnableConsoleLogging": true,
  "RequestTimeoutSeconds": 10
}
EOF
    
    # Crea batch file per Windows
    cat > "../$BUILD_DIR/Client/start_client.bat" << 'EOF'
@echo off
echo ╔═══════════════════════════════════════════════════════════╗
echo ║     Help Request System - CLIENT                          ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo Avvio del client...
echo I log verranno salvati in client_log.txt
echo.
Client.exe
EOF
    
    echo -e "${GREEN}✓ File copiati in $BUILD_DIR/Client${NC}"
else
    echo -e "${RED}✗ Errore nella compilazione del Client${NC}"
    exit 1
fi

cd ..

# Crea README per Windows
cat > "$BUILD_DIR/README_WINDOWS.txt" << 'EOF'
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
EOF

# Copia la guida completa
if [ -f "GUIDA_WINDOWS_SEMPLICE.txt" ]; then
    cp "GUIDA_WINDOWS_SEMPLICE.txt" "$BUILD_DIR/"
    echo -e "${GREEN}✓ Guida dettagliata copiata${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ BUILD COMPLETATA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}✓ Server Windows: $BUILD_DIR/Server/${NC}"
echo -e "${GREEN}✓ Client Windows: $BUILD_DIR/Client/${NC}"
echo ""
echo "📦 DIMENSIONI:"
du -sh "$BUILD_DIR/Server" 2>/dev/null | awk '{print "   Server: " $1}'
du -sh "$BUILD_DIR/Client" 2>/dev/null | awk '{print "   Client: " $1}'
echo ""
echo "📋 PROSSIMI PASSI:"
echo "   1. Copia la cartella 'Server' sul computer Windows server"
echo "   2. Copia la cartella 'Client' sui computer Windows client"
echo "   3. Leggi README_WINDOWS.txt per le istruzioni"
echo ""
echo "💡 SUGGERIMENTO:"
echo "   Puoi creare un file ZIP per facilitare il trasferimento:"
echo "   cd $BUILD_DIR && zip -r HelpRequestSystem_Windows.zip Server/ Client/ README_WINDOWS.txt"
echo ""
echo "═══════════════════════════════════════════════════════════"
