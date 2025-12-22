#!/bin/bash

echo "🚀 Avvio Server Help Request System"
echo "===================================="
echo ""

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verifica se siamo nella directory corretta
if [ ! -f "Server.csproj" ]; then
    echo -e "${RED}Errore: Esegui questo script dalla directory Server!${NC}"
    echo "cd /home/king_monster_/Scrivania/HelpRequestSystem/Server"
    exit 1
fi

# Trova l'IP locale
echo "📡 Rilevamento IP della rete locale..."
LOCAL_IP=$(hostname -I | awk '{print $1}')

if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -1)
fi

echo -e "${GREEN}✓ IP rilevato: $LOCAL_IP${NC}"
echo ""
echo -e "${YELLOW}⚠️  I client dovranno usare questo IP: $LOCAL_IP${NC}"
echo ""

# Verifica se la porta è già in uso
if netstat -tuln 2>/dev/null | grep -q ":7777 "; then
    echo -e "${RED}⚠️  La porta 7777 è già in uso!${NC}"
    echo "Chiudi l'altra applicazione o usa un'altra porta."
    exit 1
fi

# Verifica permessi
echo "🔐 Verifica permessi..."
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}⚠️  Non stai eseguendo come root.${NC}"
    echo "HttpListener potrebbe richiedere permessi amministrativi."
    echo ""
    echo "Se il server non parte, riesegui con: sudo $0"
    echo ""
    read -p "Vuoi continuare comunque? (s/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
        exit 1
    fi
fi

# Build del progetto
echo ""
echo "🔨 Compilazione del progetto..."
dotnet build -c Release

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Errore durante la compilazione!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Compilazione completata${NC}"
echo ""

# Avvio del server
echo "🚀 Avvio del server sulla porta 7777..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

dotnet run -c Release

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Server terminato."
