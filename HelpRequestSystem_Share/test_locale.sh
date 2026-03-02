#!/bin/bash

echo "🧪 TEST LOCALE - Cartella Condivisa Simulata"
echo "═══════════════════════════════════════════════════════════"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Crea cartella temporanea per test
TEST_SHARE="/tmp/helprequests_test"
rm -rf "$TEST_SHARE"
mkdir -p "$TEST_SHARE"

echo -e "${BLUE}[1/3]${NC} Cartella di test creata: $TEST_SHARE"
echo ""

# Aggiorna configurazioni per test
echo -e "${BLUE}[2/3]${NC} Configurazione Client e Server per test locale..."

# Backup configurazioni originali
cp Client/client_config.json Client/client_config.json.backup 2>/dev/null || true
cp Server/server_config.json Server/server_config.json.backup 2>/dev/null || true

# Crea configurazioni di test
cat > Client/client_config.json << EOF
{
  "SharePath": "$TEST_SHARE",
  "LogFilePath": "client_log.txt",
  "EnableFileLogging": true,
  "EnableConsoleLogging": true
}
EOF

cat > Server/server_config.json << EOF
{
  "SharePath": "$TEST_SHARE",
  "PollIntervalSeconds": 1,
  "AutoDeleteProcessedFiles": true,
  "LogFilePath": "server_log.txt",
  "EnableFileLogging": true,
  "EnableConsoleLogging": true
}
EOF

echo -e "${GREEN}✓ Configurazioni aggiornate${NC}"
echo ""

echo -e "${BLUE}[3/3]${NC} Compilazione..."
dotnet build Client/Client.csproj > /dev/null 2>&1
dotnet build Server/Server.csproj > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Compilazione riuscita${NC}"
else
    echo -e "${RED}✗ Errore compilazione${NC}"
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ SETUP TEST COMPLETATO${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}📋 PER TESTARE:${NC}"
echo ""
echo "1. Apri DUE terminali:"
echo ""
echo "   ${BLUE}Terminal 1 (Server):${NC}"
echo "   cd Server"
echo "   dotnet run"
echo ""
echo "   ${BLUE}Terminal 2 (Client):${NC}"
echo "   cd Client"
echo "   dotnet run"
echo ""
echo "2. Nel Client:"
echo "   - Inserisci un nome"
echo "   - Scrivi un messaggio"
echo "   - Clicca 'Invia Richiesta'"
echo ""
echo "3. Verifica:"
echo "   - Controlla che la richiesta appaia nel Server"
echo "   - Controlla i file in: $TEST_SHARE"
echo "   - Leggi i log: server_log.txt e client_log.txt"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${BLUE}💡 Note:${NC}"
echo "  • Polling interval: 1 secondo (più veloce per test)"
echo "  • Auto-delete: true (i file spariscono dopo lettura)"
echo "  • Cartella test: $TEST_SHARE"
echo ""
echo -e "${YELLOW}⚠ Ripristino:${NC}"
echo "  Per tornare alle configurazioni originali:"
echo "  mv Client/client_config.json.backup Client/client_config.json"
echo "  mv Server/server_config.json.backup Server/server_config.json"
echo ""
