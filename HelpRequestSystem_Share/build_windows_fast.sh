#!/bin/bash

echo "🔨 BUILD WINDOWS VELOCE - Senza self-contained"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "⚠️  NOTA: Questa build richiede .NET installato su Windows!"
echo "   Per build self-contained (senza .NET), usa: ./build_windows.sh"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Crea directory di output
BUILD_DIR="build_windows_fast"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo -e "${BLUE}[1/3]${NC} Compilazione Client per Windows (framework-dependent)..."
dotnet publish Client/Client.csproj \
    -c Release \
    -r win-x64 \
    --self-contained false \
    -o "$BUILD_DIR/Client" \
    --nologo

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Errore compilazione Client${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Client compilato${NC}"
echo ""

echo -e "${BLUE}[2/3]${NC} Compilazione Server per Windows (framework-dependent)..."
dotnet publish Server/Server.csproj \
    -c Release \
    -r win-x64 \
    --self-contained false \
    -o "$BUILD_DIR/Server" \
    --nologo

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Errore compilazione Server${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Server compilato${NC}"
echo ""

echo -e "${BLUE}[3/3]${NC} Creazione file configurazione e script..."

# Script Client
cat > "$BUILD_DIR/Client/start_client.bat" << 'EOF'
@echo off
echo ============================================
echo    Client HelpRequest - Cartella Condivisa
echo ============================================
echo.
echo ATTENZIONE: Questa versione richiede .NET 9 installato!
echo.
echo Verifica .NET installato:
dotnet --version
IF ERRORLEVEL 1 (
    echo.
    echo ERRORE: .NET non trovato!
    echo Scarica e installa .NET 9 da: https://dot.net
    pause
    exit /b 1
)
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
echo ATTENZIONE: Questa versione richiede .NET 9 installato!
echo.
echo Verifica .NET installato:
dotnet --version
IF ERRORLEVEL 1 (
    echo.
    echo ERRORE: .NET non trovato!
    echo Scarica e installa .NET 9 da: https://dot.net
    pause
    exit /b 1
)
echo.
echo Avvio server...
echo.
Server.exe
pause
EOF

# Configurazioni
cat > "$BUILD_DIR/Client/client_config.json" << 'EOF'
{
  "SharePath": "//192.168.0.114/HelpRequests",
  "LogFilePath": "client_log.txt",
  "EnableFileLogging": true,
  "EnableConsoleLogging": true
}
EOF

cat > "$BUILD_DIR/Server/server_config.json" << 'EOF'
{
  "SharePath": "//192.168.0.114/HelpRequests",
  "PollIntervalSeconds": 2,
  "AutoDeleteProcessedFiles": true,
  "LogFilePath": "server_log.txt",
  "EnableFileLogging": true,
  "EnableConsoleLogging": true
}
EOF

# README
cat > "$BUILD_DIR/README.txt" << 'EOF'
╔════════════════════════════════════════════════════════════╗
║   HelpRequestSystem - Build Veloce (richiede .NET)        ║
╚════════════════════════════════════════════════════════════╝

⚠️  REQUISITO: .NET 9 deve essere installato su Windows!

INSTALLAZIONE .NET:
  1. Scarica da: https://dot.net/download
  2. Installa "NET 9.0 Runtime" (o SDK)
  3. Riavvia il PC

VANTAGGI QUESTA BUILD:
  ✓ Compilazione velocissima (pochi secondi)
  ✓ File molto più piccoli (~5 MB vs ~70 MB)
  ✓ Aggiornabile facilmente

SVANTAGGIO:
  ✗ Richiede .NET installato su ogni PC Windows

═══════════════════════════════════════════════════════════

SETUP:

1. CREA CARTELLA CONDIVISA:
   - Sul PC Master: C:\HelpRequests
   - Condividi con "Everyone" (Lettura/Scrittura)

2. CONFIGURA:
   - Modifica server_config.json
   - Modifica client_config.json
   - Imposta "SharePath" corretto

3. AVVIA:
   - Server: start_server.bat
   - Client: start_client.bat

═══════════════════════════════════════════════════════════

Per build self-contained (senza .NET richiesto), usa:
  ./build_windows.sh

EOF

echo -e "${GREEN}✓ File creati${NC}"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ BUILD VELOCE COMPLETATA!${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Output: $BUILD_DIR/"
echo ""
echo "Dimensioni:"
du -sh "$BUILD_DIR/Client" 2>/dev/null
du -sh "$BUILD_DIR/Server" 2>/dev/null
echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
echo "  Questa build richiede .NET 9 installato sui PC Windows!"
echo "  Scarica da: https://dot.net/download"
echo ""
echo -e "${BLUE}💡 Per build self-contained (senza .NET):${NC}"
echo "  ./build_windows.sh"
echo ""
