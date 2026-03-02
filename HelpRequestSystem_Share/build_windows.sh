#!/bin/bash

echo "🔨 BUILD WINDOWS SELF-CONTAINED - Versione Cartella Condivisa"
echo "═══════════════════════════════════════════════════════════"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Crea directory di output
BUILD_DIR="build_windows"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Controlla connessione internet
echo -e "${BLUE}[0/6]${NC} Verifica connessione..."
if ping -c 1 api.nuget.org > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Connessione OK${NC}"
else
    echo -e "${YELLOW}⚠ Connessione lenta o assente${NC}"
    echo "   Il download potrebbe richiedere più tempo..."
fi
echo ""

echo -e "${BLUE}[1/6]${NC} Preparazione cache NuGet..."
# Pre-scarica i runtime per evitare timeout durante publish
echo "   Scaricamento runtime Windows (può richiedere 2-5 minuti)..."

# Ripristino con runtime esplicito
dotnet restore Client/Client.csproj \
    -r win-x64 \
    --configfile /dev/null \
    --disable-parallel \
    --force

dotnet restore Server/Server.csproj \
    -r win-x64 \
    --configfile /dev/null \
    --disable-parallel \
    --force

echo -e "${GREEN}✓ Runtime scaricati${NC}"
echo ""

# Compilazione Client
echo -e "${BLUE}[2/6]${NC} Compilazione Client per Windows..."
echo "   (Self-contained: non richiede .NET su Windows)"
dotnet publish Client/Client.csproj \
    -c Release \
    -r win-x64 \
    --self-contained true \
    -p:PublishSingleFile=false \
    -p:PublishReadyToRun=false \
    -p:PublishTrimmed=false \
    -o "$BUILD_DIR/Client" \
    --no-restore \
    --nologo

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Errore compilazione Client${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Client compilato${NC}"
echo ""

# Compilazione Server
echo -e "${BLUE}[3/6]${NC} Compilazione Server per Windows..."
dotnet publish Server/Server.csproj \
    -c Release \
    -r win-x64 \
    --self-contained true \
    -p:PublishSingleFile=false \
    -p:PublishReadyToRun=false \
    -p:PublishTrimmed=false \
    -o "$BUILD_DIR/Server" \
    --no-restore \
    --nologo

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Errore compilazione Server${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Server compilato${NC}"
echo ""

echo -e "${BLUE}[4/6]${NC} Creazione script di avvio..."

# Script Client
cat > "$BUILD_DIR/Client/start_client.bat" << 'EOF'
@echo off
echo ============================================
echo    Client HelpRequest - Cartella Condivisa
echo ============================================
echo.
echo CONFIGURAZIONE:
echo   Modifica client_config.json per impostare
echo   il percorso della cartella condivisa
echo.
echo Avvio client...
echo.
Client.exe
pause
EOF

# Script Server
cat > "$BUILD_DIR/Server/start_server.bat" << 'EOF'
@echo off
echo ============================================
echo    Server HelpRequest - Cartella Condivisa
echo ============================================
echo.
echo CONFIGURAZIONE:
echo   Modifica server_config.json per impostare
echo   il percorso della cartella condivisa
echo.
echo Avvio server...
echo.
Server.exe
pause
EOF

echo -e "${GREEN}✓ Script di avvio creati${NC}"
echo ""

echo -e "${BLUE}[5/6]${NC} Copia file di configurazione..."

# Copia le configurazioni
cat > "$BUILD_DIR/Client/client_config.json" << 'EOF'
{
  "SharePath": "C:\\HelpRequests",
  "LogFilePath": "client_log.txt",
  "EnableFileLogging": true,
  "EnableConsoleLogging": true
}
EOF

cat > "$BUILD_DIR/Server/server_config.json" << 'EOF'
{
  "SharePath": "C:\\HelpRequests",
  "PollIntervalSeconds": 2,
  "AutoDeleteProcessedFiles": true,
  "LogFilePath": "server_log.txt",
  "EnableFileLogging": true,
  "EnableConsoleLogging": true
}
EOF

echo -e "${GREEN}✓ Configurazioni create${NC}"
echo ""

# Crea README nella build
cat > "$BUILD_DIR/README.txt" << 'EOF'
╔════════════════════════════════════════════════════════════╗
║   HelpRequestSystem - Versione Cartella Condivisa         ║
╚════════════════════════════════════════════════════════════╝

SETUP RAPIDO:

1. CREA CARTELLA CONDIVISA:
   - Crea: C:\HelpRequests (su un PC Windows)
   - Click destro → Proprietà → Condivisione
   - Condividi con "Everyone" (Lettura/Scrittura)
   - Annota percorso (es: \\192.168.0.114\HelpRequests)

2. SERVER (PC Master):
   - Modifica server_config.json
   - Imposta "SharePath": "C:\\HelpRequests"
     (o percorso network: "\\\\IP\\HelpRequests")
   - Avvia: start_server.bat

3. CLIENT (PC Utenti):
   - Modifica client_config.json  
   - Imposta "SharePath": "\\\\192.168.0.114\\HelpRequests"
   - Avvia: start_client.bat

═══════════════════════════════════════════════════════════

VANTAGGI:
✓ Nessuna porta di rete
✓ Nessuna configurazione firewall
✓ Funziona in ambienti aziendali

LOG:
- server_log.txt
- client_log.txt

TROUBLESHOOTING:
- Verifica che SharePath esista
- Controlla permessi Lettura/Scrittura
- Usa percorsi identici in client e server

EOF

echo -e "${GREEN}✓ README creato${NC}"
echo ""

echo -e "${BLUE}[6/6]${NC} Ottimizzazione per build future..."
# Salva info sulla cache
CACHE_INFO="$BUILD_DIR/.cache_info"
echo "Build completata: $(date)" > "$CACHE_INFO"
echo "Runtime win-x64 in cache: ~/.nuget/packages" >> "$CACHE_INFO"
echo "Prossime build saranno molto più veloci (cache già pronta)" >> "$CACHE_INFO"
echo -e "${GREEN}✓ Cache NuGet aggiornata${NC}"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ BUILD COMPLETATA!${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Output: $BUILD_DIR/"
echo ""
echo -e "${YELLOW}📋 PROSSIMI PASSI:${NC}"
echo ""
echo "1. Crea cartella condivisa su Windows: C:\\HelpRequests"
echo "2. Copia $BUILD_DIR/Server sul PC Master"
echo "3. Copia $BUILD_DIR/Client sui PC utente"
echo "4. Modifica *_config.json su ogni PC"
echo "5. Avvia start_server.bat e start_client.bat"
echo ""
echo "Dimensioni build:"
du -sh "$BUILD_DIR/Client" "$BUILD_DIR/Server"
echo ""
echo -e "${BLUE}💡 Note sulle performance:${NC}"
echo "  • Prima build: 2-10 minuti (download runtime ~200MB)"
echo "  • Build successive: 30-60 secondi (runtime in cache)"
echo "  • Cache NuGet: ~/.nuget/packages/"
echo ""
echo -e "${YELLOW}⚡ Per build veloce (richiede .NET su Windows):${NC}"
echo "  ./build_windows_fast.sh (~5 secondi, file più piccoli)"
echo ""
