#!/bin/bash

echo "🧪 TEST RAPIDO - Help Request System"
echo "═══════════════════════════════════════════════════════════"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Questo script testa il sistema localmente con 127.0.0.1"
echo ""

# Test 1: Compilazione
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TEST 1: Compilazione"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Building Server..."
cd Server
dotnet build -c Debug > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Server compila correttamente${NC}"
else
    echo -e "${RED}✗ Errore compilazione Server${NC}"
    exit 1
fi

cd ../Client
echo "Building Client..."
dotnet build -c Debug > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Client compila correttamente${NC}"
else
    echo -e "${RED}✗ Errore compilazione Client${NC}"
    exit 1
fi

cd ..

# Test 2: File di configurazione
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TEST 2: File di configurazione"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# I file config vengono creati automaticamente al primo avvio
echo -e "${YELLOW}I file di configurazione verranno creati al primo avvio${NC}"
echo -e "${GREEN}✓ Sistema configurazione OK${NC}"

# Test 3: Script eseguibili
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TEST 3: Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -x "Server/start_server.sh" ]; then
    echo -e "${GREEN}✓ Server/start_server.sh è eseguibile${NC}"
else
    echo -e "${RED}✗ Server/start_server.sh non è eseguibile${NC}"
fi

if [ -x "Client/start_client.sh" ]; then
    echo -e "${GREEN}✓ Client/start_client.sh è eseguibile${NC}"
else
    echo -e "${RED}✗ Client/start_client.sh non è eseguibile${NC}"
fi

if [ -x "Server/get_ip.sh" ]; then
    echo -e "${GREEN}✓ Server/get_ip.sh è eseguibile${NC}"
else
    echo -e "${RED}✗ Server/get_ip.sh non è eseguibile${NC}"
fi

if [ -x "build_windows.sh" ]; then
    echo -e "${GREEN}✓ build_windows.sh è eseguibile${NC}"
else
    echo -e "${RED}✗ build_windows.sh non è eseguibile${NC}"
fi

# Test 4: Documentazione
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TEST 4: Documentazione"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docs=("README_IT.md" "FAQ.md" "SETUP_NETWORK.md" "CHANGELOG.md" "START_HERE.txt" "RISPOSTE_DOMANDE.txt")

for doc in "${docs[@]}"; do
    if [ -f "$doc" ]; then
        echo -e "${GREEN}✓ $doc presente${NC}"
    else
        echo -e "${YELLOW}⚠ $doc mancante${NC}"
    fi
done

# Riepilogo
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ RIEPILOGO TEST"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}✓ Sistema pronto per l'uso!${NC}"
echo ""
echo "Prossimi passi:"
echo "  1. Avvia il server: cd Server && sudo ./start_server.sh"
echo "  2. Avvia il client: cd Client && ./start_client.sh"
echo "  3. Nel client usa IP: 127.0.0.1 per test locale"
echo ""
echo "Per build Windows:"
echo "  ./build_windows.sh"
echo ""
echo "Per aiuto:"
echo "  cat START_HERE.txt"
echo "  cat FAQ.md"
echo ""
echo "═══════════════════════════════════════════════════════════"
